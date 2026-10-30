//
//  WorkerSetup.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-30.
//

import Foundation


enum WorkerSetupStatus {

   
    static let completedKey = "onboardingComplete"


    static func needsSetup(_ data: [String: Any]?) -> Bool {
        guard let data else { return true }

        if data[completedKey] as? Bool == true { return false }

        let category = (data["serviceCategory"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rate = (data["hourlyRate"] as? NSNumber)?.doubleValue ?? 0
        let days = (data["availability"] as? [String: Any])?["workingDays"] as? [String] ?? []

        let profileDone = !category.isEmpty && rate > 0
        let availabilityDone = !days.isEmpty
        return !(profileDone && availabilityDone)
    }
}
