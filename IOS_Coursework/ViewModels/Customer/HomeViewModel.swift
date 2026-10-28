//
//  HomeViewModel.swift
//  IOS_Coursework
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine



@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var fullName = ""
    @Published private(set) var upcoming: BookingItem?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }

   

    func start() {
        guard listener == nil, let uid = Auth.auth().currentUser?.uid else { return }

      
        Task {
            if let data = try? await db.collection("users").document(uid).getDocument().data() {
                fullName = data["fullName"] as? String ?? ""
            }
        }

        
        listener = db.collection("bookings")
            .whereField("customerId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                let items = snapshot?.documents.map { BookingItem(id: $0.documentID, data: $0.data()) } ?? []
                Task { @MainActor [weak self] in
                    self?.updateUpcoming(items)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    private func updateUpcoming(_ items: [BookingItem]) {
        let now = Date()

        let candidates = items.filter { (booking: BookingItem) -> Bool in
            switch booking.status {
            case "in_progress":
                return true
            case "pending", "accepted":
                return (booking.scheduledAt ?? now) >= now
            default:
                return false
            }
        }

        upcoming = candidates.sorted {
            ($0.scheduledAt ?? .distantFuture) < ($1.scheduledAt ?? .distantFuture)
        }.first

       
        WidgetStore.save(WidgetSnapshot(
            isSignedIn: true,
            role: "customer",
            name: firstName,
            nextService: upcoming?.service,
            nextPerson: upcoming?.workerName,
            nextDate: upcoming?.scheduledAt,
            nextStatus: upcoming?.status
        ))
    }

   

  
    func timeText(_ booking: BookingItem) -> String {
        guard let date = booking.scheduledAt else { return "--" }

        let time = DateFormatter()
        time.locale = Locale(identifier: "en_US")
        time.dateFormat = "h:mm a"
        let timeText = time.string(from: date)

        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today, \(timeText)" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow, \(timeText)" }

        let day = DateFormatter()
        day.locale = Locale(identifier: "en_US")
        day.dateFormat = "MMM d"
        return "\(day.string(from: date)), \(timeText)"
    }
}
