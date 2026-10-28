//
//  WorkerProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//


import SwiftUI
import PhotosUI
import UIKit
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

    @State private var photoItem: PhotosPickerItem?
    @State private var selectedPhoto: UIImage?
    @State private var isSavingPhoto = false
    @State private var photoError: String?

    private let brandBlue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

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

                
                profileHeader

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

              
                toggleRow(
                    title: "Notification Settings",
                    isOn: $notificationsOn
                )

                toggleRow(
                    title: "Location Services",
                    isOn: $locationOn
                )

               
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
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.red.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadProfile()
        }
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                await loadSelectedPhoto(newItem)
            }
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
                            .frame(width: 96, height: 96)
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
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "camera.fill")
                        .font(
                            .system(size: 12, weight: .semibold)
                        )
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(
                                    Color(uiColor: .systemBackground),
                                    lineWidth: 3
                                )
                        }
                }
                .disabled(isSavingPhoto)
            }

            VStack(spacing: 5) {

                Text(userName.isEmpty ? "Worker" : userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if !userEmail.isEmpty {
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                }

                if !userPhone.isEmpty {
                    Text(userPhone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

   

    @MainActor
    private func loadProfile() async {

        guard let user = Auth.auth().currentUser else {
            return
        }

        if let email = user.email {
            userEmail = email
        }

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

        } catch {
            print("Failed to load worker profile: \(error.localizedDescription)")
        }
    }


    @MainActor
    private func loadSelectedPhoto(
        _ item: PhotosPickerItem
    ) async {

        photoError = nil

        guard let user = Auth.auth().currentUser else {
            photoError = "Please log in to update your profile photo."
            return
        }

        isSavingPhoto = true
        defer { isSavingPhoto = false }

        do {
            guard let data = try await item.loadTransferable(
                type: Data.self
            ) else {
                photoError = "Unable to load the selected photo."
                return
            }

            guard let image = UIImage(data: data) else {
                photoError = "The selected image is invalid."
                return
            }

     
            let maxDimension: CGFloat = 500
            let scale = min(
                maxDimension / image.size.width,
                maxDimension / image.size.height,
                1
            )

            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )

            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            guard let compressedData = resizedImage.jpegData(
                compressionQuality: 0.65
            ) else {
                photoError = "Unable to process the selected photo."
                return
            }

            let base64String = compressedData.base64EncodedString()

       
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .setData([
                    "photoBase64": base64String
                ], merge: true)

          
            selectedPhoto = resizedImage
            userPhotoBase64 = base64String

        } catch {
            photoError = "Failed to save photo: \(error.localizedDescription)"
        }
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
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: 1
                )
        }
    }

    

    private func toggleRow(
        title: String,
        isOn: Binding<Bool>
    ) -> some View {

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
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: 1
                )
        }
    }
}



#Preview {
    NavigationStack {
        WorkerProfileView()
            .environmentObject(LoginViewModel())
    }
}

