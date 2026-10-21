//
//  SearchView.swift
//  IOS_Coursework
//

//

import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    var onChoose: (WorkerResult) -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(initialSearch: String = "",
         onChoose: @escaping (WorkerResult) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(searchText: initialSearch))
        self.onChoose = onChoose
    }

    var body: some View {
        VStack(spacing: 14) {

            searchField

            filterChips

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.results) { worker in
                        workerCard(worker)
                    }

                    if !viewModel.isLoading && viewModel.results.isEmpty {
                        Text("No workers found nearby.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }
                }
                .padding(.bottom, 80)
            }
            .refreshable { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && viewModel.allWorkers.isEmpty {
                    ProgressView()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            NavigationLink {
                WorkerMapView(viewModel: viewModel, onChoose: onChoose)
            } label: {
                Label("View on Map", systemImage: "map.fill")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(blue)
                    .clipShape(Capsule())
                    .shadow(radius: 4, y: 2)
            }
            .padding(.bottom, 12)
        }
        .task { await viewModel.load() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

  

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(blue)

            TextField("Search plumber, electrician...", text: $viewModel.searchText)
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(blue, lineWidth: 1.5)
        )
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
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(isSelected ? .white : .black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? blue : Color.white)
                            .overlay(
                                Capsule().stroke(isSelected ? blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func workerCard(_ worker: WorkerResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(worker.name)
                        .fontWeight(.bold)
                    Text(subtitle(for: worker))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "star")
                        .foregroundColor(.orange)
                    Text(worker.rating.map { String(format: "%.1f", $0) } ?? "New")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
            }

            HStack(spacing: 8) {
                if let distance = worker.distanceMiles {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f miles", distance))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(worker.statusText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(worker.isAvailableToday ? Color(red: 0.1, green: 0.6, blue: 0.4) : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (worker.isAvailableToday ? Color.green : Color.gray).opacity(0.15)
                    )
                    .cornerRadius(4)

                Spacer()

                Button {
                    onChoose(worker)
                } label: {
                    Text("Choose")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func subtitle(for worker: WorkerResult) -> String {
        [worker.category, worker.experience]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}
