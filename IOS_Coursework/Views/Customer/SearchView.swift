//
//  SearchView.swift
//  IOS_Coursework
//

//


import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    var onChoose: (WorkerResult) -> Void
    var onBackToHome: () -> Void = {}

    @State private var chosenWorkerID: String?

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    private let maxContentWidth: CGFloat = 1100

    init(
        initialSearch: String = "",
        onChoose: @escaping (WorkerResult) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: SearchViewModel(searchText: initialSearch)
        )
        self.onChoose = onChoose
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 16) {
                searchField

                filterChips

                resultsContent(isPad: isPad)
            }
            .padding(.horizontal, isPad ? 28 : 20)
            .padding(.top, 12)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                mapButton
                    .padding(.bottom, 12)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .workerFlow(
            selection: $chosenWorkerID,
            onBackToHome: onBackToHome
        )
        .task {
            await viewModel.load()
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

   

    @ViewBuilder
    private func resultsContent(isPad: Bool) -> some View {
        if viewModel.isLoading && viewModel.allWorkers.isEmpty {
            Spacer()
            ProgressView("Finding workers...")
            Spacer()
        } else if viewModel.results.isEmpty {
            ScrollView {
                emptyState
                    .frame(maxWidth: .infinity)
            }
            .refreshable {
                await viewModel.load()
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
                    spacing: 14
                ) {
                    ForEach(viewModel.results) { worker in
                        workerCard(worker)
                    }
                }
                .padding(.bottom, 90)
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

  

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(blue)

            TextField(
                "Search plumber, electrician...",
                text: $viewModel.searchText
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 48)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(blue.opacity(0.65), lineWidth: 1)
        }
    }

    

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchViewModel.Filter.allCases) { item in
                    let isSelected = viewModel.filter == item

                    Button {
                        viewModel.filter = item
                    } label: {
                        Text(item.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                isSelected ? .white : .primary
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background {
                                Capsule()
                                    .fill(
                                        isSelected
                                        ? blue
                                        : Color(uiColor: .secondarySystemBackground)
                                    )
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        isSelected
                                        ? blue
                                        : Color.gray.opacity(0.3),
                                        lineWidth: 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 42))
                .foregroundStyle(blue.opacity(0.6))

            Text("No workers found")
                .font(.headline)
                .fontWeight(.bold)

            Text(
                "Try another search term or change your filters " +
                "to find available professionals."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 320)
        }
        .padding(.vertical, 55)
    }

    

    private func workerCard(_ worker: WorkerResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(worker.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Text(subtitle(for: worker))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 4)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)

                    Text(
                        worker.rating.map {
                            String(format: "%.1f", $0)
                        } ?? "New"
                    )
                    .fontWeight(.semibold)
                }
                .font(.footnote)
            }

            HStack(spacing: 8) {
                if let distance = worker.distanceMiles {
                    Label {
                        Text(String(format: "%.1f miles", distance))
                    } icon: {
                        Image(systemName: "mappin.circle")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Text(worker.statusText)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        worker.isAvailableToday ? Color.green : Color.gray
                    )
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .fill(
                                (worker.isAvailableToday
                                 ? Color.green
                                 : Color.gray).opacity(0.13)
                            )
                    }
            }

            HStack {
                Spacer()

                Button {
                    onChoose(worker)
                    chosenWorkerID = worker.id
                } label: {
                    HStack(spacing: 7) {
                        Text("Choose Worker")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 42)
                    .background(blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 15))
    }

 

    private var mapButton: some View {
        NavigationLink {
            WorkerMapView(
                viewModel: viewModel,
                onChoose: onChoose,
                onBackToHome: onBackToHome
            )
        } label: {
            Label("View on Map", systemImage: "map.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 13)
                .background(blue)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }

    

    private func subtitle(for worker: WorkerResult) -> String {
        [worker.category, worker.experience]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
