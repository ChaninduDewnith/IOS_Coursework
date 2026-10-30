//
//  ProfileBanner.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-30.
//

import SwiftUI


struct ProfileIncompleteBanner: View {

    @StateObject private var viewModel = ProfileReminderViewModel()

   
    @AppStorage("workerSelectedTab") private var selectedTab = 0

    var body: some View {
   
        VStack(spacing: 0) {
            if viewModel.needsSetup {
                Button {
                    selectedTab = 3
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Please update your profile")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Add your service, hourly rate and availability so customers can find and book you.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .animation(.default, value: viewModel.needsSetup)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}

#Preview {
    ProfileIncompleteBanner().padding()
}
