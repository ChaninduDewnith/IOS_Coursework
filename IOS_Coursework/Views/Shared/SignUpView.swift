//
//  SignUpView.swift
//  IOS_Coursework
//


import SwiftUI

struct SignUpView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            Group {
                if isPad {
                    iPadLayout
                } else {
                    iPhoneLayout
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(Color(uiColor: .systemBackground))
        }
        .navigationBarBackButtonHidden(false)
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: {
                    if !$0 {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Account Created", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your Workly account is ready.")
        }
    }

   

    private var iPhoneLayout: some View {
        ScrollView(showsIndicators: false) {
            signUpForm(isPad: false)
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .padding(.bottom, 24)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    

    private var iPadLayout: some View {
        HStack(spacing: 0) {

          
            VStack(spacing: 28) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 130, height: 130)
                    .background(.white.opacity(0.15))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 32)
                    )

                Text("Workly")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)

                Text("Find trusted workers.\nOffer your professional services.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                    .frame(height: 20)

                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")

                    Text("Your next opportunity starts here")
                        .font(.headline)
                }
                .foregroundStyle(.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(40)
            .background(primaryColor)

           
            ScrollView(showsIndicators: false) {
                signUpForm(isPad: true)
                    .padding(.horizontal, 44)
                    .padding(.vertical, 32)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .ignoresSafeArea(edges: .top)
    }

   

    private func signUpForm(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {

         
            HStack(spacing: 10) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(primaryColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )

                Text("Workly")
                    .font(.title2.bold())
            }
            .padding(.bottom, isPad ? 24 : 28)

           
            Text("Create Account")
                .font(
                    .system(
                        size: isPad ? 34 : 28,
                        weight: .bold
                    )
                )
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)

            Text("Join Workly to find or offer trusted services.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, isPad ? 24 : 28)

         
            fieldLabel("Full Name")

            inputField(
                icon: "person",
                placeholder: "Enter your full name",
                text: $viewModel.fullName
            )
            .textContentType(.name)
            .textInputAutocapitalization(.words)
            .padding(.bottom, 18)

            
            fieldLabel("NIC Number")

            inputField(
                icon: "person.text.rectangle",
                placeholder: "Enter your NIC number",
                text: $viewModel.nic
            )
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .padding(.bottom, 18)

          
            fieldLabel("Address")

            inputField(
                icon: "mappin.and.ellipse",
                placeholder: "Enter your address",
                text: $viewModel.address
            )
            .textContentType(.fullStreetAddress)
            .padding(.bottom, 18)

        
            fieldLabel("Email Address")

            inputField(
                icon: "envelope",
                placeholder: "silva@example.com",
                text: $viewModel.email
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.bottom, 18)

          
            fieldLabel("Phone Number")

            inputField(
                icon: "phone",
                placeholder: "+94 706533150",
                text: $viewModel.phone
            )
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .padding(.bottom, 18)

           
            fieldLabel("Password")

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)

                Group {
                    if viewModel.showPassword {
                        TextField(
                            "At least 6 characters",
                            text: $viewModel.password
                        )
                    } else {
                        SecureField(
                            "At least 6 characters",
                            text: $viewModel.password
                        )
                    }
                }
                .textContentType(.newPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    viewModel.showPassword.toggle()
                } label: {
                    Image(
                        systemName: viewModel.showPassword
                            ? "eye"
                            : "eye.slash"
                    )
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    viewModel.showPassword
                        ? "Hide password"
                        : "Show password"
                )
            }
            .padding(15)
            .frame(minHeight: 54)
            .background(fieldColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 22)

          
            Text("I want to use Workly as:")
                .font(.subheadline.weight(.medium))
                .padding(.bottom, 12)

            Picker("Role", selection: $viewModel.role) {
                Text("Customer")
                    .tag(UserRole.customer)

                Text("Worker")
                    .tag(UserRole.worker)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 28)

           
            Button {
                Task {
                    await viewModel.createAccount()
                }
            } label: {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .background(
                    primaryColor.opacity(
                        viewModel.isFormValid ? 1 : 0.5
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(
                viewModel.isLoading || !viewModel.isFormValid
            )

      
            HStack(spacing: 5) {
                Spacer()

                Text("Already have an account?")
                    .foregroundStyle(.secondary)

                Button("Log In") {
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundStyle(primaryColor)

                Spacer()
            }
            .font(.subheadline)
            .padding(.top, 24)

         
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "lock.shield")

                Text(
                    "Join Workly and connect with trusted professionals"
                )
                .fixedSize(horizontal: false, vertical: true)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 28)
            .padding(.bottom, 16)
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
            .font(.subheadline.weight(.medium))
            .padding(.bottom, 10)
    }

    

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            TextField(placeholder, text: text)
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 54)
        .background(fieldColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
