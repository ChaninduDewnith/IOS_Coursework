//
//  WorkerJobDetailsView.swift
//  IOS_Coursework
//


import SwiftUI


struct WorkerJobDetailView: View {

    let jobID: String
    @ObservedObject var viewModel: WorkerRequestsViewModel

    @Environment(\.dismiss) var dismiss

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    
    private var job: WorkerRequest? {
        viewModel.all.first { $0.id == jobID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Job Details")
                .font(.title3)
                .fontWeight(.bold)

            if let job {
                VStack(alignment: .leading, spacing: 14) {
                    field("CUSTOMER", job.customerName)
                    field("SERVICE", job.service)
                    field("DATE & TIME", viewModel.jobTimeText(job))
                    field("ADDRESS", job.address)
                    field("ISSUE", job.issue)
                    field("STATUS", statusText(job.status))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )

                Spacer()

                actionButton(for: job)
            } else {
                Text("This job could not be found.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(20)
        .presentationDetents([.medium, .large])
    }

   

    @ViewBuilder
    private func actionButton(for job: WorkerRequest) -> some View {
        switch job.status {
        case "accepted":
            primaryButton("Start Job", color: blue, job: job) {
                _ = await viewModel.startJob(job)
            }
        case "in_progress":
            primaryButton("Mark as Completed", color: .green, job: job) {
                if await viewModel.completeJob(job) { dismiss() }
            }
        default:
            EmptyView()
        }
    }

    private func primaryButton(_ title: String,
                               color: Color,
                               job: WorkerRequest,
                               action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action() }
        } label: {
            Group {
                if viewModel.respondingID == job.id {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(10)
        }
        .disabled(viewModel.isResponding)
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

    private func statusText(_ status: String) -> String {
        switch status {
        case "accepted": return "Accepted"
        case "in_progress": return "In Progress"
        case "completed": return "Completed"
        default: return status.capitalized
        }
    }
}
