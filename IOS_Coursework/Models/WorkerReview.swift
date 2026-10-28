//
//  WorkerReviews.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//

import Foundation
import FirebaseFirestore


struct WorkerReview: Identifiable {
    let id: String
    let customerName: String
    let rating: Double
    let comment: String
    let createdAt: Date?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.customerName = data["customerName"] as? String ?? "Customer"
        self.rating = (data["rating"] as? NSNumber)?.doubleValue ?? 0
        self.comment = data["comment"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
    }
}
