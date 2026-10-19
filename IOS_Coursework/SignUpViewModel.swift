import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {

    @Published var fullName = ""
    @Published var nic = ""
    @Published var address = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var role: UserRole = .customer
    @Published var showPassword = false

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isEmailValid: Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed(email).range(of: pattern, options: .regularExpression) != nil
    }

    var isPhoneValid: Bool {
        let digits = trimmed(phone).filter(\.isNumber)
        return digits.count >= 9 && digits.count <= 15
    }

    var isFormValid: Bool {
        !trimmed(fullName).isEmpty &&
        !trimmed(nic).isEmpty &&
        !trimmed(address).isEmpty &&
        isEmailValid &&
        isPhoneValid &&
        password.count >= 6
    }

    func createAccount() async {
        guard isFormValid, !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthService.register(
                fullName: trimmed(fullName),
                nic: trimmed(nic).uppercased(),
                address: trimmed(address),
                email: trimmed(email).lowercased(),
                phone: trimmed(phone),
                password: password,
                role: role                      
            )
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
