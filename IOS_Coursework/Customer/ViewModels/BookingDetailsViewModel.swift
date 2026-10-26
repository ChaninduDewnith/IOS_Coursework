//
//  BookingDetailsViewModel.swift
//  IOS_Coursework
//
//

import SwiftUI
import FirebaseFirestore
import Combine

struct TimelineStep: Identifiable {
    enum Kind { case done, upcoming, failed }

    let id: Int
    let title: String
    let date: Date?
    let kind: Kind
}

@MainActor
final class BookingDetailsViewModel: ObservableObject {

    let bookingID: String

    @Published private(set) var workerName = ""
    @Published private(set) var category = ""
    @Published private(set) var scheduledAt: Date?
    @Published private(set) var address = ""
    @Published private(set) var status = "pending"
    @Published private(set) var issue = ""
    @Published private(set) var customerName = ""
    @Published private(set) var hourlyRate: Double = 0
    @Published private(set) var startedAt: Date?
    @Published private(set) var completedAt: Date?
    @Published private(set) var steps: [TimelineStep] = []
    @Published private(set) var isLoading = false
    @Published private(set) var notFound = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(bookingID: String) {
        self.bookingID = bookingID
    }

 
    var dateTimeText: String {
        guard let scheduledAt else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d, yyyy 'at' hh:mm a"
        return formatter.string(from: scheduledAt)
    }

    
    func stepDateText(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }

    

    var isCompleted: Bool { status == "completed" }

    
    var durationText: String? {
        guard let startedAt, let completedAt, completedAt > startedAt else { return nil }
        let minutes = Int(completedAt.timeIntervalSince(startedAt) / 60)
        let hours = minutes / 60
        let rest = minutes % 60
        if hours == 0 { return "\(max(rest, 1)) min" }
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
    }

  
    func pdfData() -> BookingPDFData {
        BookingPDFData(
            reference: String(bookingID.prefix(8)).uppercased(),
            customerName: customerName,
            workerName: workerName,
            service: category,
            address: address,
            issue: issue,
            scheduledAt: scheduledAt,
            hourlyRate: hourlyRate,
            duration: durationText,
            steps: steps
        )
    }

  

    func start() {
        guard listener == nil else { return }
        isLoading = true

        listener = db.collection("bookings").document(bookingID)
            .addSnapshotListener { [weak self] snapshot, _ in
                let data = snapshot?.data()
                let exists = snapshot?.exists ?? false

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false

                    guard exists, let data else {
                        self.notFound = true
                        return
                    }
                    self.notFound = false
                    self.apply(data)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    private func apply(_ data: [String: Any]) {
        workerName = data["workerName"] as? String ?? "Worker"
        category = data["serviceCategory"] as? String ?? ""
        scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue()
        address = data["address"] as? String ?? ""

        func date(_ key: String) -> Date? { (data[key] as? Timestamp)?.dateValue() }

        status = data["status"] as? String ?? "pending"
        issue = data["issue"] as? String ?? ""
        customerName = data["customerName"] as? String ?? ""
        hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue ?? 0
        startedAt = date("startedAt")
        completedAt = date("completedAt")

        steps = Self.buildSteps(
            status: data["status"] as? String ?? "pending",
            createdAt: date("createdAt"),
            acceptedAt: date("acceptedAt"),
            startedAt: date("startedAt"),
            completedAt: date("completedAt"),
            declinedAt: date("declinedAt"),
            cancelledAt: date("cancelledAt")
        )
    }

    

 
    private static func buildSteps(status: String,
                                   createdAt: Date?,
                                   acceptedAt: Date?,
                                   startedAt: Date?,
                                   completedAt: Date?,
                                   declinedAt: Date?,
                                   cancelledAt: Date?) -> [TimelineStep] {

        let sent = TimelineStep(id: 0, title: "Request Sent", date: createdAt, kind: .done)

        switch status {
        case "declined":
            return [sent, TimelineStep(id: 1, title: "Declined", date: declinedAt, kind: .failed)]
        case "cancelled":
            return [sent, TimelineStep(id: 1, title: "Cancelled", date: cancelledAt, kind: .failed)]
        default:
            break
        }

        
        let rank: Int
        switch status {
        case "accepted": rank = 1
        case "in_progress": rank = 2
        case "completed": rank = 3
        default: rank = 0 
        }

        func kind(_ step: Int) -> TimelineStep.Kind { rank >= step ? .done : .upcoming }

        return [
            sent,
            TimelineStep(id: 1, title: "Accepted", date: rank >= 1 ? acceptedAt : nil, kind: kind(1)),
            TimelineStep(id: 2, title: "In Progress", date: rank >= 2 ? startedAt : nil, kind: kind(2)),
            TimelineStep(id: 3, title: "Completed", date: rank >= 3 ? completedAt : nil, kind: kind(3))
        ]
    }
}
