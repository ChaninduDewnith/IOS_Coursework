//
//  SerachViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI
import CoreLocation
import FirebaseFirestore
import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    enum Filter: String, CaseIterable, Identifiable {
        case nearMe = "Near Me"
        case topRated = "Top Rated"
        case availableToday = "Available Today"
        var id: String { rawValue }
    }

   
    static let workerRole = "worker"

    
    @Published var searchText: String
    @Published var filter: Filter = .nearMe
    @Published private(set) var allWorkers: [WorkerResult] = []
    @Published private(set) var userLocation: CLLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private let locationManager = LocationManager()

    init(searchText: String = "") {
        self.searchText = searchText
    }

   
    var results: [WorkerResult] {
     
        var list = allWorkers.filter { $0.isOnline }.map { worker -> WorkerResult in
            var copy = worker
            if let user = userLocation {
                let workerLocation = CLLocation(latitude: worker.coordinate.latitude,
                                                longitude: worker.coordinate.longitude)
                copy.distanceMiles = user.distance(from: workerLocation) / 1609.344
            }
            return copy
        }

       
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter { worker in
                let category = worker.category.lowercased()
                return (!category.isEmpty && (category.contains(query) || query.contains(category)))
                    || worker.name.lowercased().contains(query)
            }
        }

                list = list.filter { worker in
            guard let distance = worker.distanceMiles,
                  let radius = worker.serviceRadiusMiles else { return true }
            return distance <= radius
        }

        switch filter {
        case .nearMe:
            return list.sorted { ($0.distanceMiles ?? .infinity) < ($1.distanceMiles ?? .infinity) }
        case .topRated:
            return list.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .availableToday:
            return list.filter { $0.isAvailableToday }
                .sorted { ($0.distanceMiles ?? .infinity) < ($1.distanceMiles ?? .infinity) }
        }
    }

    var mapTitle: String {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "Workers Near Me" : "\(text.capitalized)s Near Me"
    }

   
    func load() async {
        isLoading = true
        defer { isLoading = false }


        do {
            let snapshot = try await db.collection("users")
                .whereField("role", isEqualTo: Self.workerRole)
                .getDocuments()

            allWorkers = snapshot.documents.compactMap {
                WorkerResult(id: $0.documentID, data: $0.data())
            }
        } catch {
            errorMessage = "Could not load workers: \(error.localizedDescription)"
            showError = true
            return
        }

       
        userLocation = try? await locationManager.currentLocation()
    }
}
