//
//  BookingDetailsView.swift
//  IOS_Coursework
//
//


import SwiftUI

struct BookingDetailsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookingDetailsViewModel

    @State private var pdfFile: PDFFile?
    @State private var pdfFailed = false

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let maxContentWidth: CGFloat = 850

    init(bookingID: String) {
        _viewModel = StateObject(
            wrappedValue: BookingDetailsViewModel(bookingID: bookingID)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ScrollView {
                VStack(alignment: .leading, spacing: isPad ? 24 : 18) {

                    backButton

                    if viewModel.notFound {
                        notFoundView
                    } else if !viewModel.workerName.isEmpty {
                        if isPad {
                            ipadBookingContent
                        } else {
                            iphoneBookingContent
                        }
                    }
                }
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isPad ? 32 : 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .overlay {
                if viewModel.isLoading && viewModel.workerName.isEmpty {
                    ProgressView("Loading booking...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.background.opacity(0.8))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(item: $pdfFile) { file in
            PDFPreviewScreen(file: file)
        }
        .alert("Could not create the PDF", isPresented: $pdfFailed) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please try again.")
        }
    }

   

    private var backButton: some View {
        HStack {
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

            Spacer()

            Text("Booking Details")
                .font(.headline)

            Spacer()

            
            Color.clear
                .frame(width: 44, height: 44)
        }
    }

  

    private var iphoneBookingContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            workerCard
            serviceCard
            statusCard

            if viewModel.isCompleted {
                downloadButton
            }
        }
    }

 

    private var ipadBookingContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            workerCard

            HStack(alignment: .top, spacing: 24) {
                serviceCard
                    .frame(maxWidth: .infinity, alignment: .top)

                statusCard
                    .frame(maxWidth: .infinity, alignment: .top)
            }

            if viewModel.isCompleted {
                downloadButton
                    .frame(maxWidth: 440)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    

    private var notFoundView: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("Booking Not Found")
                .font(.title3)
                .fontWeight(.bold)

            Text("This booking could not be found.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 40)
    }

    

    private var downloadButton: some View {
        Button {
            makePDF()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.down.doc.fill")
                Text("Download PDF")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func makePDF() {
        if let url = BookingPDFExporter.makeFile(for: viewModel.pdfData()) {
            pdfFile = PDFFile(url: url)
        } else {
            pdfFailed = true
        }
    }

    

    private var workerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(blue.opacity(0.1))
                    .frame(width: 54, height: 54)

                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundStyle(blue)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.workerName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)

                Text(viewModel.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(card)
    }

    

    private var serviceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(
                "Service Information",
                symbol: "clipboard"
            )

            Divider()

            field("SERVICE TYPE", viewModel.category)
            field("DATE & TIME", viewModel.dateTimeText)
            field("ADDRESS", viewModel.address)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(card)
    }

    private func field(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

   

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeading(
                "Booking Status",
                symbol: "clock"
            )

            VStack(alignment: .leading, spacing: 0) {
                ForEach(
                    Array(viewModel.steps.enumerated()),
                    id: \.element.id
                ) { index, step in
                    timelineRow(
                        step,
                        isLast: index == viewModel.steps.count - 1,
                        nextIsDone: index + 1 < viewModel.steps.count
                            && viewModel.steps[index + 1].kind == .done
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(card)
    }

    private func timelineRow(
        _ step: TimelineStep,
        isLast: Bool,
        nextIsDone: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(
                            nextIsDone
                                ? blue
                                : Color.gray.opacity(0.25)
                        )
                        .frame(width: 2)
                        .padding(.top, 10)
                }

                dot(for: step.kind)
            }
            .frame(width: 14)

            VStack(alignment: .leading, spacing: 5) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(
                        step.kind == .upcoming ? .regular : .semibold
                    )
                    .foregroundStyle(stepTitleColor(for: step.kind))
                    .fixedSize(horizontal: false, vertical: true)

                if let text = viewModel.stepDateText(step.date) {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, isLast ? 0 : 24)

            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func stepTitleColor(
        for kind: TimelineStep.Kind
    ) -> Color {
        switch kind {
        case .done:
            return .primary
        case .failed:
            return .red
        case .upcoming:
            return .secondary
        }
    }

    @ViewBuilder
    private func dot(for kind: TimelineStep.Kind) -> some View {
        switch kind {
        case .done:
            Circle()
                .fill(blue)
                .frame(width: 12, height: 12)

        case .failed:
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)

        case .upcoming:
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(Color.gray.opacity(0.45), lineWidth: 1.5)
                }
        }
    }

    
    private func sectionHeading(
        _ title: String,
        symbol: String
    ) -> some View {
        HStack(spacing: 9) {
            Image(systemName: symbol)
                .foregroundStyle(blue)

            Text(title)
                .font(.headline)
                .fontWeight(.bold)
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground).opacity(0.35))
            .strokeBorder(Color.gray.opacity(0.22), lineWidth: 1)
    }
}
