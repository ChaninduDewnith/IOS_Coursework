//
//  BookingSubmittedViewModel.swift
//  IOS_Coursework
//

//

import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class BookingSubmittedViewModel: ObservableObject {

    let bookingID: String

    @Published private(set) var workerName = ""
    @Published private(set) var service = ""
    @Published private(set) var scheduledAt: Date?
    @Published private(set) var status = "pending"
    @Published private(set) var isLoading = false
    @Published private(set) var loadFailed = false

    private let db = Firestore.firestore()

    init(bookingID: String) {
        self.bookingID = bookingID
    }



   
    var dateTimeText: String {
        guard let scheduledAt else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy 'at' hh:mm a"
        return formatter.string(from: scheduledAt)
    }

    var statusText: String {
        switch status {
        case "pending": return "Pending Approval"
        case "accepted": return "Accepted"
        case "declined": return "Declined"
        case "completed": return "Completed"
        case "cancelled": return "Cancelled"
        default: return status.capitalized
        }
    }

    var statusColors: (text: Color, background: Color) {
        switch status {
        case "accepted", "completed":
            return (Color(red: 0.05, green: 0.45, blue: 0.3), Color.green.opacity(0.15))
        case "declined", "cancelled":
            return (Color(red: 0.7, green: 0.1, blue: 0.1), Color.red.opacity(0.12))
        default: 
            return (Color(red: 0.6, green: 0.35, blue: 0.0), Color.yellow.opacity(0.3))
        }
    }

 

    func load() async {
        isLoading = true
        loadFailed = false
        defer { isLoading = false }

        do {
            let snapshot = try await db.collection("bookings").document(bookingID).getDocument()
            guard let data = snapshot.data() else {
                loadFailed = true
                return
            }

            workerName = data["workerName"] as? String ?? ""
            service = data["serviceCategory"] as? String ?? ""
            scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue()
            status = data["status"] as? String ?? "pending"
        } catch {
            loadFailed = true
        }
    }
}
