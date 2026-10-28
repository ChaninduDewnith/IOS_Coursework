//
//  WorkerJobDetailsView.swift
//  IOS_Coursework
//



import SwiftUI

struct WorkerJobDetailView: View {

    let jobID: String
    @ObservedObject var viewModel: WorkerRequestsViewModel

    @Environment(\.dismiss) private var dismiss

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var job: WorkerRequest? {
        viewModel.all.first { $0.id == jobID }
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Text("Job Details")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if let job {
                        statusBadge(job.status)
                    }
                }

                if let job {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            customerHeader(job)

                            VStack(alignment: .leading, spacing: 18) {
                                field(
                                    "CUSTOMER",
                                    job.customerName,
                                    icon: "person"
                                )

                                field(
                                    "SERVICE",
                                    job.service,
                                    icon: "wrench.and.screwdriver"
                                )

                                field(
                                    "DATE & TIME",
                                    viewModel.jobTimeText(job),
                                    icon: "calendar"
                                )

                                field(
                                    "ADDRESS",
                                    job.address,
                                    icon: "mappin.and.ellipse"
                                )

                                field(
                                    "ISSUE",
                                    job.issue,
                                    icon: "text.alignleft"
                                )

                                field(
                                    "STATUS",
                                    statusText(job.status),
                                    icon: "checkmark.circle"
                                )
                            }
                            .padding(20)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(Color.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        Color.gray.opacity(0.22),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .frame(maxWidth: isPad ? 700 : .infinity)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                    }

                    actionButton(for: job)
                } else {
                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 42))
                            .foregroundColor(.gray)

                        Text("Job Not Found")
                            .font(.headline)

                        Text("This job could not be found.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()
                }
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func customerHeader(_ job: WorkerRequest) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(job.customerName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(job.service)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    @ViewBuilder
    private func actionButton(for job: WorkerRequest) -> some View {
        switch job.status {
        case "accepted":
            primaryButton("Start Job", color: blue, job: job) {
                _ = await viewModel.startJob(job)
            }

        case "in_progress":
            primaryButton(
                "Mark as Completed",
                color: .green,
                job: job
            ) {
                if await viewModel.completeJob(job) {
                    dismiss()
                }
            }

        default:
            EmptyView()
        }
    }

    private func primaryButton(
        _ title: String,
        color: Color,
        job: WorkerRequest,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 10) {
                if viewModel.respondingID == job.id {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.footnote.weight(.semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isResponding)
    }

    private func field(
        _ title: String,
        _ value: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(blue)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text(value.isEmpty ? "--" : value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 0)
        }
    }

    private func statusBadge(_ status: String) -> some View {
        Text(statusText(status).uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor(status).opacity(0.12))
            .clipShape(Capsule())
            .fixedSize()
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "accepted":
            return blue
        case "in_progress":
            return .orange
        case "completed":
            return .green
        default:
            return .secondary
        }
    }

    private func statusText(_ status: String) -> String {
        switch status {
        case "accepted":
            return "Accepted"
        case "in_progress":
            return "In Progress"
        case "completed":
            return "Completed"
        default:
            return status.capitalized
        }
    }
}
