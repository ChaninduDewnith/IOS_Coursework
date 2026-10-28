//
//  BookingHistoryView.swift
//  IOS_Coursework
//




import SwiftUI

struct BookingHistoryView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BookingHistoryViewModel()

    @State private var detailsBookingID: String?
    @State private var bookingToRate: BookingItem?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let maxContentWidth: CGFloat = 1100

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 16) {
                header
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)

                ScrollView {
                    if isPad {
                        LazyVGrid(columns: columns, spacing: 18) {
                            bookingCards
                        }
                    } else {
                        LazyVStack(spacing: 14) {
                            bookingCards
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .overlay {
                    if viewModel.isLoading && viewModel.all.isEmpty {
                        ProgressView("Loading bookings...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.background.opacity(0.8))
                    } else if !viewModel.isLoading && viewModel.history.isEmpty {
                        emptyState
                    }
                }
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .padding(.top, 8)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationDestination(
            isPresented: Binding(
                get: { detailsBookingID != nil },
                set: { if !$0 { detailsBookingID = nil } }
            )
        ) {
            if let id = detailsBookingID {
                BookingDetailsView(bookingID: id)
            }
        }
        .sheet(item: $bookingToRate) { booking in
            RateServiceView(booking: booking, viewModel: viewModel)
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    

    @ViewBuilder
    private var bookingCards: some View {
        ForEach(viewModel.history) { booking in
            card(booking)
        }
    }

  

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Go back")

            Text("Booking History")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()
        }
    }

   

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("No Past Bookings")
                .font(.headline)

            Text("Your completed and cancelled bookings will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    

    private func card(_ booking: BookingItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    badge(for: booking)

                    Text(booking.workerName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(booking.service)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 10) {
                    Text(viewModel.dateText(booking))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)

                    if booking.status == "completed" {
                        heart(for: booking)
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                if booking.status == "completed" {
                    rateButton(for: booking)
                }

                Button {
                    detailsBookingID = booking.id
                } label: {
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.3))
                .strokeBorder(Color.gray.opacity(0.22), lineWidth: 1)
        }
    }

    

    private func heart(for booking: BookingItem) -> some View {
        let isFavorite = viewModel.isFavorite(booking.workerId)

        return Button {
            Task {
                await viewModel.toggleFavorite(workerID: booking.workerId)
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.body)
                .foregroundStyle(isFavorite ? .red : .primary)
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isFavorite ? "Remove worker from favorites" : "Add worker to favorites"
        )
    }

   

    @ViewBuilder
    private func rateButton(for booking: BookingItem) -> some View {
        if booking.reviewed {
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)

                Text("Rated \(Int(booking.reviewRating ?? 0))")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        } else {
            Button {
                bookingToRate = booking
            } label: {
                Text("Rate Service")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(blue.opacity(0.4), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
    }

   

    @ViewBuilder
    private func badge(for booking: BookingItem) -> some View {
        switch booking.status {
        case "completed":
            pill(
                "COMPLETED",
                text: Color(red: 0.05, green: 0.6, blue: 0.4),
                background: Color.green.opacity(0.15)
            )

        case "declined":
            pill(
                "DECLINED",
                text: Color(red: 0.7, green: 0.1, blue: 0.1),
                background: Color.red.opacity(0.12)
            )

        default:
            pill(
                "CANCELLED",
                text: Color(red: 0.6, green: 0.35, blue: 0),
                background: Color.yellow.opacity(0.3)
            )
        }
    }

    private func pill(
        _ title: String,
        text: Color,
        background: Color
    ) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(text)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(Capsule())
            .fixedSize()
    }
}
