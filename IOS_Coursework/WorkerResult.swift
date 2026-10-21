//
//  WorkerResult.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import Foundation
import CoreLocation
import FirebaseFirestore

enum WorkerAvailability {
    case available
    case opensToday(String)
    case later(String)
    case unavailable
}


struct WorkerResult: Identifiable {
    let id: String
    let name: String
    let category: String
    let experience: String
    let rating: Double?
    let hourlyRate: Double?
    let coordinate: CLLocationCoordinate2D
    let serviceRadiusMiles: Double?
    let workingDays: [String]
    let startTime: String
    let endTime: String
   
    let isOnline: Bool
    var distanceMiles: Double?

    init?(id: String, data: [String: Any]) {
        guard let geo = data["location"] as? GeoPoint else { return nil }

        let availability = data["availability"] as? [String: Any] ?? [:]

        self.id = id
        self.name = data["fullName"] as? String ?? "Worker"
        self.category = data["serviceCategory"] as? String ?? ""
        self.experience = data["experience"] as? String ?? ""
        self.isOnline = data["isAvailable"] as? Bool ?? true
        self.rating = (data["rating"] as? NSNumber)?.doubleValue
        self.hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue
        self.coordinate = CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude)
        self.serviceRadiusMiles = (availability["serviceRadiusMiles"] as? NSNumber)?.doubleValue
        self.workingDays = availability["workingDays"] as? [String] ?? []
        self.startTime = availability["startTime"] as? String ?? "08:00"
        self.endTime = availability["endTime"] as? String ?? "18:00"
    }

    

    private static let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    func availability(at now: Date = Date()) -> WorkerAvailability {
        guard !workingDays.isEmpty,
              let start = Self.minutes(startTime),
              let end = Self.minutes(endTime) else { return .unavailable }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now) - 1 // 0 = Sun
        let current = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)

        if workingDays.contains(Self.dayNames[weekday]) {
            if current >= start && current < end { return .available }
            if current < start { return .opensToday("Opens \(Self.display(startTime))") }
        }

        
        for offset in 1...7 {
            let index = (weekday + offset) % 7
            if workingDays.contains(Self.dayNames[index]) {
                return .later("Next: \(Self.dayNames[index]) \(Self.display(startTime))")
            }
        }
        return .unavailable
    }

    var isAvailableToday: Bool {
        switch availability() {
        case .available, .opensToday: return true
        default: return false
        }
    }

    var statusText: String {
        switch availability() {
        case .available: return "Available"
        case .opensToday(let text), .later(let text): return text
        case .unavailable: return "Unavailable"
        }
    }

    var isAvailableNow: Bool {
        if case .available = availability() { return true }
        return false
    }


    private static func minutes(_ time: String) -> Int? {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
        return h * 60 + m
    }

    private static func display(_ time: String) -> String {
        guard let total = minutes(time) else { return time }
        let hour = total / 60
        let minute = total % 60
        let suffix = hour >= 12 ? "PM" : "AM"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%d:%02d %@", hour12, minute, suffix)
    }
}
