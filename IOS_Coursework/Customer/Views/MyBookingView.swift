//
//  MyBookingView.swift
//  IOS_Coursework
//
//

import SwiftUI

struct MyBookingsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = MyBookingsViewModel()
    @State private var detailsBookingID: String?

    
    var onViewDetails: (BookingItem) -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(onViewDetails: @escaping (BookingItem) -> Void = { _ in }) {
        self.onViewDetails = onViewDetails
    }

    var body: some View {
        VStack(spacing: 16) {

            header

            tabChips

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.bookings) { booking in
                        bookingCard(booking)
                    }

                    if !viewModel.isLoading && viewModel.bookings.isEmpty {
                        Text(viewModel.emptyMessage)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    }
                }
                .padding(.top, 4)
            }
            .overlay {
                if viewModel.isLoading {
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
            if let bookingID = detailsBookingID {
                BookingDetailsView(bookingID: bookingID)
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .alert("Cancel this booking?",
               isPresented: Binding(
                get: { viewModel.bookingToCancel != nil },
                set: { if !$0 { viewModel.bookingToCancel = nil } }
               )) {
            Button("Yes, Cancel", role: .destructive) {
                if let booking = viewModel.bookingToCancel {
                    Task { await viewModel.cancel(booking) }
                }
            }
            Button("Keep Booking", role: .cancel) { }
        } message: {
            if let booking = viewModel.bookingToCancel {
                Text("Your booking with \(booking.workerName) on \(viewModel.dateText(booking)) will be cancelled.")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

 

    private var header: some View {
        ZStack {
            Text("My Bookings")
                .font(.title3)
                .fontWeight(.bold)

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
    }

    private var tabChips: some View {
        HStack(spacing: 10) {
            ForEach(MyBookingsViewModel.Tab.allCases) { item in
                let isSelected = viewModel.tab == item
                Button {
                    viewModel.tab = item
                } label: {
                    Text(item.rawValue)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSelected ? blue : Color.white)
                        .overlay(
                            Capsule().stroke(isSelected ? blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
    }

   

    private func bookingCard(_ booking: BookingItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                statusBadge(booking)
                Spacer()
                Text(viewModel.dateText(booking))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Text(booking.workerName)
                .fontWeight(.bold)

            Text(booking.service)
                .font(.footnote)
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                if booking.canCancel {
                    Button {
                        viewModel.bookingToCancel = booking
                    } label: {
                        Text("Cancel")
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
                    .disabled(viewModel.isCancelling)
                }

                Button {
                    onViewDetails(booking)
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

    private func statusBadge(_ booking: BookingItem) -> some View {
        let text = booking.isConfirmed ? "CONFIRMED" : "PENDING"
        let foreground = booking.isConfirmed
            ? Color(red: 0.05, green: 0.6, blue: 0.4)
            : Color(red: 0.6, green: 0.35, blue: 0.0)
        let background = booking.isConfirmed
            ? Color.green.opacity(0.15)
            : Color.yellow.opacity(0.3)

        return Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .cornerRadius(4)
    }
}
