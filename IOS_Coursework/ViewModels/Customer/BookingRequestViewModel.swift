//
//  BookingRequestViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-21.
//

import SwiftUI
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Combine



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

@MainActor
final class BookingRequestViewModel: ObservableObject {

    let workerID: String

   
    @Published private(set) var workerName = ""
    @Published private(set) var workerCategory = ""
    @Published private(set) var hourlyRate: Double?
    private var workingDays: [String] = []
    private var startMinutes = 8 * 60
    private var endMinutes = 18 * 60

  
    @Published var selectedDate: Date = BookingRequestViewModel.tomorrow {
        didSet { dropSlotIfUnavailable() }
    }
    @Published var selectedSlot: TimeSlot?
    @Published var address = ""
    @Published var issue = ""

   
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var isLocating = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published private(set) var createdBookingID: String?

    private let db = Firestore.firestore()
    private let locationManager = LocationManager()

   
    private var customerName = ""
    private var customerPhone = ""

    
    private var coordinate: CLLocationCoordinate2D?
    private var coordinateAddress = ""

    init(workerID: String) {
        self.workerID = workerID
    }

    private static var tomorrow: Date {
        let start = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start
    }

   

    var hourlyRateText: String? {
        guard let rate = hourlyRate else { return nil }
        return rate.truncatingRemainder(dividingBy: 1) == 0
            ? "Rs.\(Int(rate))/hr"
            : String(format: "Rs.%.2f/hr", rate)
    }

   
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let base = formatter.string(from: selectedDate)

        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) { return "Today, \(base)" }
        if calendar.isDateInTomorrow(selectedDate) { return "Tomorrow, \(base)" }

        let weekday = DateFormatter()
        weekday.dateFormat = "EEEE"
        return "\(weekday.string(from: selectedDate)), \(base)"
    }

    

    private static let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

 
    var isWorkingDay: Bool {
        guard !workingDays.isEmpty else { return true }
        let weekday = Calendar.current.component(.weekday, from: selectedDate) - 1
        return workingDays.contains(Self.dayNames[weekday])
    }

    var selectedDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }


    var availableSlots: [TimeSlot] {
        guard isWorkingDay else { return [] }

        var slots: [TimeSlot] = []
        var minute = startMinutes
        while minute < endMinutes {
            slots.append(TimeSlot(hour: minute / 60, minute: minute % 60))
            minute += 120
        }

        if Calendar.current.isDateInToday(selectedDate) {
            let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let nowMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
            slots = slots.filter { $0.id > nowMinutes }
        }
        return slots
    }

    private func dropSlotIfUnavailable() {
        if let slot = selectedSlot, !availableSlots.contains(slot) {
            selectedSlot = nil
        }
    }

 

    func load() async {
        
        guard !workerID.isEmpty else {
            show("No worker selected.")
            return
        }

        isLoading = true
        defer { isLoading = false }

      
        do {
            let snapshot = try await db.collection("users").document(workerID).getDocument()
            guard let data = snapshot.data() else {
                show("This worker could not be found.")
                return
            }

            workerName = data["fullName"] as? String ?? "Worker"
            workerCategory = data["serviceCategory"] as? String ?? ""
            hourlyRate = (data["hourlyRate"] as? NSNumber)?.doubleValue

            let availability = data["availability"] as? [String: Any] ?? [:]
            workingDays = availability["workingDays"] as? [String] ?? []
            startMinutes = Self.minutes(availability["startTime"] as? String) ?? startMinutes
            endMinutes = Self.minutes(availability["endTime"] as? String) ?? endMinutes
            objectWillChange.send()
        } catch {
            show("Could not load worker: \(error.localizedDescription)")
            return
        }

        
        if let uid = Auth.auth().currentUser?.uid,
           let data = try? await db.collection("users").document(uid).getDocument().data() {
            customerName = data["fullName"] as? String ?? ""
            customerPhone = data["phone"] as? String ?? ""
            if address.isEmpty {
                address = data["address"] as? String ?? ""
            }
        }
    }

    private static func minutes(_ time: String?) -> Int? {
        guard let parts = time?.split(separator: ":"), parts.count == 2,
              let hour = Int(parts[0]), let minute = Int(parts[1]) else { return nil }
        return hour * 60 + minute
    }

    

    func useCurrentLocation() async {
        isLocating = true
        defer { isLocating = false }

        do {
            let location = try await locationManager.currentLocation()
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)

            var text = ""
            if let place = placemarks.first {
                text = [place.subThoroughfare, place.thoroughfare, place.locality]
                    .compactMap { $0 }
                    .joined(separator: " ")
                if text.isEmpty { text = place.name ?? "" }
            }
            if text.isEmpty {
                text = String(format: "%.5f, %.5f",
                              location.coordinate.latitude, location.coordinate.longitude)
            }

            address = text
            coordinate = location.coordinate
            coordinateAddress = text
        } catch {
            show(error.localizedDescription)
        }
    }


    func submit() async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in to request a service.")
            return false
        }
        guard isWorkingDay else {
            show("\(workerName) doesn't work on \(selectedDayName)s. Please pick another date.")
            return false
        }
        guard let slot = selectedSlot else {
            show("Please choose a time slot.")
            return false
        }

        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAddress.isEmpty else {
            show("Please enter the service location.")
            return false
        }

        let trimmedIssue = issue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedIssue.isEmpty else {
            show("Please describe the issue.")
            return false
        }

        guard let scheduledAt = Calendar.current.date(bySettingHour: slot.hour,
                                                      minute: slot.minute,
                                                      second: 0,
                                                      of: selectedDate),
              scheduledAt > Date() else {
            show("Please choose a time in the future.")
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let dateKey = DateFormatter()
        dateKey.locale = Locale(identifier: "en_US_POSIX")
        dateKey.dateFormat = "yyyy-MM-dd"

        var data: [String: Any] = [
            "customerId": uid,
            "customerName": customerName,
            "customerPhone": customerPhone,
            "workerId": workerID,
            "workerName": workerName,
            "serviceCategory": workerCategory,
            "hourlyRate": hourlyRate ?? 0,
            "scheduledAt": Timestamp(date: scheduledAt),
            "dateKey": dateKey.string(from: selectedDate),
            "timeSlot": slot.label,
            "address": trimmedAddress,
            "issue": trimmedIssue,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

      
        if let coordinate, trimmedAddress == coordinateAddress {
            data["serviceLocation"] = GeoPoint(latitude: coordinate.latitude,
                                               longitude: coordinate.longitude)
        }

        do {
            let ref = try await db.collection("bookings").addDocument(data: data)
            createdBookingID = ref.documentID

            let day = DateFormatter()
            day.locale = Locale(identifier: "en_US")
            day.dateFormat = "MMM d"
            await NotificationService.send(
                to: workerID, type: "new_request",
                title: "New Booking Opportunity",
                message: "\(customerName) requested a \(workerCategory.lowercased()) job on \(day.string(from: scheduledAt)) at \(slot.label).",
                bookingID: ref.documentID)

            showSuccess = true
            return true
        } catch {
            show("Could not send request: \(error.localizedDescription)")
            return false
        }
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
