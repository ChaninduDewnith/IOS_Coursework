//
//  FavoritesView.swift
//  IOS_Coursework
//



import SwiftUI

struct FavoritesView: View {

    @StateObject private var viewModel = FavoritesViewModel()
    @State private var chosenWorkerID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let maxContentWidth: CGFloat = 1100

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(alignment: .leading, spacing: 20) {
                header

                if viewModel.isLoading && viewModel.workers.isEmpty {
                    Spacer()
                    ProgressView("Loading favorites...")
                    Spacer()
                } else if viewModel.workers.isEmpty {
                    ScrollView {
                        emptyState
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(
                                    .flexible(),
                                    spacing: 16,
                                    alignment: .top
                                ),
                                count: isPad ? 2 : 1
                            ),
                            alignment: .center,
                            spacing: 16
                        ) {
                            ForEach(viewModel.workers) { worker in
                                card(worker)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .padding(.top, 12)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(uiColor: .systemBackground))
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .workerFlow(selection: $chosenWorkerID)
        .alert(
            "Remove from favorites?",
            isPresented: Binding(
                get: { viewModel.workerToRemove != nil },
                set: {
                    if !$0 {
                        viewModel.workerToRemove = nil
                    }
                }
            )
        ) {
            Button("Remove", role: .destructive) {
                if let worker = viewModel.workerToRemove {
                    Task {
                        await viewModel.remove(worker)
                    }
                }
            }

            Button("Keep", role: .cancel) {
                viewModel.workerToRemove = nil
            }
        } message: {
            if let worker = viewModel.workerToRemove {
                Text("\(worker.name) will be removed from your favorites.")
            }
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

  

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Favorites")
                .font(.title2)
                .fontWeight(.bold)

            if !viewModel.workers.isEmpty {
                Text(
                    "\(viewModel.workers.count) saved " +
                    "\(viewModel.workers.count == 1 ? "worker" : "workers")"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            } else {
                Text("Your saved workers will appear here.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

 

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundStyle(Color.gray.opacity(0.4))

            Text("No favorites yet")
                .font(.headline)
                .fontWeight(.bold)

            Text(
                "Tap the heart on a worker's profile to save them " +
                "here for quick booking."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    

    private func card(_ worker: FavoriteWorker) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 12) {
                avatar(worker)

                VStack(alignment: .leading, spacing: 5) {
                    Text(worker.name)
                        .font(.headline)
                        .lineLimit(2)

                    Text(
                        [worker.category, worker.experience]
                            .filter { !$0.isEmpty }
                            .joined(separator: " · ")
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)

                            Text(
                                worker.rating.map {
                                    String(format: "%.1f", $0)
                                } ?? "New"
                            )
                            .fontWeight(.semibold)
                        }
                        .font(.caption)

                        if let rate = worker.hourlyRate {
                            Text(
                                rate.truncatingRemainder(dividingBy: 1) == 0
                                ? "Rs. \(Int(rate))/hr"
                                : String(format: "Rs. %.2f/hr", rate)
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(blue)
                        }
                    }
                }

                Spacer(minLength: 4)

                Button {
                    viewModel.workerToRemove = worker
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.red)
                        .frame(width: 38, height: 38)
                        .background(Color.red.opacity(0.07))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(worker.name) from favorites")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                chosenWorkerID = worker.id
            }

            Divider()

            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(worker.isOnline ? .green : .gray)
                        .frame(width: 8, height: 8)

                    Text(worker.isOnline ? "Available" : "Offline")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            worker.isOnline ? .green : .secondary
                        )
                }

                Spacer(minLength: 8)

                Button {
                    chosenWorkerID = worker.id
                } label: {
                    HStack(spacing: 6) {
                        Text("Book Now")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .frame(minHeight: 42)
                    .background(
                        worker.isOnline ? blue : Color.gray.opacity(0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!worker.isOnline)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

    

    @ViewBuilder
    private func avatar(_ worker: FavoriteWorker) -> some View {
        let initial = Text(
            String(worker.name.prefix(1)).uppercased()
        )
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(blue)
        .frame(width: 58, height: 58)
        .background(blue.opacity(0.13))

        Group {
            if let url = worker.photoURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        initial
                    }
                }
            } else {
                initial
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(Circle())
        .accessibilityLabel("\(worker.name)'s profile picture")
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
