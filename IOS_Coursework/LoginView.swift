
import SwiftUI

struct LoginView: View {

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    @StateObject private var viewModel = LoginViewModel()

    @State private var showResetAlert = false

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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                       HStack(spacing: 10) {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(primaryColor)
                                .cornerRadius(9)

                            Text("Workly")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 32)
                            Text("Welcome to Workly")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.bottom, 8)

                        Text("Log in to find and book trusted workers.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)
                         Text("Email Address")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.bottom, 10)

                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)

                            TextField("silva@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding(16)
                        .background(fieldColor)
                        .cornerRadius(12)
                        .padding(.bottom, 22)

                        

                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.bottom, 10)

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)

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
                                .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(fieldColor)
                        .cornerRadius(12)

                        

                        HStack {
                            Spacer()

                            Button("Forgot Password?") {
                                showResetAlert = true
                            }
                            .font(.subheadline)
                            .foregroundColor(primaryColor)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                     

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.bottom, 12)
                        }

                        if let info = viewModel.infoMessage {
                            Text(info)
                                .font(.footnote)
                                .foregroundColor(.green)
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
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(primaryColor)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading)

                       

                        NavigationLink(
                            destination: MainTabView(),
                            isActive: $viewModel.isLoggedIn
                        ) {
                            EmptyView()
                        }
                        .hidden()

           

                        HStack(spacing: 14) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(height: 1)

                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Rectangle()
                                .fill(Color.gray.opacity(0.25))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 28)

                   

                        HStack(spacing: 5) {
                            Spacer()

                            Text("Don't have an account?")
                                .foregroundColor(.gray)

                            NavigationLink {
                                SignUpView()
                            } label: {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(primaryColor)
                            }

                            Spacer()
                        }
                        .font(.footnote)

                        Spacer(minLength: 25)

                        

                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield")

                            Text("Secure login to your Workly account")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    .frame(
                        maxWidth: 500,
                        minHeight: geometry.size.height,
                        alignment: .top
                    )
                    .frame(maxWidth: .infinity)
                }
                .background(Color(uiColor: .systemBackground))
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert("Reset Password", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}

                Button("Send Email") {
                    Task {
                        await viewModel.resetPassword(email: email)
                    }
                }
            } message: {
                Text("A password reset link will be sent to the email address entered above.")
            }
        }
    }
}

#Preview {
    LoginView()
}

