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

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LoginViewModel

    @AppStorage("userName") var userName = "Silva"
    @AppStorage("userEmail") var userEmail = "silva@example.com"
    @AppStorage("userPhone") var userPhone = "+94 706533150"
    @AppStorage("notificationsOn") var notificationsOn = true
    @AppStorage("locationOn") var locationOn = true

    @State private var faceIDMessage: String?
    @State private var isUpdatingFaceID = false

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
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                }

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(brandBlue)
                    .cornerRadius(20)

                VStack(spacing: 3) {
                    Text(userName)
                        .font(.headline)
                    Text(userEmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(userPhone)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)

                NavigationLink {
                    CustomerEditProfileView()
                } label: {
                    profileRow(title: "Edit Profile")
                }
                
              

                NavigationLink {
                    FavoritesView()
                } label: {
                    profileRow(title: "Saved Favorites")
                }

                NavigationLink {
                    BookingHistoryView()
                } label: {
                    profileRow(title: "Booking History")
                }

                faceIDSection

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
        .task { await loadProfile() }
    }


    private func loadProfile() async {
        guard let user = Auth.auth().currentUser else { return }
        userEmail = user.email ?? userEmail

        if let data = try? await Firestore.firestore()
            .collection("users").document(user.uid).getDocument().data() {
            if let name = data["fullName"] as? String, !name.isEmpty { userName = name }
            if let phone = data["phone"] as? String, !phone.isEmpty { userPhone = phone }
            if let email = data["email"] as? String, !email.isEmpty { userEmail = email }
        }
    }

    

   

    private var faceIDSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.title2)
                    .foregroundColor(brandBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Face ID")
                        .font(.footnote)
                        .fontWeight(.medium)

                    Text("Log in to Workly with Face ID")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Toggle(
                    "Enable Face ID",
                    isOn: Binding(
                        get: { viewModel.isFaceIDEnabled },
                        set: { newValue in
                            Task { await setFaceID(newValue) }
                        }
                    )
                )
                .labelsHidden()
                .disabled(isUpdatingFaceID || AuthService.currentUser == nil)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )

            if let message = faceIDMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(viewModel.isFaceIDEnabled ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if viewModel.isFaceIDEnabled {
                Button {
                    viewModel.lockWorkly()
                } label: {
                    Label("Lock Workly with Face ID", systemImage: "lock.fill")
                        .font(.footnote.bold())
                        .foregroundColor(brandBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(brandBlue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
    }

    @MainActor
    private func setFaceID(_ enabled: Bool) async {
        faceIDMessage = nil
        isUpdatingFaceID = true
        defer { isUpdatingFaceID = false }

        if enabled {
            await viewModel.enableFaceID()
            faceIDMessage = viewModel.isFaceIDEnabled
                ? "Face ID enabled. You can now log in with Face ID."
                : (viewModel.errorMessage ?? "Unable to enable Face ID.")
        } else {
            viewModel.disableFaceID()
            faceIDMessage = "Face ID has been disabled."
        }
    }

    private func profileRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.black)
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
