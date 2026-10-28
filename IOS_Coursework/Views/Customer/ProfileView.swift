import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import UIKit

struct ProfileView: View {

    var showBackButton = false

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: LoginViewModel

    @AppStorage("userName") private var userName = "Silva"
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("userPhone") private var userPhone = ""
    @AppStorage("userPhotoBase64") private var userPhotoBase64 = ""
    @AppStorage("notificationsOn") private var notificationsOn = true
    @AppStorage("locationOn") private var locationOn = true

    @State private var faceIDMessage: String?
    @State private var isUpdatingFaceID = false

    
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPhoto: UIImage?
    @State private var isSavingPhoto = false
    @State private var photoError: String?

    private let brandBlue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    private let fieldColor = Color(
        red: 0.96,
        green: 0.96,
        blue: 0.97
    )

  

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
                .frame(
                    maxWidth: .infinity,
                    alignment: .top
                )

                VStack(spacing: 16) {

                    sectionHeading("Security & Settings")

                    settingsSection

                    faceIDSection

                    logoutButton
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .top
                )
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
                Label(
                    "Back",
                    systemImage: "chevron.left"
                )
                .font(.headline)
                .foregroundColor(brandBlue)
            }

            Spacer()
        }
    }

    

    private var profileHeader: some View {

        VStack(spacing: 12) {

            ZStack(alignment: .bottomTrailing) {

                Group {

                    if let selectedPhoto {

                        Image(uiImage: selectedPhoto)
                            .resizable()
                            .scaledToFill()

                    } else if
                        let data = Data(
                            base64Encoded: userPhotoBase64
                        ),
                        let image = UIImage(data: data) {

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()

                    } else {

                        Image(systemName: "person.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                            .frame(
                                width: 96,
                                height: 96
                            )
                            .background(brandBlue)
                    }
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(
                            Color(uiColor: .systemBackground),
                            lineWidth: 4
                        )
                }
                .shadow(
                    color: brandBlue.opacity(0.25),
                    radius: 8,
                    y: 4
                )

                
                PhotosPicker(
                    selection: $photoItem,
                    matching: .images
                ) {

                    Image(systemName: "camera.fill")
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Color.black.opacity(0.75)
                        )
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    Color(
                                        uiColor: .systemBackground
                                    ),
                                    lineWidth: 3
                                )
                        }
                }
                .disabled(isSavingPhoto)
            }

            if isSavingPhoto {

                ProgressView("Saving profile photo...")
                    .font(.caption)
            }

            if let photoError {

                Text(photoError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 5) {

                Text(userName.isEmpty ? "User" : userName)
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
        .onChange(of: photoItem) { _, newItem in

            guard let newItem else { return }

            Task {
                await saveProfilePhoto(from: newItem)
            }
        }
    }

    

    @MainActor
    private func saveProfilePhoto(
        from item: PhotosPickerItem
    ) async {

        guard let user = Auth.auth().currentUser else {

            photoError = "Please log in to update your photo."
            return
        }

        isSavingPhoto = true
        photoError = nil

        defer {
            isSavingPhoto = false
        }

        do {

            guard let data = try await item.loadTransferable(
                type: Data.self
            ),
            let image = UIImage(data: data) else {

                photoError = "Unable to load the selected photo."
                return
            }

            
            let maxDimension: CGFloat = 400

            let scale = min(
                maxDimension / image.size.width,
                maxDimension / image.size.height,
                1
            )

            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )

            let renderer = UIGraphicsImageRenderer(
                size: newSize
            )

            let resizedImage = renderer.image { _ in
                image.draw(
                    in: CGRect(
                        origin: .zero,
                        size: newSize
                    )
                )
            }

            
            guard let compressedData = resizedImage.jpegData(
                compressionQuality: 0.5
            ) else {

                photoError = "Unable to process the photo."
                return
            }

            let base64String =
                compressedData.base64EncodedString()

            
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .setData([
                    "photoBase64": base64String
                ], merge: true)

            
            selectedPhoto = resizedImage
            userPhotoBase64 = base64String

         
            photoItem = nil

        } catch {

            photoError =
                "Unable to save photo: \(error.localizedDescription)"
        }
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

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

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
                        get: {
                            viewModel.isFaceIDEnabled
                        },
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
                        viewModel.isFaceIDEnabled
                            ? .green
                            : .secondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
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
                    .background(
                        brandBlue.opacity(0.1)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 1
                )
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
                : (
                    viewModel.errorMessage ??
                    "Unable to enable Face ID."
                )

        } else {

            viewModel.disableFaceID()
            faceIDMessage = "Face ID has been disabled."
        }
    }

    

    private var logoutButton: some View {

        Button {
            viewModel.logout()
        } label: {

            Label(
                "Logout",
                systemImage: "rectangle.portrait.and.arrow.right"
            )
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                Color.red.opacity(0.08)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.red.opacity(0.25),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }

   

    private func sectionHeading(
        _ title: String
    ) -> some View {

        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 1
                )
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
        .background(
            Color(uiColor: .secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 1
                )
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

            if let photo = data["photoBase64"] as? String,
               !photo.isEmpty {

                userPhotoBase64 = photo
            }

           
            if let photoData = Data(
                base64Encoded: userPhotoBase64
            ) {
                selectedPhoto = UIImage(data: photoData)
            }

        } catch {

            print(
                "Unable to load profile: \(error.localizedDescription)"
            )
        }
    }
}



#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(LoginViewModel())
    }
}
