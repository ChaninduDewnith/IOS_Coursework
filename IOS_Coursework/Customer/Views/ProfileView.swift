//
//  ProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//





import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {

    var showBackButton = false

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: LoginViewModel

    @AppStorage("userName") private var userName = "Silva"
    @AppStorage("userEmail") private var userEmail = "silva@example.com"
    @AppStorage("userPhone") private var userPhone = "+94 706533150"
    @AppStorage("notificationsOn") private var notificationsOn = true
    @AppStorage("locationOn") private var locationOn = true

    @State private var faceIDMessage: String?
    @State private var isUpdatingFaceID = false

    private let brandBlue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let fieldColor = Color(red: 0.96, green: 0.96, blue: 0.97)

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ScrollView {
                VStack(spacing: isPad ? 28 : 18) {

                    if showBackButton {
                        backButton
                    }

                    if isPad {
                        iPadProfileLayout
                    } else {
                        iPhoneProfileLayout
                    }
                }
                .padding(isPad ? 32 : 20)
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemBackground))
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadProfile()
        }
    }

    

    private var iPhoneProfileLayout: some View {
        VStack(spacing: 18) {
            profileHeader

            profileLinks

            settingsSection

            faceIDSection

            logoutButton
        }
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity)
    }

    

    private var iPadProfileLayout: some View {
        VStack(spacing: 28) {
            profileHeader

            HStack(alignment: .top, spacing: 24) {

                VStack(spacing: 16) {
                    sectionHeading("Account")

                    profileLinks
                }
                .frame(maxWidth: .infinity, alignment: .top)

                VStack(spacing: 16) {
                    sectionHeading("Security & Settings")

                    settingsSection

                    faceIDSection

                    logoutButton
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: 1000)
        .frame(maxWidth: .infinity)
    }



    private var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.headline)
                    .foregroundColor(brandBlue)
            }

            Spacer()
        }
    }

 

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.fill")
                .font(.system(size: 38))
                .foregroundColor(.white)
                .frame(width: 90, height: 90)
                .background(brandBlue)
                .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack(spacing: 5) {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .textSelection(.enabled)

                Text(userPhone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }



    private var profileLinks: some View {
        VStack(spacing: 12) {
            NavigationLink {
                CustomerEditProfileView()
            } label: {
                profileRow(
                    title: "Edit Profile",
                    icon: "person.crop.circle"
                )
            }

            NavigationLink {
                FavoritesView()
            } label: {
                profileRow(
                    title: "Saved Favorites",
                    icon: "heart"
                )
            }

            NavigationLink {
                BookingHistoryView()
            } label: {
                profileRow(
                    title: "Booking History",
                    icon: "clock.arrow.circlepath"
                )
            }
        }
        .buttonStyle(.plain)
    }

  

    private var settingsSection: some View {
        VStack(spacing: 12) {
            toggleRow(
                title: "Notification Settings",
                icon: "bell",
                isOn: $notificationsOn
            )

            toggleRow(
                title: "Location Services",
                icon: "location",
                isOn: $locationOn
            )
        }
    }

    

    private var faceIDSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.title2)
                    .foregroundColor(brandBlue)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Face ID")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Log in to Workly with Face ID.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 8)

                Toggle(
                    "Enable Face ID",
                    isOn: Binding(
                        get: { viewModel.isFaceIDEnabled },
                        set: { newValue in
                            Task {
                                await setFaceID(newValue)
                            }
                        }
                    )
                )
                .labelsHidden()
                .disabled(
                    isUpdatingFaceID ||
                    AuthService.currentUser == nil
                )
            }

            if isUpdatingFaceID {
                ProgressView("Updating Face ID...")
                    .font(.caption)
            }

            if let message = faceIDMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(
                        viewModel.isFaceIDEnabled ? .green : .secondary
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }

            if viewModel.isFaceIDEnabled {
                Button {
                    viewModel.lockWorkly()
                } label: {
                    Label(
                        "Lock Workly with Face ID",
                        systemImage: "lock.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(brandBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(brandBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

    @MainActor
    private func setFaceID(_ enabled: Bool) async {
        faceIDMessage = nil
        isUpdatingFaceID = true

        defer {
            isUpdatingFaceID = false
        }

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

    

    private var logoutButton: some View {
        Button {
            viewModel.logout()
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.25), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func profileRow(
        title: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(brandBlue)
                .frame(width: 28)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
        .contentShape(Rectangle())
    }

    private func toggleRow(
        title: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(brandBlue)
                .frame(width: 28)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer(minLength: 8)

            Toggle(title, isOn: isOn)
                .labelsHidden()
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

    

    @MainActor
    private func loadProfile() async {
        guard let user = Auth.auth().currentUser else {
            return
        }

        userEmail = user.email ?? userEmail

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .getDocument()

            guard let data = snapshot.data() else {
                return
            }

            if let name = data["fullName"] as? String,
               !name.isEmpty {
                userName = name
            }

            if let phone = data["phone"] as? String,
               !phone.isEmpty {
                userPhone = phone
            }

            if let email = data["email"] as? String,
               !email.isEmpty {
                userEmail = email
            }
        } catch {
            
            print("Unable to load profile: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(LoginViewModel())
    }
}
