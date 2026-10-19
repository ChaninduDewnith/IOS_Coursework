//
//  WorkerAvailabilityViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class WorkerAvailabilityViewModel: ObservableObject {

    
    @Published var selectedDays: Set<String> = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    @Published var startTime = WorkerAvailabilityViewModel.date(hour: 8, minute: 0)
    @Published var endTime = WorkerAvailabilityViewModel.date(hour: 18, minute: 0)
    @Published var radiusMiles: Double = 15

    
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showError = false

    let allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private let db = Firestore.firestore()

  
    private var userRef: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
    }

    
    func toggle(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

  
    private static let storageFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "HH:mm"
        return f
    }()

    private static func date(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    
    func loadAvailability() async {
        guard let ref = userRef else {
            show(error: "You must be logged in to edit your availability.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await ref.getDocument()
            guard let availability = snapshot.data()?["availability"] as? [String: Any] else {
                return
            }

            if let days = availability["workingDays"] as? [String] {
                selectedDays = Set(days)
            }
            if let start = availability["startTime"] as? String,
               let date = Self.storageFormatter.date(from: start) {
                startTime = Self.merge(time: date)
            }
            if let end = availability["endTime"] as? String,
               let date = Self.storageFormatter.date(from: end) {
                endTime = Self.merge(time: date)
            }
            if let radius = availability["serviceRadiusMiles"] as? Double {
                radiusMiles = radius
            } else if let radius = availability["serviceRadiusMiles"] as? Int {
                radiusMiles = Double(radius)
            }
        } catch {
            show(error: "Could not load availability: \(error.localizedDescription)")
        }
    }

  
    private static func merge(time: Date) -> Date {
        let c = Calendar.current.dateComponents([.hour, .minute], from: time)
        return date(hour: c.hour ?? 0, minute: c.minute ?? 0)
    }

   
    func saveAvailability() async -> Bool {
        guard let ref = userRef else {
            show(error: "You must be logged in to save your availability.")
            return false
        }
        guard !selectedDays.isEmpty else {
            show(error: "Please select at least one working day.")
            return false
        }

        let start = Self.storageFormatter.string(from: startTime)
        let end = Self.storageFormatter.string(from: endTime)
        guard start < end else {
            show(error: "End time must be after start time.")
            return false
        }

        isSaving = true
        defer { isSaving = false }

     
        let orderedDays = allDays.filter { selectedDays.contains($0) }

        let data: [String: Any] = [
            "availability": [
                "workingDays": orderedDays,
                "startTime": start,
                "endTime": end,
                "serviceRadiusMiles": Int(radiusMiles)
            ],
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            
            try await ref.setData(data, merge: true)
            return true
        } catch {
            show(error: "Could not save availability: \(error.localizedDescription)")
            return false
        }
    }

    private func show(error message: String) {
        errorMessage = message
        showError = true
    }
}
