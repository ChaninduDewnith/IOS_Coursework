import Testing
import Foundation
import FirebaseFirestore
@testable import IOS_Coursework

@Suite("WorkerRequest")
struct WorkerRequestTests {

    @Test("Fields and the customer's GPS point are parsed")
    func parsesFieldsAndLocation() throws {
        let when = Date(timeIntervalSince1970: 1_800_000_000)
        let data: [String: Any] = [
            "customerId": "c1", "customerName": "Silva", "serviceCategory": "Plumber",
            "address": "5 Main St", "issue": "Leaking pipe",
            "scheduledAt": Timestamp(date: when),
            "completedAt": Timestamp(date: when.addingTimeInterval(3600)),
            "status": "in_progress",
            "serviceLocation": GeoPoint(latitude: 6.9, longitude: 79.8)
        ]
        let request = WorkerRequest(id: "r1", data: data)

        #expect(request.id == "r1")
        #expect(request.customerId == "c1")
        #expect(request.customerName == "Silva")
        #expect(request.service == "Plumber")
        #expect(request.address == "5 Main St")
        #expect(request.issue == "Leaking pipe")
        #expect(request.status == "in_progress")
        #expect(request.scheduledAt != nil)
        #expect(request.completedAt != nil)
        #expect(abs(try #require(request.latitude) - 6.9) < 0.0001)
        #expect(abs(try #require(request.longitude) - 79.8) < 0.0001)
    }

    @Test("Missing fields use defaults and leave the location empty")
    func defaultsForMissingFields() {
        let request = WorkerRequest(id: "r2", data: [:])

        #expect(request.customerName == "Customer")
        #expect(request.status == "pending")
        #expect(request.latitude == nil)
        #expect(request.longitude == nil)
        #expect(request.scheduledAt == nil)
        #expect(request.completedAt == nil)
    }

    @Test("Two requests are equal only when all their fields match")
    func equatable() {
        let a = WorkerRequest(id: "r1", data: ["status": "pending"])
        let b = WorkerRequest(id: "r1", data: ["status": "pending"])
        let c = WorkerRequest(id: "r1", data: ["status": "accepted"])

        #expect(a == b)
        #expect(a != c)
    }
}