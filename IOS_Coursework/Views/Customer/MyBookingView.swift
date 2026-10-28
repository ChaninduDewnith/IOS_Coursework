import SwiftUI

struct MyBookingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    @StateObject private var viewModel = MyBookingsViewModel()
    @State private var detailsBookingID: String?

    var onViewDetails: (BookingItem) -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let fieldColor = Color(.secondarySystemBackground)

    init(onViewDetails: @escaping (BookingItem) -> Void = { _ in }) {
        self.onViewDetails = onViewDetails
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: isPad ? 24 : 18) {

                header(isPad: isPad)

                tabChips(isPad: isPad)

                if !viewModel.isLoading && viewModel.bookings.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: bookingColumns(isPad: isPad),
                            alignment: .leading,
                            spacing: 16
                        ) {
                            ForEach(viewModel.bookings) { booking in
                                bookingCard(booking, isPad: isPad)
                            }
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                        .frame(maxWidth: 1100)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .overlay {
                        if viewModel.isLoading {
                            ProgressView("Loading bookings...")
                        }
                    }
                }
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .padding(.top, isPad ? 20 : 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .alert(
            "Cancel this booking?",
            isPresented: Binding(
                get: { viewModel.bookingToCancel != nil },
                set: { if !$0 { viewModel.bookingToCancel = nil } }
            )
        ) {
            Button("Yes, Cancel", role: .destructive) {
                if let booking = viewModel.bookingToCancel {
                    Task {
                        await viewModel.cancel(booking)
                    }
                }
            }

            Button("Keep Booking", role: .cancel) { }
        } message: {
            if let booking = viewModel.bookingToCancel {
                Text(
                    "Your booking with \(booking.workerName) on " +
                    "\(viewModel.dateText(booking)) will be cancelled."
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

   

    private func header(isPad: Bool) -> some View {
        HStack {
            if isPresented {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(fieldColor)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Back")
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            Text("My Bookings")
                .font(isPad ? .largeTitle : .title3)
                .fontWeight(.bold)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .frame(maxWidth: 1100)
        .frame(maxWidth: .infinity)
    }

   

    private func tabChips(isPad: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MyBookingsViewModel.Tab.allCases) { item in
                    let isSelected = viewModel.tab == item

                    Button {
                        viewModel.tab = item
                    } label: {
                        Text(item.rawValue)
                            .font(isPad ? .subheadline : .footnote)
                            .fontWeight(.medium)
                            .foregroundColor(
                                isSelected ? .white : .secondary
                            )
                            .padding(.horizontal, isPad ? 20 : 16)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ? blue : Color(uiColor: .secondarySystemBackground)
                            )
                            .overlay {
                                Capsule()
                                    .stroke(
                                        isSelected
                                            ? blue
                                            : Color.gray.opacity(0.25),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxWidth: 1100)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

  

    private func bookingColumns(isPad: Bool) -> [GridItem] {
        if isPad {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        }

        return [
            GridItem(.flexible())
        ]
    }

  

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 42))
                .foregroundColor(blue.opacity(0.8))

            Text(viewModel.emptyMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

   

    private func bookingCard(
        _ booking: BookingItem,
        isPad: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 8) {
                statusBadge(booking)

                Spacer(minLength: 4)

                Text(viewModel.dateText(booking))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            }

            Text(booking.workerName)
                .font(isPad ? .title3 : .headline)
                .fontWeight(.bold)
                .lineLimit(2)

            Label(booking.service, systemImage: "wrench.and.screwdriver")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Spacer(minLength: 4)

            HStack(spacing: 10) {
                if booking.canCancel {
                    Button {
                        viewModel.bookingToCancel = booking
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(fieldColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.gray.opacity(0.25),
                                        lineWidth: 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isCancelling)
                }

                Button {
                    onViewDetails(booking)
                    detailsBookingID = booking.id
                } label: {
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(isPad ? 20 : 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: isPad ? 190 : nil)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

    
    private func statusBadge(_ booking: BookingItem) -> some View {
        let text: String
        let foreground: Color
        let background: Color

        if booking.isOngoing {
            text = "IN PROGRESS"
            foreground = blue
            background = blue.opacity(0.15)
        } else if booking.isConfirmed {
            text = "CONFIRMED"
            foreground = Color(red: 0.05, green: 0.6, blue: 0.4)
            background = Color.green.opacity(0.15)
        } else {
            text = "PENDING"
            foreground = Color(red: 0.6, green: 0.35, blue: 0.0)
            background = Color.yellow.opacity(0.25)
        }

        return Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(foreground)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    NavigationStack {
        MyBookingsView()
    }
}
