import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine





@MainActor
final class EditProfileViewModel: ObservableObject {

    
    @Published var name = ""
    @Published var category = ""
    @Published var rate = ""
    @Published var experience = "8+ Years Active Service"
    @Published var about = ""

   
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showError = false

    let categories = [
        ServiceCategory(name: "Electrician", icon: "bolt.fill"),
        ServiceCategory(name: "Plumber", icon: "drop.fill"),
        ServiceCategory(name: "Cleaner", icon: "sparkles"),
        ServiceCategory(name: "Painter", icon: "paintbrush.fill"),
        ServiceCategory(name: "Carpenter", icon: "hammer.fill"),
        ServiceCategory(name: "AC Technician", icon: "snowflake")
    ]

    let experienceOptions = [
        "Less than 1 Year",
        "1-3 Years Active Service",
        "3-5 Years Active Service",
        "5-8 Years Active Service",
        "8+ Years Active Service"
    ]

    private let db = Firestore.firestore()

   
    private var userRef: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
    }

    var formattedRate: String {
        String(format: "%.2f", Double(rate) ?? 0)
    }

   
    func loadProfile() async {
        guard let ref = userRef else {
            show(error: "You must be logged in to edit your profile.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await ref.getDocument()

            if let data = snapshot.data() {
                name = data["fullName"] as? String
                    ?? Auth.auth().currentUser?.displayName ?? ""
                category = data["serviceCategory"] as? String ?? ""
                if let hourly = data["hourlyRate"] as? Double {
                    rate = hourly.truncatingRemainder(dividingBy: 1) == 0
                        ? String(Int(hourly)) : String(hourly)
                }
                experience = data["experience"] as? String ?? experience
                about = data["about"] as? String ?? ""
            } else {
               
                name = Auth.auth().currentUser?.displayName ?? ""
            }
        } catch {
            show(error: "Could not load profile: \(error.localizedDescription)")
        }
    }

    
    func saveProfile() async -> Bool {
        guard let ref = userRef else {
            show(error: "You must be logged in to save your profile.")
            return false
        }

        guard !category.isEmpty else {
            show(error: "Please choose your service category.")
            return false
        }

        guard let hourly = Double(rate), hourly > 0 else {
            show(error: "Please enter a valid hourly rate.")
            return false
        }

        isSaving = true
        defer { isSaving = false }

        let data: [String: Any] = [
            "serviceCategory": category,
            "hourlyRate": hourly,
            "experience": experience,
            "about": about.trimmingCharacters(in: .whitespacesAndNewlines),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            
            try await ref.setData(data, merge: true)
            return true
        } catch {
            show(error: "Could not save profile: \(error.localizedDescription)")
            return false
        }
    }

    private func show(error message: String) {
        errorMessage = message
        showError = true
    }
}
