import Testing
import Foundation
import FirebaseFirestore
@testable import IOS_Coursework

@Suite("BookingItem")
struct BookingItemTests {

    private func booking(status: String) -> BookingItem {
        BookingItem(id: "b1", data: ["status": status])
    }

    

    @Test("Every field is read from the booking document")
    func parsesAllFields() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let data: [String: Any] = [
            "workerId": "w1", "workerName": "Kamal", "serviceCategory": "Electrician",
            "scheduledAt": Timestamp(date: date), "timeSlot": "10:00 AM",
            "address": "12 Galle Road", "issue": "Short circuit", "hourlyRate": 1500,
            "customerName": "Silva", "reviewed": true, "reviewRating": 4.0,
            "status": "accepted"
        ]
        let item = BookingItem(id: "b1", data: data)

        #expect(item.id == "b1")
        #expect(item.workerId == "w1")
        #expect(item.workerName == "Kamal")
        #expect(item.service == "Electrician")
        #expect(abs((item.scheduledAt?.timeIntervalSince1970 ?? 0) - date.timeIntervalSince1970) < 1)
        #expect(item.timeSlot == "10:00 AM")
        #expect(item.address == "12 Galle Road")
        #expect(item.issue == "Short circuit")
        #expect(item.hourlyRate == 1500)
        #expect(item.customerName == "Silva")
        #expect(item.reviewed)
        #expect(item.reviewRating == 4.0)
        #expect(item.status == "accepted")
    }

    @Test("An empty document still produces a usable booking")
    func defaultsForMissingFields() {
        let item = BookingItem(id: "b2", data: [:])

        #expect(item.workerName == "Worker")
        #expect(item.status == "pending")
        #expect(item.hourlyRate == 0)
        #expect(item.scheduledAt == nil)
        #expect(item.reviewRating == nil)
        #expect(!item.reviewed)
    }

  

    struct StatusCase: Sendable, CustomTestStringConvertible {
        let status: String
        let isPending: Bool
        let isConfirmed: Bool
        let isOngoing: Bool
        let canCancel: Bool
        var testDescription: String { status }
    }

    static let statusCases: [StatusCase] = [
        .init(status: "pending",     isPending: true,  isConfirmed: false, isOngoing: false, canCancel: true),
        .init(status: "accepted",    isPending: false, isConfirmed: true,  isOngoing: false, canCancel: true),
        .init(status: "in_progress", isPending: false, isConfirmed: false, isOngoing: true,  canCancel: false),
        .init(status: "completed",   isPending: false, isConfirmed: false, isOngoing: false, canCancel: false),
        .init(status: "declined",    isPending: false, isConfirmed: false, isOngoing: false, canCancel: false),
        .init(status: "cancelled",   isPending: false, isConfirmed: false, isOngoing: false, canCancel: false)
    ]

    @Test("Status flags match each booking status", arguments: statusCases)
    func statusFlags(for testCase: StatusCase) {
        let item = booking(status: testCase.status)

        #expect(item.isPending == testCase.isPending)
        #expect(item.isConfirmed == testCase.isConfirmed)
        #expect(item.isOngoing == testCase.isOngoing)
        #expect(item.canCancel == testCase.canCancel)
    }

    @Test("An unknown status is treated as none of the active states")
    func unknownStatus() {
        let item = booking(status: "something_else")
        #expect(!item.isPending && !item.isConfirmed && !item.isOngoing && !item.canCancel)
    }
}
