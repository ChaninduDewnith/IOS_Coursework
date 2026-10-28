//
//  WorkerProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//





import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct WorkerProfileView: View {

    var showBackButton = false

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: LoginViewModel

    @AppStorage("userName") private var userName = ""
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("userPhotoBase64") private var userPhotoBase64 = ""
    @AppStorage("notificationsOn") private var notificationsOn = true
    @AppStorage("locationOn") private var locationOn = true

    private let brandBlue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                if showBackButton {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    }
                }

                AvatarView(base64: userPhotoBase64, name: userName, size: 80)

                VStack(spacing: 3) {
                    Text(userName.isEmpty ? "Worker" : userName)
                        .font(.headline)
                    if !userEmail.isEmpty {
                        Text(userEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if !userPhone.isEmpty {
                        Text(userPhone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                NavigationLink {
                    WorkerEditProfileView()
                } label: {
                    profileRow(title: "Edit Profile")
                }

                NavigationLink {
                    WorkerAvailabilityView()
                } label: {
                    profileRow(title: "Set Availability")
                }

                toggleRow(title: "Notification Settings", isOn: $notificationsOn)
                toggleRow(title: "Location Services", isOn: $locationOn)

                Button {
                    viewModel.logout()
                } label: {
                    Text("Logout")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task { await loadProfile() }
        }
    }

   
    @MainActor
    private func loadProfile() async {
        guard let user = Auth.auth().currentUser else { return }

        if let email = user.email { userEmail = email }

        guard let data = try? await Firestore.firestore()
            .collection("users").document(user.uid)
            .getDocument().data() else { return }

        if let name = data["fullName"] as? String, !name.isEmpty { userName = name }
        if let phone = data["phone"] as? String, !phone.isEmpty { userPhone = phone }
        if let email = data["email"] as? String, !email.isEmpty { userEmail = email }
        userPhotoBase64 = data["photoBase64"] as? String ?? ""
    }

   

    private func profileRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        WorkerProfileView()
    }
    .environmentObject(LoginViewModel())
}
