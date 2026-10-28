//
//  Booking.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//
import Foundation
import FirebaseFirestore

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
    var isOngoing: Bool { status == "in_progress" }
    var canCancel: Bool { isPending || isConfirmed }
}
