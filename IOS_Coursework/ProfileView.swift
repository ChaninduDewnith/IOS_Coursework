//
//  ProfileView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//

import SwiftUI

struct ProfileView: View {


    var showBackButton = false

    
    @Environment(\.dismiss) var dismiss

    
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName") var userName = "Silva"
    @AppStorage("userEmail") var userEmail = "silva@example.com"
    @AppStorage("userPhone") var userPhone = "+94 706533150"
    @AppStorage("notificationsOn") var notificationsOn = true
    @AppStorage("locationOn") var locationOn = true

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
                    .background(Color(red: 0.23, green: 0.49, blue: 0.94))
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
                    
                } label: {
                    HStack {
                        Text("Edit Profile")
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

        
                NavigationLink {
                    Text("Saved Favorites coming soon")
                } label: {
                    HStack {
                        Text("Saved Favorites")
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

            
                NavigationLink {
                    Text("Booking History coming soon")
                } label: {
                    HStack {
                        Text("Booking History")
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

            
                HStack {
                    Text("Notification Settings")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle("", isOn: $notificationsOn)
                        .labelsHidden()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )

        
                HStack {
                    Text("Location Services")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle("", isOn: $locationOn)
                        .labelsHidden()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )

            
                Button {
                    isLoggedIn = false
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
}





#Preview {
    NavigationStack {
        ProfileView()
    }
}
