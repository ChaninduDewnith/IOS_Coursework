//
//  WorkerRequest.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//

import Foundation
import FirebaseFirestore


struct WorkerRequest: Identifiable, Equatable {
    let id: String
    let customerId: String
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
        self.customerId = data["customerId"] as? String ?? ""
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
