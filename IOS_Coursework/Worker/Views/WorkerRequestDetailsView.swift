//
//  Untitled.swift
//  IOS_Coursework
//
//
import SwiftUI


struct WorkerRequestDetailView: View {

    let request: WorkerRequest
    @ObservedObject var viewModel: WorkerRequestsViewModel

    @Environment(\.dismiss) var dismiss

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Service Request")
                .font(.title3)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 14) {
                field("CUSTOMER", request.customerName)
                field("SERVICE", request.service)
                field("DATE & TIME", viewModel.scheduleText(request))
                field("ADDRESS", request.address)
                field("ISSUE", request.issue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )

            Spacer()

            HStack(spacing: 12) {
                Button {
                    Task { await respond(accept: false) }
                } label: {
                    Text("Decline")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                }

                Button {
                    Task { await respond(accept: true) }
                } label: {
                    Group {
                        if viewModel.isResponding {
                            ProgressView().tint(.white)
                        } else {
                            Text("Accept")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(blue)
                    .cornerRadius(10)
                }
            }
            .disabled(viewModel.isResponding)
        }
        .padding(20)
        .presentationDetents([.medium, .large])
    }

    private func field(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value.isEmpty ? "--" : value)
                .font(.subheadline)
        }
    }

    private func respond(accept: Bool) async {
        if await viewModel.respond(to: request, accept: accept) {
            dismiss()
        }
    }
}
