import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore





@MainActor
final class LoginViewModel: ObservableObject {

  
    private static let enabledKey = "worklyFaceIDEnabled"
    private static let uidKey = "worklyFaceIDUID"

    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var role: UserRole?
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    
    @Published private(set) var isFaceIDEnabled = false
   
    @Published private(set) var canUseFaceID = false

    private let faceID = FaceIDManager()
    private var didAutoPrompt = false

    

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
            let result = try await AuthService.login(
                email: cleanEmail,
                password: password
            )

            role = try await AuthService.fetchRole(uid: result.user.uid)
            refreshFaceIDState()
            isLoggedIn = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

   
    func restoreSession() async {
        guard let user = AuthService.currentUser else {
            refreshFaceIDState()
            return
        }

        refreshFaceIDState()
        if canUseFaceID { return }

        isLoading = true
        defer { isLoading = false }

        do {
            role = try await AuthService.fetchRole(uid: user.uid)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

  
    func loginWithFaceID(automatic: Bool = false) async {
        guard canUseFaceID, !isLoggedIn, !isLoading else { return }

        if automatic {
            guard !didAutoPrompt else { return }
            didAutoPrompt = true
        }

        errorMessage = nil
        infoMessage = nil

        guard let user = AuthService.currentUser else {
            refreshFaceIDState()
            return
        }

        let ok = await faceID.authenticate(
            reason: "Log in to Workly",
            allowPasscode: true
        )

        guard ok else {
            errorMessage = faceID.errorMessage
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            role = try await AuthService.fetchRole(uid: user.uid)
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
            refreshFaceIDState()
        }
    }

   

    func enableFaceID() async {
        errorMessage = nil

        guard let user = AuthService.currentUser else {
            errorMessage = "Please log in with email and password first."
            return
        }

        let ok = await faceID.authenticate(
            reason: "Enable Face ID for Workly",
            allowPasscode: false
        )

        if ok {
            UserDefaults.standard.set(true, forKey: Self.enabledKey)
            UserDefaults.standard.set(user.uid, forKey: Self.uidKey)
        } else {
            errorMessage = faceID.errorMessage ?? "Face ID was not enabled."
        }
        refreshFaceIDState()
    }

    func disableFaceID() {
        UserDefaults.standard.set(false, forKey: Self.enabledKey)
        UserDefaults.standard.removeObject(forKey: Self.uidKey)
        refreshFaceIDState()
    }

   
    func lockWorkly() {
        guard isFaceIDEnabled else { return }
        role = nil
        isLoggedIn = false
        didAutoPrompt = false
        refreshFaceIDState()
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
            infoMessage = "Password reset email sent. Please check your inbox."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

   
    func logout() {
        try? AuthService.logout()
        WidgetStore.clear()
        role = nil
        isLoggedIn = false
        didAutoPrompt = false
        refreshFaceIDState()
    }

   

    private func refreshFaceIDState() {
        let d = UserDefaults.standard
        let uid = AuthService.currentUser?.uid

        isFaceIDEnabled = uid != nil
            && d.bool(forKey: Self.enabledKey)
            && d.string(forKey: Self.uidKey) == uid

        canUseFaceID = isFaceIDEnabled && faceID.isBiometricAvailable
    }
}
