//
//  FavoritesViewModel.swift
//  IOS_Coursework
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct FavoriteWorker: Identifiable {
    let id: String
    let name: String
    let category: String
    let experience: String
    let rating: Double?
    let reviewCount: Int?
    let hourlyRate: Double?
    let photoURL: URL?
    let isOnline: Bool

    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["fullName"] as? String ?? "Worker"
        self.category = data["serviceCategory"] as? String ?? ""
        self.experience = data["experience"] as? String ?? ""
        self.rating = (data["rating"] as? NSNumber)?.doubleValue
        self.reviewCount = (data["reviewCount"] as? NSNumber)?.intValue
        self.hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue
        self.photoURL = (data["photoURL"] as? String).flatMap(URL.init(string:))
        self.isOnline = data["isAvailable"] as? Bool ?? true
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published private(set) var workers: [FavoriteWorker] = []
    @Published private(set) var isLoading = false
    @Published var workerToRemove: FavoriteWorker?
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var loadTask: Task<Void, Never>?

 
    func start() {
        guard listener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to see your favorites.")
            return
        }

        isLoading = true

        listener = db.collection("users").document(uid).collection("favorites")
            .addSnapshotListener { [weak self] snapshot, error in
                
                let ids = (snapshot?.documents ?? [])
                    .map { doc -> (id: String, date: Date) in
                        (doc.documentID, (doc.data()["createdAt"] as? Timestamp)?.dateValue() ?? .distantFuture)
                    }
                    .sorted { $0.date > $1.date }
                    .map { $0.id }
                let message = error?.localizedDescription

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let message, snapshot == nil {
                        self.isLoading = false
                        self.show("Could not load favorites: \(message)")
                        return
                    }
                    self.reload(ids: ids)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
        loadTask?.cancel()
    }

   

    private func reload(ids: [String]) {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }

            guard !ids.isEmpty else {
                self.workers = []
                self.isLoading = false
                return
            }

            var found: [String: FavoriteWorker] = [:]

           
            for start in stride(from: 0, to: ids.count, by: 10) {
                let chunk = Array(ids[start..<min(start + 10, ids.count)])
                if let snapshot = try? await self.db.collection("users")
                    .whereField(FieldPath.documentID(), in: chunk)
                    .getDocuments() {
                    for doc in snapshot.documents {
                        found[doc.documentID] = FavoriteWorker(id: doc.documentID, data: doc.data())
                    }
                }
            }

            if Task.isCancelled { return }

            
            self.workers = ids.compactMap { found[$0] }
            self.isLoading = false
        }
    }

  

    
    func remove(_ worker: FavoriteWorker) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

    
        workers.removeAll { $0.id == worker.id }

        do {
            try await db.collection("users").document(uid)
                .collection("favorites").document(worker.id).delete()
        } catch {
            show("Could not remove favorite: \(error.localizedDescription)")
            reload(ids: workers.map(\.id) + [worker.id])
        }
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}

