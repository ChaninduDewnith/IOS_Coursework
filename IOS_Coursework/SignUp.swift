//
//  SignUp.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//

import SwiftUI

struct CreateAccountView: View {

    @State private var fullName = ""
    @State private var nic = ""
    @State private var address = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var role = "Customer"
    @State private var showPassword = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    
                    HStack(spacing: 10) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Color(red: 0.23, green: 0.49, blue: 0.94)
                            )
                            .cornerRadius(9)

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
                        .foregroundColor(.gray)
                        .padding(.bottom, 28)

                    
                    fieldLabel("Full Name")

                    inputField(
                        icon: "person",
                        placeholder: "Enter your full name",
                        text: $fullName
                    )
                    .padding(.bottom, 18)
                    
                    fieldLabel("NIC Number")

                    HStack(spacing: 12) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(.gray)

                        TextField("Enter your NIC number", text: $nic)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                    .padding(15)
                    .background(fieldColor)
                    .cornerRadius(10)
                    .padding(.bottom, 18)

                    
                    fieldLabel("Address")

                    inputField(
                        icon: "mappin.and.ellipse",
                        placeholder: "Enter your address",
                        text: $address
                    )
                    .padding(.bottom, 18)

                    
                    fieldLabel("Email Address")

                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)

                        TextField("silva@example.com", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(15)
                    .background(fieldColor)
                    .cornerRadius(10)
                    .padding(.bottom, 18)

                    
                    fieldLabel("Phone Number")

                    HStack(spacing: 12) {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)

                        TextField("+94 706533150", text: $phone)
                            .keyboardType(.phonePad)
                    }
                    .padding(15)
                    .background(fieldColor)
                    .cornerRadius(10)
                    .padding(.bottom, 18)

                    
                    fieldLabel("Password")

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

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(
                                systemName: showPassword ? "eye" : "eye.slash"
                            )
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(15)
                    .background(fieldColor)
                    .cornerRadius(10)
                    .padding(.bottom, 22)

                    
                    Text("I want to use Workly as:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.bottom, 12)

                    Picker("Role", selection: $role) {
                        Text("Customer").tag("Customer")
                        Text("Worker").tag("Worker")
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 28)

                    
                    Button {} label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(primaryColor)
                            .cornerRadius(12)
                    }

                    
                    HStack(spacing: 5) {
                        Spacer()

                        Text("Already have an account?")
                            .foregroundColor(.gray)

                        NavigationLink("Log In") {
                            LoginView()
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(primaryColor)

                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.top, 24)

                
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                        Text("Join Workly and connect with trusted professionals")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 26)
                .padding(.top, 28)
                .frame(
                    maxWidth: 500,
                    minHeight: geometry.size.height,
                    alignment: .top
                )
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemBackground))
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
                .foregroundColor(.gray)

            TextField(placeholder, text: text)
        }
        .padding(15)
        .background(fieldColor)
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
