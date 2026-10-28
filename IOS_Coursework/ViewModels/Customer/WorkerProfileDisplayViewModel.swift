//
//  WorkerProfileDisplayViewModel.swift
//  IOS_Coursework
//
//



import SwiftUI
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Combine



@MainActor
final class WorkerProfileDisplayViewModel: ObservableObject {

    let workerID: String

    @Published private(set) var profile: WorkerProfile?
    @Published private(set) var reviews: [WorkerReview] = []
    @Published private(set) var isFavorite = false
    @Published private(set) var distanceMiles: Double?
  @Published private(set) var distanceIssue: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private let locationManager = LocationService()

    init(workerID: String) {
        self.workerID = workerID
    }

    private var workerRef: DocumentReference {
        db.collection("users").document(workerID)
    }

    
    private var favoriteRef: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
            .collection("favorites").document(workerID)
    }

    

    
    var ratingText: String {
        if let rating = profile?.rating {
            return String(format: "%.1f", rating)
        }
        guard !reviews.isEmpty else { return "New" }
        let average = reviews.map(\.rating).reduce(0, +) / Double(reviews.count)
        return String(format: "%.1f", average)
    }

    var reviewCountText: String {
        let count = profile?.reviewCount ?? reviews.count
        return "\(count) \(count == 1 ? "review" : "reviews")"
    }

    var distanceText: String {
        guard let distanceMiles else { return "--" }
        return String(format: "%.1f mi", distanceMiles)
    }

    
    var experienceText: String {
        guard let experience = profile?.experience, !experience.isEmpty else { return "--" }
        if experience.lowercased().hasPrefix("less") { return "< 1 yr" }
        let first = experience.split(separator: " ").first.map(String.init) ?? experience
        return "\(first) yrs"
    }

    
    var workingDaysText: String {
        let order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let days = (profile?.workingDays ?? [])
        let indexes = days.compactMap { order.firstIndex(of: $0) }.sorted()

        guard let first = indexes.first, let last = indexes.last else { return "Not set" }
        if indexes.count == 7 { return "Every day" }
        if indexes.count == 1 { return order[first] }
        if last - first + 1 == indexes.count { return "\(order[first]) - \(order[last])" }
        return indexes.map { order[$0] }.joined(separator: ", ")
    }

    var workingHoursText: String {
        guard let profile else { return "" }
        return "\(Self.display(profile.startTime)) - \(Self.display(profile.endTime))"
    }

    var hourlyRateText: String? {
        guard let rate = profile?.hourlyRate else { return nil }
        return String(format: "Rs.%.2f / hr", rate)
    }

    private static func display(_ time: String) -> String {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) else { return time }
        let suffix = hour >= 12 ? "PM" : "AM"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%02d:%02d %@", hour12, minute, suffix)
    }

    

    func load() async {
        isLoading = true

        
        do {
            let snapshot = try await workerRef.getDocument()
            guard let data = snapshot.data() else {
                isLoading = false
                show("This worker could not be found.")
                return
            }
            profile = WorkerProfile(id: workerID, data: data)
        } catch {
            isLoading = false
            show("Could not load profile: \(error.localizedDescription)")
            return
        }

        
        if let snapshot = try? await workerRef.collection("reviews")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments() {
            reviews = snapshot.documents.map { WorkerReview(id: $0.documentID, data: $0.data()) }
        }

        
        if let ref = favoriteRef, let snapshot = try? await ref.getDocument() {
            isFavorite = snapshot.exists
        }

  
        isLoading = false

    
        await loadDistance()
    }

    
    private func loadDistance() async {
        distanceIssue = nil

        guard let coordinate = profile?.coordinate else {
            distanceIssue = "This worker has no saved location. The worker must open the "
                + "dashboard and turn Available on (or tap Share Location)."
            print("Distance: \(distanceIssue ?? "")")
            return
        }

        var lastError: Error?

     
        for attempt in 1...2 {
            do {
                let me = try await locationManager.currentLocation()
                let worker = CLLocation(latitude: coordinate.latitude,
                                        longitude: coordinate.longitude)
                distanceMiles = me.distance(from: worker) / 1609.344
                return
            } catch {
                lastError = error
                if error is LocationError { break }
                if attempt == 1 { try? await Task.sleep(nanoseconds: 700_000_000) }
            }
        }

        distanceIssue = (lastError as? LocalizedError)?.errorDescription
            ?? lastError?.localizedDescription
            ?? "Could not get your location."
        print("Distance: \(distanceIssue ?? "")")
    }

    

    func toggleFavorite() async {
        guard let ref = favoriteRef else {
            show("Please log in to save favorites.")
            return
        }

        let newValue = !isFavorite
        isFavorite = newValue

        do {
            if newValue {
                try await ref.setData([
                    "workerId": workerID,
                    "createdAt": FieldValue.serverTimestamp()
                ])
            } else {
                try await ref.delete()
            }
        } catch {
            isFavorite = !newValue
            show("Could not update favorites: \(error.localizedDescription)")
        }
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
