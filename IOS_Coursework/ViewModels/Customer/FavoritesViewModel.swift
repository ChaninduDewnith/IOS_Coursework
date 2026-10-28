//
//  FavoritesViewModel.swift
//  IOS_Coursework
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine



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

