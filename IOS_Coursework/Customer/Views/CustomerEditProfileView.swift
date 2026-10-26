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

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let fieldColor = Color(red: 0.96, green: 0.96, blue: 0.97)

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 18) {

                    Text(viewModel.initial.isEmpty ? "?" : viewModel.initial)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 8)

                    field("Full Name", icon: "person") {
                        TextField("Your full name", text: $viewModel.fullName)
                            .textContentType(.name)
                    }

                    field("Phone Number", icon: "phone") {
                        TextField("+94 7X XXX XXXX", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }

                    field("Address", icon: "mappin.and.ellipse") {
                        TextField("Your address", text: $viewModel.address, axis: .vertical)
                            .lineLimit(1...3)
                            .textContentType(.fullStreetAddress)
                    }

                    readOnlyField("Email", icon: "envelope", value: viewModel.email)

                    if !viewModel.nic.isEmpty {
                        readOnlyField("NIC", icon: "creditcard", value: viewModel.nic)
                    }

                    Button {
                        Task { await viewModel.save() }
                    } label: {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Text("Save Changes").font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSave ? blue : Color.gray.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .disabled(!canSave)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .task { await viewModel.load() }
        .alert("Profile updated", isPresented: $viewModel.showSaved) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your details have been saved.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
    }

    private var canSave: Bool {
        viewModel.hasChanges && !viewModel.isSaving && !viewModel.isLoading
    }

    

    private var header: some View {
        ZStack {
            Text("Edit Profile").font(.headline)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.black)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func field<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))

            HStack(spacing: 12) {
                Image(systemName: icon).foregroundColor(.gray)
                content()
            }
            .padding(14)
            .background(fieldColor)
            .cornerRadius(12)
        }
    }

    private func readOnlyField(_ title: String, icon: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))

            HStack(spacing: 12) {
                Image(systemName: icon).foregroundColor(.gray)
                Text(value.isEmpty ? "--" : value)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(14)
            .background(fieldColor.opacity(0.6))
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack { CustomerEditProfileView() }
}
