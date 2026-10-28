//
//  MyBookingViewModel.swift
//  IOS_Coursework
//



import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine



@MainActor
final class MyBookingsViewModel: ObservableObject {

    enum Tab: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case ongoing = "Ongoing"
        case pending = "Pending"
        case confirmed = "Confirmed"
        var id: String { rawValue }
    }

    @Published var tab: Tab = .upcoming
    @Published private(set) var allBookings: [BookingItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isCancelling = false
    @Published var bookingToCancel: BookingItem?
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

  

    var bookings: [BookingItem] {
        let now = Date()

        let filtered: [BookingItem]
        switch tab {
        case .upcoming:
            filtered = allBookings.filter {
                ($0.isPending || $0.isConfirmed) && ($0.scheduledAt ?? now) >= now
            }
        case .ongoing:
            filtered = allBookings.filter { $0.isOngoing }
        case .pending:
            filtered = allBookings.filter { $0.isPending }
        case .confirmed:
            filtered = allBookings.filter { $0.isConfirmed }
        }

       
        return filtered.sorted {
            ($0.scheduledAt ?? .distantFuture) < ($1.scheduledAt ?? .distantFuture)
        }
    }

    var emptyMessage: String {
        switch tab {
        case .upcoming: return "No upcoming bookings."
        case .ongoing: return "No jobs in progress right now."
        case .pending: return "No bookings waiting for approval."
        case .confirmed: return "No confirmed bookings yet."
        }
    }


    func start() {
        guard listener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to see your bookings.")
            return
        }

        isLoading = true

        listener = db.collection("bookings")
            .whereField("customerId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                let items = snapshot?.documents.map { BookingItem(id: $0.documentID, data: $0.data()) }
                let message = error?.localizedDescription

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    if let items {
                        self.allBookings = items
                    } else if let message {
                        self.show("Could not load bookings: \(message)")
                    }
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    
    func cancel(_ booking: BookingItem) async {
        bookingToCancel = nil

        isCancelling = true
        defer { isCancelling = false }

        do {
            try await db.collection("bookings").document(booking.id).updateData([
                "status": "cancelled",
                "cancelledAt": FieldValue.serverTimestamp()
            ])

            let day = DateFormatter()
            day.locale = Locale(identifier: "en_US")
            day.dateFormat = "MMM d"
            let when = booking.scheduledAt.map { " on \(day.string(from: $0))" } ?? ""
            await NotificationService.send(
                to: booking.workerId, type: "booking_cancelled",
                title: "Booking Cancelled",
                message: "\(booking.customerName) cancelled the \(booking.service.lowercased()) request\(when).",
                bookingID: booking.id)
           
        } catch {
            show("Could not cancel booking: \(error.localizedDescription)")
        }
    }

   
    func dateText(_ booking: BookingItem) -> String {
        guard let date = booking.scheduledAt else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
