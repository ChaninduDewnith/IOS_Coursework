//
//  BookingSubmittedView.swift
//  IOS_Coursework
//
//

import SwiftUI


struct BookingSubmittedView: View {

    @StateObject private var viewModel: BookingSubmittedViewModel

    var onViewBooking: () -> Void
    var onBackToHome: () -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(bookingID: String,
         onViewBooking: @escaping () -> Void = {},
         onBackToHome: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: BookingSubmittedViewModel(bookingID: bookingID))
        self.onViewBooking = onViewBooking
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
            ZStack {
                Circle()
                    .fill(blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundColor(blue)
            }

            Text("Request Submitted!")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 6)

            detailsCard
                .padding(.top, 26)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onViewBooking()
                } label: {
                    Text("View Booking")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(blue)
                        .cornerRadius(12)
                }

                Button {
                    onBackToHome()
                } label: {
                    Text("Back to Home")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .task { await viewModel.load() }
    }

    private var subtitle: String {
        viewModel.workerName.isEmpty
            ? "Your booking request has been sent."
            : "Your booking request has been sent to \(viewModel.workerName)."
    }

 

    private var detailsCard: some View {
        VStack(spacing: 14) {
            if viewModel.isLoading && viewModel.workerName.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if viewModel.loadFailed {
                Text("Your request was sent, but the details could not be loaded.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                row("WORKER", value: viewModel.workerName)
                row("SERVICE", value: viewModel.service)
                row("DATE & TIME", value: viewModel.dateTimeText)

                HStack {
                    Text("STATUS")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(viewModel.statusText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(viewModel.statusColors.text)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(viewModel.statusColors.background)
                        .cornerRadius(4)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func row(_ title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
    }
}
