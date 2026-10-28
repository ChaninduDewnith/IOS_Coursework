
import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showResetAlert = false

    @ObservedObject var viewModel: LoginViewModel

    private let primaryColor = Color(
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
        NavigationStack {
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
            .toolbar(.hidden, for: .navigationBar)
            .alert(
                "Reset Password",
                isPresented: $showResetAlert
            ) {
                Button("Cancel", role: .cancel) {}

                Button("Send Email") {
                    Task {
                        await viewModel.resetPassword(email: email)
                    }
                }
            } message: {
                Text(
                    "A password reset link will be sent to the email address entered above."
                )
            }
        }
    }

   

    private var iPhoneLayout: some View {
        ScrollView(showsIndicators: false) {
            loginForm(isPad: false)
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .padding(.bottom, 24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
        }
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

                Text("Find trusted workers.\nBook services with confidence.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
                    .frame(height: 20)

                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")

                    Text("Reliable services, made simple")
                        .font(.headline)
                }
                .foregroundStyle(.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(40)
            .background(primaryColor)

            
            ScrollView(showsIndicators: false) {
                loginForm(isPad: true)
                    .padding(.horizontal, 56)
                    .padding(.vertical, 40)
                    .frame(maxWidth: 620)
                    .frame(maxWidth: .infinity)
                    .frame(
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .ignoresSafeArea(edges: .top)
    }

    
    private func loginForm(isPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {

           
            HStack(spacing: 10) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(primaryColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 11)
                    )

                Text("Workly")
                    .font(.title2.bold())
            }
            .padding(.bottom, isPad ? 28 : 30)

           
            Text("Welcome to Workly")
                .font(
                    .system(
                        size: isPad ? 36 : 28,
                        weight: .bold
                    )
                )
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 8)

            Text("Log in to find and book trusted workers.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, isPad ? 30 : 28)

           
            Text("Email Address")
                .font(.subheadline.weight(.medium))
                .padding(.bottom, 10)

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)

                TextField(
                    "silva@example.com",
                    text: $email
                )
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 54)
            .background(fieldColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 22)

           
            Text("Password")
                .font(.subheadline.weight(.medium))
                .padding(.bottom, 10)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)

                Group {
                    if showPassword {
                        TextField(
                            "Enter your password",
                            text: $password
                        )
                    } else {
                        SecureField(
                            "Enter your password",
                            text: $password
                        )
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    showPassword.toggle()
                } label: {
                    Image(
                        systemName: showPassword
                            ? "eye"
                            : "eye.slash"
                    )
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    showPassword ? "Hide password" : "Show password"
                )
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 54)
            .background(fieldColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            
            HStack {
                Spacer()

                Button("Forgot Password?") {
                    showResetAlert = true
                }
                .font(.subheadline)
                .foregroundStyle(primaryColor)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)

            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 12)
            }

           
            if let info = viewModel.infoMessage {
                Text(info)
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 12)
            }

           
            Button {
                Task {
                    await viewModel.login(
                        email: email,
                        password: password
                    )
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Log In")
                            .font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)

            
            if viewModel.canUseFaceID {
                HStack(spacing: 14) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)

                    Text("OR")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(height: 1)
                }
                .padding(.vertical, 24)

                Button {
                    Task {
                        await viewModel.loginWithFaceID()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.title3)

                        Text("Log in with Face ID")
                            .font(.headline)
                    }
                    .foregroundStyle(primaryColor)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 54)
                    .background(primaryColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                primaryColor.opacity(0.35),
                                lineWidth: 1
                            )
                    }
                }
                .disabled(viewModel.isLoading)
            }

            
            HStack(spacing: 5) {
                Spacer()

                Text("Don't have an account?")
                    .foregroundStyle(.secondary)

                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundStyle(primaryColor)
                }

                Spacer()
            }
            .font(.footnote)
            .padding(.top, 28)
            .padding(.bottom, 24)

            
            HStack(spacing: 6) {
                Image(systemName: "lock.shield")

                Text("Secure login to your Workly account")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

