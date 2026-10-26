//
//  BookingHistoryViewModel.swift
//  IOS_Coursework
//



import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class BookingHistoryViewModel: ObservableObject {

    @Published private(set) var all: [BookingItem] = []
    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private var bookingsListener: ListenerRegistration?
    private var favoritesListener: ListenerRegistration?

   
    var history: [BookingItem] {
        all.filter { ["completed", "cancelled", "declined"].contains($0.status) }
            .sorted { ($0.scheduledAt ?? .distantPast) > ($1.scheduledAt ?? .distantPast) }
    }

    func isFavorite(_ workerID: String) -> Bool {
        favoriteIDs.contains(workerID)
    }

   
    func dateText(_ booking: BookingItem) -> String {
        guard let date = booking.scheduledAt else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }

   

    func start() {
        guard bookingsListener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to see your history.")
            return
        }

        isLoading = true

        bookingsListener = db.collection("bookings")
            .whereField("customerId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                let items = snapshot?.documents.map { BookingItem(id: $0.documentID, data: $0.data()) }
                let message = error?.localizedDescription

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    if let items {
                        self.all = items
                    } else if let message {
                        self.show("Could not load history: \(message)")
                    }
                }
            }

        favoritesListener = db.collection("users").document(uid).collection("favorites")
            .addSnapshotListener { [weak self] snapshot, _ in
                let ids = Set(snapshot?.documents.map { $0.documentID } ?? [])
                Task { @MainActor [weak self] in
                    self?.favoriteIDs = ids
                }
            }
    }

    func stop() {
        bookingsListener?.remove()
        bookingsListener = nil
        favoritesListener?.remove()
        favoritesListener = nil
    }

  
    func toggleFavorite(workerID: String) async {
        guard let uid = Auth.auth().currentUser?.uid, !workerID.isEmpty else { return }

        let ref = db.collection("users").document(uid).collection("favorites").document(workerID)
        let wasFavorite = favoriteIDs.contains(workerID)

       
        if wasFavorite { favoriteIDs.remove(workerID) } else { favoriteIDs.insert(workerID) }

        do {
            if wasFavorite {
                try await ref.delete()
            } else {
                try await ref.setData([
                    "workerId": workerID,
                    "createdAt": FieldValue.serverTimestamp()
                ])
            }
        } catch {
          
            if wasFavorite { favoriteIDs.insert(workerID) } else { favoriteIDs.remove(workerID) }
            show("Could not update favorites: \(error.localizedDescription)")
        }
    }

  
    func submitReview(for booking: BookingItem, rating: Int, comment: String) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to rate a service.")
            return false
        }
        guard (1...5).contains(rating) else {
            show("Please choose a star rating.")
            return false
        }
        guard !booking.reviewed else {
            show("You have already rated this service.")
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let workerRef = db.collection("users").document(booking.workerId)

        do {
            
            let workerData = try await workerRef.getDocument().data() ?? [:]
            let oldCount = (workerData["reviewCount"] as? NSNumber)?.intValue ?? 0
            let oldSum = (workerData["ratingSum"] as? NSNumber)?.doubleValue
                ?? ((workerData["rating"] as? NSNumber)?.doubleValue ?? 0) * Double(oldCount)

            let newCount = oldCount + 1
            let newSum = oldSum + Double(rating)

            let batch = db.batch()

            batch.setData([
                "bookingId": booking.id,
                "customerId": uid,
                "customerName": booking.customerName.isEmpty ? "Customer" : booking.customerName,
                "rating": rating,
                "comment": comment.trimmingCharacters(in: .whitespacesAndNewlines),
                "createdAt": FieldValue.serverTimestamp()
            ], forDocument: workerRef.collection("reviews").document(booking.id))

            batch.setData([
                "rating": newSum / Double(newCount),
                "ratingSum": newSum,
                "reviewCount": newCount
            ], forDocument: workerRef, merge: true)

            batch.updateData([
                "reviewed": true,
                "reviewRating": rating,
                "reviewedAt": FieldValue.serverTimestamp()
            ], forDocument: db.collection("bookings").document(booking.id))

            try await batch.commit()
            return true
        } catch {
            show("Could not save your rating: \(error.localizedDescription)")
            return false
        }
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
