//
//  NotificationView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-26.
//

import SwiftUI

struct NotificationsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotificationsViewModel()

    private let brandBlue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.isLoading && viewModel.notifications.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else if viewModel.notifications.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.notifications) { item in
                            card(item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    

    private var header: some View {
        ZStack {
            Text("Notifications")
                .font(.headline)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.black)
                }

                Spacer()

                if viewModel.unreadCount > 0 {
                    Button {
                        Task { await viewModel.markAllRead() }
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.title3)
                            .foregroundColor(brandBlue)
                    }
                    .accessibilityLabel("Mark all as read")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    

    private func card(_ item: AppNotification) -> some View {
        Button {
            Task { await viewModel.markRead(item) }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .font(.footnote.bold())
                        .foregroundColor(.black)

                    Spacer(minLength: 8)

                    Text(viewModel.timeText(item.createdAt))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Text(item.message)
                    .font(.caption)
                    .foregroundColor(Color(white: 0.2))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)
            .padding(.leading, 22)
            .padding(.trailing, 14)
            .background(Color.white)
            .overlay(alignment: .topLeading) {
                if !item.isRead {
                    Circle()
                        .fill(brandBlue)
                        .frame(width: 7, height: 7)
                        .padding(.leading, 11)
                        .padding(.top, 18)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        item.isRead ? Color.gray.opacity(0.25) : brandBlue,
                        lineWidth: item.isRead ? 1 : 1.5
                    )
            }
        }
        .buttonStyle(.plain)
    }

    

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text("No notifications yet")
                .font(.subheadline.bold())
            Text("Booking updates will appear here.")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack { NotificationsView() }
}
