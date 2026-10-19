//
//  WorkerProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI

struct WorkerProfileView: View {

    var showBackButton = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LoginViewModel

    @AppStorage("userName") var userName = "Silva"
    @AppStorage("userEmail") var userEmail = "silva@example.com"
    @AppStorage("userPhone") var userPhone = "+94 706533150"
    @AppStorage("notificationsOn") var notificationsOn = true
    @AppStorage("locationOn") var locationOn = true

    private let brandBlue = Color(red: 0.23, green: 0.49, blue: 0.94)

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
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                }

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(brandBlue)
                    .cornerRadius(20)

                VStack(spacing: 3) {
                    Text(userName)
                        .font(.headline)
                    Text(userEmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(userPhone)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 8)

                NavigationLink {
                    Text("Edit Profile coming soon")
                } label: {
                    profileRow(title: "Edit Profile")
                }

                NavigationLink {
                    Text("Saved Favorites coming soon")
                } label: {
                    profileRow(title: "Saved Favorites")
                }

                NavigationLink {
                    Text("Booking History coming soon")
                } label: {
                    profileRow(title: "Booking History")
                }

                toggleRow(title: "Notification Settings", isOn: $notificationsOn)
                toggleRow(title: "Location Services", isOn: $locationOn)

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
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
    }

 

    private func profileRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
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
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        WorkerProfileView()
    }
    .environmentObject(LoginViewModel())
}
