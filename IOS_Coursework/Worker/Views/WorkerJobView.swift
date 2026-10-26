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
        tab == .activeAndUpcoming ? viewModel.activeAndUpcomingJobs : viewModel.completedJobs
    }

    var body: some View {
        VStack(spacing: 16) {

            tabChips

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(jobs) { job in
                        jobCard(job)
                    }

                    if !viewModel.isLoading && jobs.isEmpty {
                        Text(tab == .activeAndUpcoming ? "No active or upcoming jobs." : "No completed jobs yet.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 60)
                    }
                }
                .padding(.top, 4)
            }
            .overlay {
                if viewModel.isLoading && viewModel.all.isEmpty {
                    ProgressView()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .sheet(isPresented: Binding(
            get: { selectedJobID != nil },
            set: { if !$0 { selectedJobID = nil } }
        )) {
            if let id = selectedJobID {
                WorkerJobDetailView(jobID: id, viewModel: viewModel)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

   

    private var tabChips: some View {
        HStack(spacing: 10) {
            ForEach(Tab.allCases) { item in
                let isSelected = tab == item
                Button {
                    tab = item
                } label: {
                    Text(item.rawValue)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isSelected ? blue : Color.white)
                        .overlay(
                            Capsule().stroke(isSelected ? blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
    }

    

    private func jobCard(_ job: WorkerRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                badge(for: job)
                Spacer()
                Text(viewModel.jobTimeText(job))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Text(job.customerName)
                .fontWeight(.bold)

            Text(job.service)
                .font(.footnote)
                .foregroundColor(.black.opacity(0.8))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.gray)
                Text(job.address)
                    .font(.footnote)
            }
            .padding(.top, 2)

            Button {
                selectedJobID = job.id
            } label: {
                Text("View Details")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func badge(for job: WorkerRequest) -> some View {
        if job.status == "completed" {
            pill("COMPLETED",
                 text: Color(red: 0.05, green: 0.6, blue: 0.4),
                 background: Color.green.opacity(0.15))
        } else if viewModel.isActive(job) {
            pill("ACTIVE",
                 text: Color(red: 0.8, green: 0.45, blue: 0.0),
                 background: Color.orange.opacity(0.2))
        } else {
            pill("UPCOMING",
                 text: blue,
                 background: blue.opacity(0.12))
        }
    }

    private func pill(_ title: String, text: Color, background: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .cornerRadius(4)
    }
}

