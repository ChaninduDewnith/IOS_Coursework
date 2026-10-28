//
//  WidgetShared.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import Foundation
import WidgetKit



enum WidgetShared {
    static let appGroup = "group.nibm.workly"
    static let storeKey = "worklyWidgetSnapshot"
    static let widgetKind = "WorklyWidget"
}


struct WidgetSnapshot: Codable, Equatable {
    var isSignedIn = false
    var role = "customer"
    var name = ""

  
    var nextService: String?
    var nextPerson: String?
    var nextDate: Date?
    var nextStatus: String?

 
    var pendingCount = 0
    var upcomingCount = 0

    var updatedAt = Date()

    static let signedOut = WidgetSnapshot()
    static let preview = WidgetSnapshot(
        isSignedIn: true, role: "customer", name: "Silva",
        nextService: "Electrician", nextPerson: "Kamal Perera",
        nextDate: Date().addingTimeInterval(3600 * 5), nextStatus: "accepted",
        pendingCount: 3, upcomingCount: 2
    )
}

enum WidgetStore {

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: WidgetShared.appGroup)
    }

    static func load() -> WidgetSnapshot {
        guard let data = defaults?.data(forKey: WidgetShared.storeKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else { return .signedOut }
        return snapshot
    }

   
    static func save(_ snapshot: WidgetSnapshot) {
        var new = snapshot
        var old = load()
        new.updatedAt = .distantPast
        old.updatedAt = .distantPast
        guard new != old else { return }

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: WidgetShared.storeKey)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetShared.widgetKind)
    }

    
    static func clear() {
        defaults?.removeObject(forKey: WidgetShared.storeKey)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetShared.widgetKind)
    }
}
