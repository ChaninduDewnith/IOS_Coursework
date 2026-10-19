import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthService {

  

    static func login(
        email: String,
        password: String
    ) async throws -> AuthDataResult {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

   

   
    static func register(
        fullName: String,
        nic: String,
        address: String,
        email: String,
        phone: String,
        password: String,
        role: String
    ) async throws {

        let result = try await createAuthUser(email: email, password: password)

        let data: [String: Any] = [
            "fullName": fullName,
            "nic": nic,
            "address": address,
            "email": email,
            "phone": phone,
            "role": role,
            "createdAt": FieldValue.serverTimestamp()
        ]

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(result.user.uid)
                .setData(data)
        } catch {
            
            try? await result.user.delete()
            throw error
        }
    }

    

    static func createAccount(
        email: String,
        password: String
    ) async throws -> AuthDataResult {
        try await createAuthUser(email: email, password: password)
    }

    private static func createAuthUser(
        email: String,
        password: String
    ) async throws -> AuthDataResult {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    

    static func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

   

    static func logout() throws {
        try Auth.auth().signOut()
    }

    

    static var currentUser: User? {
        Auth.auth().currentUser
    }


    static var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
}
