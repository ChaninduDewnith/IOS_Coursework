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
    private let maxContentWidth: CGFloat = 560

    init(
        bookingID: String,
        onViewBooking: @escaping () -> Void = {},
        onBackToHome: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: BookingSubmittedViewModel(bookingID: bookingID)
        )
        self.onViewBooking = onViewBooking
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ScrollView {
                VStack(spacing: 0) {

                    Spacer(minLength: isPad ? 50 : 24)

                    successIcon(size: isPad ? 120 : 100)

                    Text("Request Submitted!")
                        .font(isPad ? .largeTitle : .title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    Text(subtitle)
                        .font(isPad ? .body : .subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, isPad ? 20 : 10)
                        .padding(.top, 8)

                    detailsCard
                        .padding(.top, isPad ? 32 : 26)

                    actionButtons(isPad: isPad)
                        .padding(.top, isPad ? 32 : 26)

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, isPad ? 32 : 20)
            }
            .scrollIndicators(.hidden)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(.systemBackground))
        }
        .task {
            await viewModel.load()
        }
    }

  

    private func successIcon(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(blue.opacity(0.1))
                .frame(width: size, height: size)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: size * 0.46, weight: .regular))
                .foregroundStyle(blue)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Request submitted successfully")
    }

   

    private var subtitle: String {
        viewModel.workerName.isEmpty
            ? "Your booking request has been sent."
            : "Your booking request has been sent to \(viewModel.workerName)."
    }

  

    private var detailsCard: some View {
        VStack(spacing: 16) {

            if viewModel.isLoading && viewModel.workerName.isEmpty {
                ProgressView("Loading booking details...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

            } else if viewModel.loadFailed {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Your request was sent, but the details could not be loaded.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

            } else {
                detailRow("WORKER", value: viewModel.workerName)
                Divider()

                detailRow("SERVICE", value: viewModel.service)
                Divider()

                detailRow("DATE & TIME", value: viewModel.dateTimeText)
                Divider()

                HStack(alignment: .center, spacing: 12) {
                    Text("STATUS")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 8)

                    Text(viewModel.statusText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.statusColors.text)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(viewModel.statusColors.background)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.45))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.22), lineWidth: 1)
        }
    }

    private func detailRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 8)

            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    

    private func actionButtons(isPad: Bool) -> some View {
        VStack(spacing: 12) {

            Button {
                onViewBooking()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text("View Booking")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                onBackToHome()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "house")
                    Text("Back to Home")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: isPad ? 440 : .infinity)
        .frame(maxWidth: .infinity)
    }
}
