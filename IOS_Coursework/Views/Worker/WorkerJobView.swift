//
//  WorkerJobView.swift
//  IOS_Coursework
//


import SwiftUI

struct WorkerJobsView: View {

    enum Tab: String, CaseIterable, Identifiable {
        case activeAndUpcoming = "Active & Upcoming"
        case completed = "Completed"

        var id: String { rawValue }
    }

    @StateObject private var viewModel = WorkerRequestsViewModel()

    @State private var tab: Tab = .activeAndUpcoming
    @State private var selectedJobID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var jobs: [WorkerRequest] {
        tab == .activeAndUpcoming
            ? viewModel.activeAndUpcomingJobs
            : viewModel.completedJobs
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 16) {
                tabChips(isPad: isPad)

                ScrollView {
                    Group {
                        if isPad {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ],
                                alignment: .center,
                                spacing: 16
                            ) {
                                jobListContent
                            }
                        } else {
                            LazyVStack(spacing: 14) {
                                jobListContent
                            }
                        }
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: isPad ? 1100 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                .overlay {
                    if viewModel.isLoading && viewModel.all.isEmpty {
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isPad ? 28 : 20)
            .padding(.top, 8)
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(
            isPresented: Binding(
                get: { selectedJobID != nil },
                set: { isPresented in
                    if !isPresented {
                        selectedJobID = nil
                    }
                }
            )
        ) {
            if let id = selectedJobID {
                WorkerJobDetailView(
                    jobID: id,
                    viewModel: viewModel
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    @ViewBuilder
    private var jobListContent: some View {
        ForEach(jobs) { job in
            jobCard(job)
        }

        if !viewModel.isLoading && jobs.isEmpty {
            Text(
                tab == .activeAndUpcoming
                    ? "No active or upcoming jobs."
                    : "No completed jobs yet."
            )
            .font(.footnote)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding(.horizontal, 12)
        }
    }

    private func tabChips(isPad: Bool) -> some View {
        HStack(spacing: 10) {
            ForEach(Tab.allCases) { item in
                let isSelected = tab == item

                Button {
                    tab = item
                } label: {
                    Text(item.rawValue)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.horizontal, isPad ? 20 : 16)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ? blue : Color.white
                        )
                        .overlay {
                            Capsule()
                                .stroke(
                                    isSelected
                                        ? blue
                                        : Color.gray.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: 1100)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func jobCard(_ job: WorkerRequest) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 8) {
                badge(for: job)

                Spacer(minLength: 4)

                Text(viewModel.jobTimeText(job))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(job.customerName)
                .font(.headline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(job.service)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 18)

                Text(job.address)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                selectedJobID = job.id
            } label: {
                HStack {
                    Text("View Details")
                    Image(systemName: "arrow.right")
                }
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.gray.opacity(0.3),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func badge(for job: WorkerRequest) -> some View {
        if job.status == "completed" {
            pill(
                "COMPLETED",
                text: Color(red: 0.05, green: 0.6, blue: 0.4),
                background: Color.green.opacity(0.15)
            )
        } else if viewModel.isActive(job) {
            pill(
                "ACTIVE",
                text: Color(red: 0.8, green: 0.45, blue: 0.0),
                background: Color.orange.opacity(0.2)
            )
        } else {
            pill(
                "UPCOMING",
                text: blue,
                background: blue.opacity(0.12)
            )
        }
    }

    private func pill(
        _ title: String,
        text: Color,
        background: Color
    ) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .fixedSize()
    }
}
