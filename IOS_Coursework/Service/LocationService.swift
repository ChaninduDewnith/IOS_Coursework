//
//  LocationManager.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import Foundation
import CoreLocation
import Combine

enum LocationError: LocalizedError {
    case denied
    case busy

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Location access is turned off. Enable it in Settings > Privacy > Location Services."
        case .busy:
            return "A location request is already in progress."
        }
    }
}


@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var location: CLLocation?

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    
    func currentLocation() async throws -> CLLocation {
        guard continuation == nil else { throw LocationError.busy }

        switch manager.authorizationStatus {
        case .denied, .restricted:
            throw LocationError.denied
        default:
            break
        }

        return try await withCheckedThrowingContinuation { cont in
            continuation = cont
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                manager.requestLocation()
            }
        }
    }

    private func finish(with result: Result<CLLocation, Error>) {
        guard let cont = continuation else { return }
        continuation = nil
        if case .success(let loc) = result { location = loc }
        cont.resume(with: result)
    }

 

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard self.continuation != nil else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            case .denied, .restricted:
                self.finish(with: .failure(LocationError.denied))
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            self.finish(with: .success(latest))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: Error) {
        Task { @MainActor in
            self.finish(with: .failure(error))
        }
    }
}
