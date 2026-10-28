//
//  TimeSlot.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//
import Foundation
struct TimeSlot: Identifiable, Hashable {
    let hour: Int
    let minute: Int

    var id: Int { hour * 60 + minute }

    
    var label: String {
        let suffix = hour >= 12 ? "PM" : "AM"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%02d:%02d %@", hour12, minute, suffix)
    }
}
