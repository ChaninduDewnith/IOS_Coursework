//
//  FaceIdManager.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import Foundation
import Combine
import LocalAuthentication


@MainActor
final class FaceIDManager: ObservableObject {

    @Published var errorMessage: String?

    
    var isBiometricAvailable: Bool {
        LAContext().canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil
        )
    }

 
    func authenticate(
        reason: String = "Unlock your Workly account",
        allowPasscode: Bool = true
    ) async -> Bool {
        errorMessage = nil

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = allowPasscode
            ? "Use Passcode" : ""

        let policy: LAPolicy = allowPasscode
            ? .deviceOwnerAuthentication
            : .deviceOwnerAuthenticationWithBiometrics

        var policyError: NSError?
        guard context.canEvaluatePolicy(policy, error: &policyError) else {
            errorMessage = message(for: policyError)
            return false
        }

        do {
            return try await context.evaluatePolicy(
                policy,
                localizedReason: reason
            )
        } catch {
          
            if let laError = error as? LAError,
               laError.code == .userCancel ||
               laError.code == .appCancel ||
               laError.code == .systemCancel {
                return false
            }
            errorMessage = message(for: error as NSError)
            return false
        }
    }

    private func message(for error: NSError?) -> String {
        guard let error else { return "Face ID is unavailable." }

        switch LAError.Code(rawValue: error.code) {
        case .biometryNotEnrolled:
            return "Face ID is not set up on this device. Set it up in Settings."
        case .biometryNotAvailable:
            return "Face ID is not available on this device."
        case .biometryLockout:
            return "Face ID is locked. Enter your device passcode to unlock it."
        case .passcodeNotSet:
            return "Set a device passcode in Settings to use Face ID."
        case .authenticationFailed:
            return "Face ID did not recognise you. Please try again."
        default:
            return error.localizedDescription
        }
    }
}
