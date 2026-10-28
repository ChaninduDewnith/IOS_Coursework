//
//  EditProfileViewModel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class CustomerEditProfileViewModel: ObservableObject {

   
    @Published var fullName = ""
    @Published var phone = ""
    @Published var address = ""

    
    @Published private(set) var email = ""
    @Published private(set) var nic = ""

    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var showSaved = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let db = Firestore.firestore()
    private var original = (name: "", phone: "", address: "")

    var initial: String {
        String(fullName.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
    }

   
    var hasChanges: Bool {
        fullName.trimmingCharacters(in: .whitespacesAndNewlines) != original.name
        || phone.trimmingCharacters(in: .whitespacesAndNewlines) != original.phone
        || address.trimmingCharacters(in: .whitespacesAndNewlines) != original.address
    }

   

    func load() async {
        guard let user = Auth.auth().currentUser else {
            show("You must be logged in.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await db.collection("users").document(user.uid)
                .getDocument().data() ?? [:]

            fullName = data["fullName"] as? String ?? ""
            phone = data["phone"] as? String ?? ""
            address = data["address"] as? String ?? ""
            nic = data["nic"] as? String ?? ""
            email = data["email"] as? String ?? user.email ?? ""

            original = (fullName, phone, address)
        } catch {
            show("Could not load your profile: \(error.localizedDescription)")
        }
    }

   

    
    @discardableResult
    func save() async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            show("You must be logged in.")
            return false
        }

        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneText = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let addressText = address.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            show("Please enter your full name.")
            return false
        }

        let digits = phoneText.filter(\.isNumber)
        guard digits.count >= 9, digits.count <= 15 else {
            show("Please enter a valid phone number.")
            return false
        }

        guard !addressText.isEmpty else {
            show("Please enter your address.")
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await db.collection("users").document(uid).setData([
                "fullName": name,
                "phone": phoneText,
                "address": addressText,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            fullName = name
            phone = phoneText
            address = addressText
            original = (name, phoneText, addressText)

            
            UserDefaults.standard.set(name, forKey: "userName")
            UserDefaults.standard.set(phoneText, forKey: "userPhone")

            showSaved = true
            return true
        } catch {
            show("Could not save: \(error.localizedDescription)")
            return false
        }
    }

    private func show(_ message: String) {
        errorMessage = message
        showError = true
    }
}
