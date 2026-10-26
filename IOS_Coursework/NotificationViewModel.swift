//
//  NotificationViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

struct AppNotification: Identifiable, Equatable {
    let id: String
    let title: String
    let message: String
    let createdAt: Date
    var isRead: Bool
    let bookingID: String?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? "Notification"
        self.message = data["message"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.isRead = data["isRead"] as? Bool ?? false
        self.bookingID = data["bookingId"] as? String
    }
}

@MainActor
final class NotificationsViewModel: ObservableObject {

    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var isLoading = false

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var collection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("notifications")
    }

    func start() {
        guard listener == nil, let collection else { return }
        isLoading = true

        listener = collection
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, _ in
                let items = snapshot?.documents.map {
                    AppNotification(id: $0.documentID, data: $0.data())
                } ?? []
                Task { @MainActor in
                    self?.notifications = items
                    self?.isLoading = false
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    func markRead(_ notification: AppNotification) async {
        guard !notification.isRead, let collection else { return }

        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
        try? await collection.document(notification.id).updateData(["isRead": true])
    }

    func markAllRead() async {
        guard let collection else { return }
        let unread = notifications.filter { !$0.isRead }
        guard !unread.isEmpty else { return }

        for index in notifications.indices { notifications[index].isRead = true }

        let batch = db.batch()
        for item in unread {
            batch.updateData(["isRead": true], forDocument: collection.document(item.id))
        }
        try? await batch.commit()
    }

   
    func timeText(_ date: Date) -> String {
        let seconds = max(0, Int(Date().timeIntervalSince(date)))
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24

        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes) min\(minutes == 1 ? "" : "s") ago" }
        if hours < 24 { return "\(hours) hour\(hours == 1 ? "" : "s") ago" }
        if days < 7 { return "\(days) day\(days == 1 ? "" : "s") ago" }

        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
