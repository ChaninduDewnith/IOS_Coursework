//
//  BookingRequestView.swift
//  IOS_Coursework
//
//

import SwiftUI


struct BookingRequestView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookingRequestViewModel
    @State private var showDatePicker = false

    
    var onViewBooking: (String) -> Void
    var onBackToHome: () -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(workerID: String,
         onViewBooking: @escaping (String) -> Void = { _ in },
         onBackToHome: @escaping () -> Void = { }) {
        _viewModel = StateObject(wrappedValue: BookingRequestViewModel(workerID: workerID))
        self.onViewBooking = onViewBooking
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }

                    workerCard

                    label("Select Date")
                    dateRow

                    label("Preferred Time Slot")
                    slotsSection

                    label("Service Location")
                    locationRow

                    label("Describe the Issue")
                    issueEditor
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .overlay {
                if viewModel.isLoading && viewModel.workerName.isEmpty {
                    ProgressView()
                }
            }

            confirmButton
        }
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.load() }
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            if let bookingID = viewModel.createdBookingID {
                BookingSubmittedView(
                    bookingID: bookingID,
                    onViewBooking: {
                        viewModel.showSuccess = false
                        dismiss()
                        onViewBooking(bookingID)
                    },
                    onBackToHome: {
                        viewModel.showSuccess = false
                        dismiss()
                        onBackToHome()
                    }
                )
            }
        }
    }

    

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.top, 4)
    }

    private var workerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.workerName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(viewModel.workerCategory)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if let rate = viewModel.hourlyRateText {
                Text(rate)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(blue)
            }
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private var dateRow: some View {
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text(viewModel.dateText)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var slotsSection: some View {
        if !viewModel.isWorkingDay {
            Text("\(viewModel.workerName) doesn't work on \(viewModel.selectedDayName)s. Please pick another date.")
                .font(.footnote)
                .foregroundColor(.red)
        } else if viewModel.availableSlots.isEmpty {
            Text("No time slots left for this date.")
                .font(.footnote)
                .foregroundColor(.gray)
        } else {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                      spacing: 10) {
                ForEach(viewModel.availableSlots) { slot in
                    slotChip(slot)
                }
            }
        }
    }

    private func slotChip(_ slot: TimeSlot) -> some View {
        let isSelected = viewModel.selectedSlot == slot

        return Button {
            viewModel.selectedSlot = slot
        } label: {
            Text(slot.label)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? blue : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? blue.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var locationRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.gray)

            TextField("Enter the service address", text: $viewModel.address)
                .font(.subheadline)

            Button {
                Task { await viewModel.useCurrentLocation() }
            } label: {
                if viewModel.isLocating {
                    ProgressView()
                } else {
                    Image(systemName: "location.fill")
                        .foregroundColor(blue)
                }
            }
            .disabled(viewModel.isLocating)
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    private var issueEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.issue)
                .font(.subheadline)
                .frame(height: 130)
                .padding(8)

            if viewModel.issue.isEmpty {
                Text("e.g. Kitchen sink pipe is leaking slowly under the cabinet.")
                    .font(.subheadline)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding(.horizontal, 13)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    private var confirmButton: some View {
        Button {
            Task { _ = await viewModel.submit() }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text("Confirm Request")
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(blue)
            .cornerRadius(12)
        }
        .disabled(viewModel.isSaving || viewModel.isLoading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker("Date",
                       selection: $viewModel.selectedDate,
                       in: Calendar.current.startOfDay(for: Date())...,
                       displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showDatePicker = false }
                    }
                }
        }
        .presentationDetents([.medium])
    }
}
