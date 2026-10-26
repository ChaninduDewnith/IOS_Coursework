//
//  BookingHistoryView.swift
//  IOS_Coursework
//



import SwiftUI


struct BookingHistoryView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BookingHistoryViewModel()

    @State private var detailsBookingID: String?
    @State private var bookingToRate: BookingItem?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(spacing: 16) {

            header

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.history) { booking in
                        card(booking)
                    }

                    if !viewModel.isLoading && viewModel.history.isEmpty {
                        Text("No past bookings yet.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 60)
                    }
                }
                .padding(.top, 4)
            }
            .overlay {
                if viewModel.isLoading && viewModel.all.isEmpty {
                    ProgressView()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
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
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    

    private var header: some View {
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



    private func card(_ booking: BookingItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    badge(for: booking)

                    Text(booking.workerName)
                        .fontWeight(.bold)

                    Text(booking.service)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(viewModel.dateText(booking))
                        .font(.footnote)
                        .foregroundColor(.gray)

                    if booking.status == "completed" {
                        heart(for: booking)
                    }
                }
            }

            HStack(spacing: 10) {
                if booking.status == "completed" {
                    rateButton(for: booking)
                }

                Button {
                    detailsBookingID = booking.id
                } label: {
                    Text("View Details")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(blue)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func heart(for booking: BookingItem) -> some View {
        let isFavorite = viewModel.isFavorite(booking.workerId)

        return Button {
            Task { await viewModel.toggleFavorite(workerID: booking.workerId) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.footnote)
                .foregroundColor(isFavorite ? .red : .black)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    @ViewBuilder
    private func rateButton(for booking: BookingItem) -> some View {
        if booking.reviewed {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("Rated \(Int(booking.reviewRating ?? 0))")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        } else {
            Button {
                bookingToRate = booking
            } label: {
                Text("Rate this Service")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }



    @ViewBuilder
    private func badge(for booking: BookingItem) -> some View {
        switch booking.status {
        case "completed":
            pill("COMPLETED",
                 text: Color(red: 0.05, green: 0.6, blue: 0.4),
                 background: Color.green.opacity(0.15))
        case "declined":
            pill("DECLINED",
                 text: Color(red: 0.7, green: 0.1, blue: 0.1),
                 background: Color.red.opacity(0.12))
        default: 
            pill("CANCELLED",
                 text: Color(red: 0.6, green: 0.35, blue: 0.0),
                 background: Color.yellow.opacity(0.3))
        }
    }

    private func pill(_ title: String, text: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .cornerRadius(4)
    }
}
