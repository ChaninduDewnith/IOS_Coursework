//
//  BookingRequestView.swift
//  IOS_Coursework
//
//


import SwiftUI

struct BookingRequestView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookingRequestViewModel
    @State private var showDatePicker = false

    var onViewBooking: (String) -> Void
    var onBackToHome: () -> Void

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    private let maxContentWidth: CGFloat = 850

    init(
        workerID: String,
        onViewBooking: @escaping (String) -> Void = { _ in },
        onBackToHome: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: BookingRequestViewModel(workerID: workerID)
        )
        self.onViewBooking = onViewBooking
        self.onBackToHome = onBackToHome
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        backButton

                        workerCard

                        formFields(isPad: isPad)
                    }
                    .padding(.horizontal, isPad ? 32 : 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .overlay {
                    if viewModel.isLoading &&
                        viewModel.workerName.isEmpty {
                        ProgressView("Loading worker details...")
                    }
                }

                confirmButton(isPad: isPad)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) {}
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

   

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.headline)

                Text("Booking Request")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.primary)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }

    

    @ViewBuilder
    private func formFields(isPad: Bool) -> some View {
        if isPad {
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 18) {
                    fieldLabel("Select Date")
                    dateRow

                    fieldLabel("Preferred Time Slot")
                    slotsSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 18) {
                    fieldLabel("Service Location")
                    locationRow

                    fieldLabel("Describe the Issue")
                    issueEditor
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            VStack(alignment: .leading, spacing: 14) {
                fieldLabel("Select Date")
                dateRow

                fieldLabel("Preferred Time Slot")
                slotsSection

                fieldLabel("Service Location")
                locationRow

                fieldLabel("Describe the Issue")
                issueEditor
            }
        }
    }

   

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
    }

    

    private var workerCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 42))
                .foregroundStyle(blue.opacity(0.8))

            VStack(alignment: .leading, spacing: 5) {
                Text(
                    viewModel.workerName.isEmpty
                    ? "Worker"
                    : viewModel.workerName
                )
                .font(.headline)
                .fontWeight(.bold)

                Text(viewModel.workerCategory)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if let rate = viewModel.hourlyRateText {
                Text(rate)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(blue)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }

   

    private var dateRow: some View {
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundStyle(blue)

                Text(viewModel.dateText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(minHeight: 48)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    

    @ViewBuilder
    private var slotsSection: some View {
        if !viewModel.isWorkingDay {
            Text(
                "\(viewModel.workerName) doesn't work on " +
                "\(viewModel.selectedDayName)s. Please pick another date."
            )
            .font(.footnote)
            .foregroundStyle(.red)
            .fixedSize(horizontal: false, vertical: true)

        } else if viewModel.availableSlots.isEmpty {
            Text("No time slots left for this date.")
                .font(.footnote)
                .foregroundStyle(.secondary)

        } else {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
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
                .foregroundStyle(isSelected ? blue : .primary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 4)
                .background {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(
                            isSelected
                            ? blue.opacity(0.12)
                            : Color(uiColor: .secondarySystemBackground)
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(
                            isSelected ? blue : Color.gray.opacity(0.25),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    

    private var locationRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(blue)

            TextField(
                "Enter the service address",
                text: $viewModel.address,
                axis: .vertical
            )
            .font(.subheadline)
            .lineLimit(1...3)
            .textInputAutocapitalization(.words)

            Button {
                Task {
                    await viewModel.useCurrentLocation()
                }
            } label: {
                if viewModel.isLocating {
                    ProgressView()
                } else {
                    Image(systemName: "location.fill")
                        .foregroundStyle(blue)
                }
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLocating)
            .accessibilityLabel("Use current location")
        }
        .padding(14)
        .frame(minHeight: 50)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        }
    }

  

    private var issueEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.issue)
                .font(.subheadline)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 130)

            if viewModel.issue.isEmpty {
                Text(
                    "e.g. Kitchen sink pipe is leaking slowly under the cabinet."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary.opacity(0.7))
                .padding(.horizontal, 13)
                .padding(.vertical, 16)
                .allowsHitTesting(false)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        }
    }

  

    private func confirmButton(isPad: Bool) -> some View {
        Button {
            Task {
                _ = await viewModel.submit()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)

                    Text("Submitting...")
                        .fontWeight(.semibold)
                } else {
                    Text("Confirm Request")
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: isPad ? 500 : .infinity)
            .frame(minHeight: 52)
            .background(blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving || viewModel.isLoading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, isPad ? 32 : 20)
        .padding(.vertical, 12)
        .background(.bar)
    }

    

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                in: Calendar.current.startOfDay(for: Date())...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
