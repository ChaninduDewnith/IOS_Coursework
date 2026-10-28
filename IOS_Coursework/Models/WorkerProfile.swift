//
//  WorkerProfile.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//

import Foundation
import CoreLocation
import FirebaseFirestore


struct WorkerProfile {
    let id: String
    let name: String
    let category: String
    let about: String
    let experience: String
    let photoURL: URL?
    let rating: Double?
    let reviewCount: Int?
    let hourlyRate: Double?
    let workingDays: [String]
    let startTime: String
    let endTime: String
    let coordinate: CLLocationCoordinate2D?

    init(id: String, data: [String: Any]) {
        let availability = data["availability"] as? [String: Any] ?? [:]

        self.id = id
        self.name = data["fullName"] as? String ?? "Worker"
        self.category = data["serviceCategory"] as? String ?? ""
        self.about = data["about"] as? String ?? ""
        self.experience = data["experience"] as? String ?? ""
        self.photoURL = (data["photoURL"] as? String).flatMap(URL.init(string:))
        self.rating = (data["rating"] as? NSNumber)?.doubleValue
        self.reviewCount = (data["reviewCount"] as? NSNumber)?.intValue
        self.hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue
        self.workingDays = availability["workingDays"] as? [String] ?? []
        self.startTime = availability["startTime"] as? String ?? "08:00"
        self.endTime = availability["endTime"] as? String ?? "18:00"

        if let geo = data["location"] as? GeoPoint {
            self.coordinate = CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude)
        } else {
            self.coordinate = nil
        }
    }
}
