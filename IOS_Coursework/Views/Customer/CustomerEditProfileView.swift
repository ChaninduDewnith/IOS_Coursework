//
//  EditProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//


import SwiftUI

struct CustomerEditProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CustomerEditProfileViewModel()

    private let blue = Color(
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
            let isPad = geometry.size.width >= 600

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: isPad ? 22 : 18) {

                        
                        
                        Text(
                            viewModel.initial.isEmpty
                            ? "?"
                            : viewModel.initial
                        )
                        .font(.system(
                            size: isPad ? 42 : 34,
                            weight: .bold
                        ))
                        .foregroundStyle(.white)
                        .frame(
                            width: isPad ? 100 : 80,
                            height: isPad ? 100 : 80
                        )
                        .background(blue)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 22)
                        )
                        .padding(.top, 8)
                        .accessibilityLabel("Profile initial")

                      
                        field("Full Name", icon: "person") {
                            TextField(
                                "Your full name",
                                text: $viewModel.fullName
                            )
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                        }

                        field("Phone Number", icon: "phone") {
                            TextField(
                                "+94 7X XXX XXXX",
                                text: $viewModel.phone
                            )
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                        }

                        field(
                            "Address",
                            icon: "mappin.and.ellipse"
                        ) {
                            TextField(
                                "Your address",
                                text: $viewModel.address,
                                axis: .vertical
                            )
                            .lineLimit(1...3)
                            .textContentType(.fullStreetAddress)
                        }

                   
                        readOnlyField(
                            "Email",
                            icon: "envelope",
                            value: viewModel.email
                        )

                        if !viewModel.nic.isEmpty {
                            readOnlyField(
                                "NIC",
                                icon: "creditcard",
                                value: viewModel.nic
                            )
                        }

                     
                        Button {
                            Task {
                                await viewModel.save()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")

                                    Text("Save Changes")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: isPad ? 56 : 52)
                            .background(
                                canSave
                                ? blue
                                : Color.gray.opacity(0.4)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSave)
                        .padding(.top, 8)
                    }
                    .padding(isPad ? 30 : 20)
                    .frame(maxWidth: isPad ? 600 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .alert(
            "Profile updated",
            isPresented: $viewModel.showSaved
        ) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your details have been saved.")
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                viewModel.errorMessage
                ?? "Something went wrong."
            )
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.08)
                        .ignoresSafeArea()

                    ProgressView("Loading profile...")
                        .padding(24)
                        .background(.regularMaterial)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                }
            }
        }
    }

    private var canSave: Bool {
        viewModel.hasChanges
        && !viewModel.isSaving
        && !viewModel.isLoading
    }



    private var header: some View {
        ZStack {
            Text("Edit Profile")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go back")

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1)
        }
    }

   

    private func field<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(blue)
                    .frame(width: 20)

                content()
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding(14)
            .frame(minHeight: 52)
            .background(fieldColor)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.gray.opacity(0.12),
                        lineWidth: 1
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    

    private func readOnlyField(
        _ title: String,
        icon: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.gray)
                    .frame(width: 20)

                Text(value.isEmpty ? "--" : value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer(minLength: 8)

                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.6))
            }
            .font(.body)
            .padding(14)
            .frame(minHeight: 52)
            .background(fieldColor.opacity(0.65))
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        CustomerEditProfileView()
    }
}
