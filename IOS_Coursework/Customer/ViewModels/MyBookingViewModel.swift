//
//  MyBookingViewModel.swift
//  IOS_Coursework
//



import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct BookingItem: Identifiable, Equatable {
    let id: String
    let workerId: String
    let workerName: String
    let service: String
    let scheduledAt: Date?
    let timeSlot: String
    let address: String
    let issue: String
    let hourlyRate: Double
    let customerName: String
    let reviewed: Bool
    let reviewRating: Double?
    let status: String

    init(id: String, data: [String: Any]) {
        self.id = id
        self.workerId = data["workerId"] as? String ?? ""
        self.workerName = data["workerName"] as? String ?? "Worker"
        self.service = data["serviceCategory"] as? String ?? ""
        self.scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue()
        self.timeSlot = data["timeSlot"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.issue = data["issue"] as? String ?? ""
        self.hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue ?? 0
        self.status = data["status"] as? String ?? "pending"
        self.customerName = data["customerName"] as? String ?? ""
        self.reviewed = data["reviewed"] as? Bool ?? false
        self.reviewRating = (data["reviewRating"] as? NSNumber)?.doubleValue
    }

    var isPending: Bool { status == "pending" }
    var isConfirmed: Bool { status == "accepted" }
    var canCancel: Bool { isPending || isConfirmed }
}

@MainActor
final class MyBookingsViewModel: ObservableObject {

    enum Tab: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
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
