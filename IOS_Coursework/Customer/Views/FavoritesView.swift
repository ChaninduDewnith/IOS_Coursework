//
//  FavoritesView.swift
//  IOS_Coursework
//


import SwiftUI


struct FavoritesView: View {

    @StateObject private var viewModel = FavoritesViewModel()

  
    @State private var chosenWorkerID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Favorites")
                    .font(.title2)
                    .fontWeight(.bold)
                if !viewModel.workers.isEmpty {
                    Text("\(viewModel.workers.count) saved \(viewModel.workers.count == 1 ? "worker" : "workers")")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }

            if viewModel.workers.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.workers) { worker in
                            card(worker)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .overlay {
                    if viewModel.isLoading && viewModel.workers.isEmpty {
                        ProgressView()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .workerFlow(selection: $chosenWorkerID)
        .alert("Remove from favorites?",
               isPresented: Binding(
                get: { viewModel.workerToRemove != nil },
                set: { if !$0 { viewModel.workerToRemove = nil } }
               )) {
            Button("Remove", role: .destructive) {
                if let worker = viewModel.workerToRemove {
                    Task { await viewModel.remove(worker) }
                }
            }
            Button("Keep", role: .cancel) { }
        } message: {
            if let worker = viewModel.workerToRemove {
                Text("\(worker.name) will be removed from your favorites.")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 44))
                .foregroundColor(Color.gray.opacity(0.4))

            Text("No favorites yet")
                .fontWeight(.bold)

            Text("Tap the heart on a worker's profile to save them here for quick booking.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

  

    private func card(_ worker: FavoriteWorker) -> some View {
        VStack(alignment: .leading, spacing: 12) {

         
            HStack(alignment: .top, spacing: 12) {
                avatar(worker)

                VStack(alignment: .leading, spacing: 4) {
                    Text(worker.name)
                        .fontWeight(.bold)

                    Text([worker.category, worker.experience]
                        .filter { !$0.isEmpty }
                        .joined(separator: " · "))
                        .font(.footnote)
                        .foregroundColor(.gray)

                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(worker.rating.map { String(format: "%.1f", $0) } ?? "New")
                                .font(.caption)
                                .fontWeight(.bold)
                        }

                        if let rate = worker.hourlyRate {
                            Text(rate.truncatingRemainder(dividingBy: 1) == 0
                                 ? "Rs.\(Int(rate))/hr"
                                 : String(format: "Rs.%.2f/hr", rate))
                                .font(.caption)
                                .foregroundColor(blue)
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.workerToRemove = worker
                } label: {
                    Image(systemName: "heart.fill")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { chosenWorkerID = worker.id }

            HStack {
                Text(worker.isOnline ? "Available" : "Offline")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(worker.isOnline ? .green : .gray)
                    .padding(5)
                    .background(worker.isOnline ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .cornerRadius(6)

                Spacer()

                Button {
                    chosenWorkerID = worker.id
                } label: {
                    Text("Book Now")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(worker.isOnline ? blue : Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!worker.isOnline)
            }
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func avatar(_ worker: FavoriteWorker) -> some View {
        let initial = Text(String(worker.name.prefix(1)).uppercased())
            .fontWeight(.bold)
            .foregroundColor(blue)
            .frame(width: 52, height: 52)
            .background(blue.opacity(0.15))

        Group {
            if let url = worker.photoURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        initial
                    }
                }
            } else {
                initial
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(Circle())
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}

