//
//  NotificationService.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import Foundation
import FirebaseFirestore


enum NotificationService {

    static func send(
        to userID: String,
        type: String,
        title: String,
        message: String,
        bookingID: String?
    ) async {
        guard !userID.isEmpty else { return }

        var data: [String: Any] = [
            "type": type,
            "title": title,
            "message": message,
            "isRead": false,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let bookingID { data["bookingId"] = bookingID }

        _ = try? await Firestore.firestore()
            .collection("users").document(userID)
            .collection("notifications")
            .addDocument(data: data)
    }
}
