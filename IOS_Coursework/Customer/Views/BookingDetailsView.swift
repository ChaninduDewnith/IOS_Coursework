//
//  BookingDetailsView.swift
//  IOS_Coursework
//
//

import SwiftUI


struct BookingDetailsView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: BookingDetailsViewModel

    @State private var pdfFile: PDFFile?
    @State private var pdfFailed = false

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(bookingID: String) {
        _viewModel = StateObject(wrappedValue: BookingDetailsViewModel(bookingID: bookingID))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }

                if viewModel.notFound {
                    Text("This booking could not be found.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if !viewModel.workerName.isEmpty {
                    workerCard
                    serviceCard
                    statusCard

                    if viewModel.isCompleted {
                        downloadButton
                    }
                }
            }
            .padding(20)
        }
        .overlay {
            if viewModel.isLoading && viewModel.workerName.isEmpty {
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .sheet(item: $pdfFile) { file in
            PDFPreviewScreen(file: file)
        }
        .alert("Could not create the PDF", isPresented: $pdfFailed) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please try again.")
        }
    }

  

    private var downloadButton: some View {
        Button {
            makePDF()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.doc.fill")
                Text("Download PDF")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(blue)
            .cornerRadius(12)
        }
    }

    private func makePDF() {
        if let url = BookingPDFExporter.makeFile(for: viewModel.pdfData()) {
            pdfFile = PDFFile(url: url)
        } else {
            pdfFailed = true
        }
    }

    

    private var workerCard: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(viewModel.workerName)
                .fontWeight(.bold)
            Text(viewModel.category)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

   

    private var serviceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Information")
                .fontWeight(.bold)

            Divider()

            field("SERVICE TYPE", viewModel.category)
            field("DATE & TIME", viewModel.dateTimeText)
            field("ADDRESS", viewModel.address)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

    private func field(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
        }
    }

    

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Booking Status")
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                    timelineRow(step,
                                isLast: index == viewModel.steps.count - 1,
                                nextIsDone: index + 1 < viewModel.steps.count
                                    && viewModel.steps[index + 1].kind == .done)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

    private func timelineRow(_ step: TimelineStep, isLast: Bool, nextIsDone: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {

           
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(nextIsDone ? blue : Color.gray.opacity(0.25))
                        .frame(width: 2)
                        .padding(.top, 10)
                }
                dot(for: step.kind)
            }
            .frame(width: 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(step.kind == .upcoming ? .regular : .semibold)
                    .foregroundColor(step.kind == .upcoming ? .gray : (step.kind == .failed ? .red : .black))

                if let text = viewModel.stepDateText(step.date) {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, isLast ? 0 : 20)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func dot(for kind: TimelineStep.Kind) -> some View {
        switch kind {
        case .done:
            Circle().fill(blue).frame(width: 12, height: 12)
        case .failed:
            Circle().fill(Color.red).frame(width: 12, height: 12)
        case .upcoming:
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                .background(Circle().fill(Color.white))
                .frame(width: 12, height: 12)
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
    }
}
