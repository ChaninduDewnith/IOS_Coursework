
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

   

    func login(email: String, password: String) async {
        let cleanEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        errorMessage = nil
        infoMessage = nil

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        guard cleanEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await AuthService.login(
                email: cleanEmail,
                password: password
            )

            isLoggedIn = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

   

    func resetPassword(email: String) async {
        let cleanEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        errorMessage = nil
        infoMessage = nil

        guard !cleanEmail.isEmpty, cleanEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthService.resetPassword(email: cleanEmail)

            infoMessage =
                "Password reset email sent. Please check your inbox."

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


