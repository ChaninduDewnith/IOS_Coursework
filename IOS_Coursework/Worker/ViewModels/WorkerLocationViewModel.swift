//
//  WorkerLocationViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine
internal import _LocationEssentials

@MainActor
final class WorkerLocationViewModel: ObservableObject {

    @Published var isUpdating = false
    @Published var lastUpdated: Date?
    @Published var statusMessage: String?
    @Published var isError = false
    
    @Published var remoteIsAvailable: Bool?

    private let locationManager = LocationManager()
    private let db = Firestore.firestore()


    private var userRef: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
    }


    func loadSavedLocation() async {
        guard let ref = userRef else { return }
        do {
            let data = try await ref.getDocument().data()
            if let timestamp = data?["locationUpdatedAt"] as? Timestamp {
                lastUpdated = timestamp.dateValue()
            }
            remoteIsAvailable = data?["isAvailable"] as? Bool
        } catch {
       
        }
    }

  
    func setAvailable(_ isAvailable: Bool) async -> Bool {
        guard let ref = userRef else {
            show("You must be logged in to change your availability.", error: true)
            return false
        }

        isUpdating = true
        statusMessage = nil
        defer { isUpdating = false }

        var data: [String: Any] = [
            "isAvailable": isAvailable,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        var locationProblem: String?

        if isAvailable {
            do {
                let location = try await locationManager.currentLocation()
                data["location"] = GeoPoint(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
                data["locationUpdatedAt"] = FieldValue.serverTimestamp()
            } catch {
                
                locationProblem = error.localizedDescription
            }
        }

        do {
            try await ref.setData(data, merge: true)
            remoteIsAvailable = isAvailable

            if !isAvailable {
                show("You're offline. Customers won't see you in search.", error: false)
            } else if let problem = locationProblem {
                show("You're available, but your location was not shared. \(problem)", error: true)
            } else {
                lastUpdated = Date()
                show("You're available and your location is shared.", error: false)
            }
            return true
        } catch {
            show("Could not update availability: \(error.localizedDescription)", error: true)
            return false
        }
    }

        func updateLocation() async {
        guard let ref = userRef else {
            show("You must be logged in to update your location.", error: true)
            return
        }

        isUpdating = true
        statusMessage = nil
        defer { isUpdating = false }

        do {
            let location = try await locationManager.currentLocation()

            try await ref.setData([
                "location": GeoPoint(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude),
                "locationUpdatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            lastUpdated = Date()
            show("Location updated. Customers nearby can now find you.", error: false)
        } catch {
            show(error.localizedDescription, error: true)
        }
    }

    private func show(_ message: String, error: Bool) {
        statusMessage = message
        isError = error
    }
}
