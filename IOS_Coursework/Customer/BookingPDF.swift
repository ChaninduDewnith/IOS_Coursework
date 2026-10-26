//
//  BookingPdf.swift
//  IOS_Coursework
//
import SwiftUI
import UIKit
import PDFKit



struct BookingPDFData {
    let reference: String
    let customerName: String
    let workerName: String
    let service: String
    let address: String
    let issue: String
    let scheduledAt: Date?
    let hourlyRate: Double
    let duration: String?
    let steps: [TimelineStep]
}



struct BookingPDFPage: View {

    let data: BookingPDFData

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

          
            HStack(alignment: .top) {
                Text("Workly")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(blue)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("SERVICE SUMMARY")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Ref #\(data.reference)")
                        .font(.system(size: 13, weight: .semibold))
                }
            }

            Rectangle()
                .fill(blue)
                .frame(height: 2)

            Text("COMPLETED")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.05, green: 0.6, blue: 0.4))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .cornerRadius(4)

            section("Worker") {
                row("Name", data.workerName)
                row("Service", data.service)
            }

            section("Customer") {
                row("Name", data.customerName)
            }

            section("Service Information") {
                row("Date & time", dateText)
                row("Address", data.address)
                row("Issue", data.issue)
                row("Hourly rate", rateText)
                if let duration = data.duration {
                    row("Time on job", duration)
                }
            }

            section("Booking Timeline") {
                ForEach(data.steps) { step in
                    row(step.title, stepText(step))
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 3) {
                Text("Generated on \(generatedText)")
                Text("Thank you for using Workly.")
            }
            .font(.system(size: 10))
            .foregroundColor(.gray)
        }
        .padding(40)
        .frame(width: 595, height: 842, alignment: .topLeading)
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }

    

    private func section<Content: View>(_ title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(blue)

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .frame(width: 110, alignment: .leading)
            Text(value.isEmpty ? "--" : value)
                .font(.system(size: 12, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

  

    private static func format(_ date: Date?, _ pattern: String) -> String {
        guard let date else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }

    private var dateText: String {
        Self.format(data.scheduledAt, "MMMM d, yyyy 'at' hh:mm a")
    }

    private var generatedText: String {
        Self.format(Date(), "MMMM d, yyyy, h:mm a")
    }

    private var rateText: String {
        data.hourlyRate.truncatingRemainder(dividingBy: 1) == 0
            ? "Rs.\(Int(data.hourlyRate)) / hr"
            : String(format: "Rs.%.2f / hr", data.hourlyRate)
    }

    private func stepText(_ step: TimelineStep) -> String {
        guard step.date != nil else { return step.kind == .done ? "Done" : "--" }
        return Self.format(step.date, "MMM d, yyyy, h:mm a")
    }
}



@MainActor
enum BookingPDFExporter {

 
    static func makeFile(for data: BookingPDFData) -> URL? {
        let renderer = ImageRenderer(content: BookingPDFPage(data: data))

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Workly-Service-\(data.reference).pdf")
        try? FileManager.default.removeItem(at: url)

        var success = false
        renderer.render { size, renderInContext in
            var box = CGRect(origin: .zero, size: size)
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil)
            renderInContext(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            success = true
        }
        
        let pageCount = PDFDocument(url: url)?.pageCount ?? 0
        return (success && pageCount > 0) ? url : nil
    }
}



struct PDFFile: Identifiable {
    let url: URL
    var id: URL { url }
}

struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) { }
}

