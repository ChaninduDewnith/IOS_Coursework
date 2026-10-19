//
//  SignUpView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI

struct SignUpView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    HStack(spacing: 10) {
                        Image(systemName: "briefcase.fill")
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(primaryColor)
                            .clipShape(RoundedRectangle(cornerRadius: 9))

                        Text("Workly")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 28)

                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 8)

                    Text("Join Workly to find or offer trusted services.")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 28)

                    fieldLabel("Full Name")
                    inputField(icon: "person",
                               placeholder: "Enter your full name",
                               text: $viewModel.fullName)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .padding(.bottom, 18)

                    fieldLabel("NIC Number")
                    inputField(icon: "person.text.rectangle",
                               placeholder: "Enter your NIC number",
                               text: $viewModel.nic)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(.bottom, 18)

                    fieldLabel("Address")
                    inputField(icon: "mappin.and.ellipse",
                               placeholder: "Enter your address",
                               text: $viewModel.address)
                        .textContentType(.fullStreetAddress)
                        .padding(.bottom, 18)

                    fieldLabel("Email Address")
                    inputField(icon: "envelope",
                               placeholder: "silva@example.com",
                               text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.bottom, 18)

                    fieldLabel("Phone Number")
                    inputField(icon: "phone",
                               placeholder: "+94 706533150",
                               text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(.bottom, 18)

                    fieldLabel("Password")
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundStyle(.gray)

                        Group {
                            if viewModel.showPassword {
                                TextField("At least 6 characters", text: $viewModel.password)
                            } else {
                                SecureField("At least 6 characters", text: $viewModel.password)
                            }
                        }
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        Button {
                            viewModel.showPassword.toggle()
                        } label: {
                            Image(systemName: viewModel.showPassword ? "eye" : "eye.slash")
                                .foregroundStyle(.gray)
                        }
                        .accessibilityLabel(viewModel.showPassword ? "Hide password" : "Show password")
                    }
                    .padding(15)
                    .background(fieldColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 22)

                    Text("I want to use Workly as:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.bottom, 12)

                    Picker("Role", selection: $viewModel.role) {
                        Text("Customer").tag("Customer")
                        Text("Worker").tag("Worker")
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 28)

                    Button {
                        Task { await viewModel.createAccount() }
                    } label: {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(primaryColor.opacity(viewModel.isFormValid ? 1 : 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)

                    HStack(spacing: 5) {
                        Spacer()

                        Text("Already have an account?")
                            .foregroundStyle(.gray)

                        NavigationLink("Log In") {
                            LoginView()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryColor)

                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.top, 24)

                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                        Text("Join Workly and connect with trusted professionals")
                    }
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .frame(maxWidth: 500,
                       minHeight: geometry.size.height,
                       alignment: .top)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Account Created", isPresented: $viewModel.showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your Workly account is ready.")
        }
    }

    
    private var primaryColor: Color {
        Color(red: 0.23, green: 0.49, blue: 0.94)
    }

    private var fieldColor: Color {
        Color(red: 0.96, green: 0.96, blue: 0.97)
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.bottom, 10)
    }

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.gray)

            TextField(placeholder, text: text)
        }
        .padding(15)
        .background(fieldColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
