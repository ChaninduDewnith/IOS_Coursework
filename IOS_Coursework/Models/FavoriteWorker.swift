//
//  FavoriteWorker.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//
import Foundation
struct FavoriteWorker: Identifiable {
    let id: String
    let name: String
    let category: String
    let experience: String
    let rating: Double?
    let reviewCount: Int?
    let hourlyRate: Double?
    let photoURL: URL?
    let isOnline: Bool

    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["fullName"] as? String ?? "Worker"
        self.category = data["serviceCategory"] as? String ?? ""
        self.experience = data["experience"] as? String ?? ""
        self.rating = (data["rating"] as? NSNumber)?.doubleValue
        self.reviewCount = (data["reviewCount"] as? NSNumber)?.intValue
        self.hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue
        self.photoURL = (data["photoURL"] as? String).flatMap(URL.init(string:))
        self.isOnline = data["isAvailable"] as? Bool ?? true
    }
}
