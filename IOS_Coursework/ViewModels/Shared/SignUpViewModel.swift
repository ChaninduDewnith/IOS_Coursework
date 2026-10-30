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

    

    static let nicLength = 12
    static let phoneLength = 10

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

  
    private func cleanedDigits(_ value: String) -> String? {
        let cleaned = trimmed(value).filter { !$0.isWhitespace && $0 != "-" }
        guard cleaned.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return cleaned
    }

    var isEmailValid: Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed(email).range(of: pattern, options: .regularExpression) != nil
    }

 
    var isNICValid: Bool {
        guard let digits = cleanedDigits(nic) else { return false }
        return digits.count == Self.nicLength
    }

    
    var isPhoneValid: Bool {
        guard let digits = cleanedDigits(phone) else { return false }
        return digits.count == Self.phoneLength
    }

    var isFormValid: Bool {
        !trimmed(fullName).isEmpty &&
        isNICValid &&
        !trimmed(address).isEmpty &&
        isEmailValid &&
        isPhoneValid &&
        password.count >= 6
    }

    

    var nicErrorText: String? {
        guard !trimmed(nic).isEmpty, !isNICValid else { return nil }
        return "NIC must be exactly \(Self.nicLength) digits."
    }

    var phoneErrorText: String? {
        guard !trimmed(phone).isEmpty, !isPhoneValid else { return nil }
        return "Phone number must be exactly \(Self.phoneLength) digits."
    }

   

    func createAccount() async {
        guard isFormValid, !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await AuthService.register(
                fullName: trimmed(fullName),
                nic: cleanedDigits(nic) ?? trimmed(nic),
                address: trimmed(address),
                email: trimmed(email).lowercased(),
                phone: cleanedDigits(phone) ?? trimmed(phone),
                password: password,
                role: role
            )
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
