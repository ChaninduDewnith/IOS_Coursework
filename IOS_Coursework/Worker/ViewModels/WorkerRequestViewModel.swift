//
//  WorkerRequestViewModel.swift
//  IOS_Coursework
//
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
import Combine



struct WorkerRequest: Identifiable, Equatable {
    let id: String
    let customerName: String
    let service: String
    let address: String
    let issue: String
    let scheduledAt: Date?
    let status: String
    let latitude: Double?
    let longitude: Double?
    let completedAt: Date?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.customerName = data["customerName"] as? String ?? "Customer"
        self.service = data["serviceCategory"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.issue = data["issue"] as? String ?? ""
        self.scheduledAt = (data["scheduledAt"] as? Timestamp)?.dateValue()
        self.completedAt = (data["completedAt"] as? Timestamp)?.dateValue()
        self.status = data["status"] as? String ?? "pending"

        if let geo = data["serviceLocation"] as? GeoPoint {
            self.latitude = geo.latitude
            self.longitude = geo.longitude
        } else {
            self.latitude = nil
            self.longitude = nil
        }
    }
}

@MainActor
final class WorkerRequestsViewModel: ObservableObject {

    @Published private(set) var all: [WorkerRequest] = []
    @Published private(set) var workerName = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isResponding = false
    @Published private(set) var respondingID: String?
    @Published private(set) var workerLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

   
    var newRequests: [WorkerRequest] {
        all.filter { $0.status == "pending" }
            .sorted { ($0.scheduledAt ?? .distantFuture) < ($1.scheduledAt ?? .distantFuture) }
    }

    var pendingCount: Int { newRequests.count }

    var upcomingCount: Int {
        all.filter { $0.status == "accepted" || $0.status == "in_progress" }.count
    }

    var completedCount: Int {
        all.filter { $0.status == "completed" }.count
    }

  

    
    var activeAndUpcomingJobs: [WorkerRequest] {
        all.filter { $0.status == "accepted" || $0.status == "in_progress" }
            .sorted {
                let first = $0.status == "in_progress" ? 0 : 1
                let second = $1.status == "in_progress" ? 0 : 1
                if first != second { return first < second }
                return ($0.scheduledAt ?? .distantFuture) < ($1.scheduledAt ?? .distantFuture)
            }
    }

    
    var completedJobs: [WorkerRequest] {
        all.filter { $0.status == "completed" }
            .sorted {
                ($0.completedAt ?? $0.scheduledAt ?? .distantPast)
                    > ($1.completedAt ?? $1.scheduledAt ?? .distantPast)
            }
    }

  
    func isActive(_ job: WorkerRequest) -> Bool {
        if job.status == "in_progress" { return true }
        guard job.status == "accepted", let date = job.scheduledAt else { return false }
        return Calendar.current.isDateInToday(date)
    }

    

    func start() {
        guard listener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to see your requests.")
            return
        }

        isLoading = true

        listener = db.collection("bookings")
            .whereField("workerId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                let items = snapshot?.documents.map { WorkerRequest(id: $0.documentID, data: $0.data()) }
                let message = error?.localizedDescription

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    if let items {
                        self.all = items
                    } else if let message {
                        self.show("Could not load requests: \(message)")
                    }
                }
            }

        
        Task {
            if let data = try? await db.collection("users").document(uid).getDocument().data() {
                workerName = data["fullName"] as? String ?? ""
                if let geo = data["location"] as? GeoPoint {
                    workerLocation = CLLocation(latitude: geo.latitude, longitude: geo.longitude)
                }
            }
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

  
    func respond(to request: WorkerRequest, accept: Bool) async -> Bool {
        isResponding = true
        respondingID = request.id
        defer {
            isResponding = false
            respondingID = nil
        }

        var update: [String: Any] = ["status": accept ? "accepted" : "declined"]
        update[accept ? "acceptedAt" : "declinedAt"] = FieldValue.serverTimestamp()

        do {
            try await db.collection("bookings").document(request.id).updateData(update)
            return true
        } catch {
            show("Could not update the request: \(error.localizedDescription)")
            return false
        }
    }

    
    func scheduleText(_ request: WorkerRequest) -> String {
        guard let date = request.scheduledAt else { return "--" }

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

  

    func startJob(_ job: WorkerRequest) async -> Bool {
        await updateStatus(job, to: "in_progress", timeField: "startedAt")
    }

    func completeJob(_ job: WorkerRequest) async -> Bool {
        await updateStatus(job, to: "completed", timeField: "completedAt")
    }

    private func updateStatus(_ job: WorkerRequest, to status: String, timeField: String) async -> Bool {
        isResponding = true
        respondingID = job.id
        defer {
            isResponding = false
            respondingID = nil
        }

        do {
            try await db.collection("bookings").document(job.id).updateData([
                "status": status,
                timeField: FieldValue.serverTimestamp()
            ])
            return true
        } catch {
            show("Could not update the job: \(error.localizedDescription)")
            return false
        }
    }

    
    func jobTimeText(_ job: WorkerRequest) -> String {
        if job.status == "completed" {
            return "\(dayText(job.completedAt ?? job.scheduledAt)) • Completed"
        }
        guard let date = job.scheduledAt else { return "--" }

        let time = DateFormatter()
        time.locale = Locale(identifier: "en_US")
        time.dateFormat = "h:mm a"
        return "\(dayText(date)) • \(time.string(from: date))"
    }

    private func dayText(_ date: Date?) -> String {
        guard let date else { return "--" }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let day = DateFormatter()
        day.locale = Locale(identifier: "en_US")
        day.dateFormat = "MMM d"
        return day.string(from: date)
    }

    
    func distanceText(_ request: WorkerRequest) -> String? {
        guard let latitude = request.latitude,
              let longitude = request.longitude,
              let me = workerLocation else { return nil }

        let miles = me.distance(from: CLLocation(latitude: latitude, longitude: longitude)) / 1609.344
        return String(format: "%.1f mi", miles)
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
