//
//  WorkerRequestView.swift
//  IOS_Coursework
//


import SwiftUI

struct WorkerRequestsView: View {

    @AppStorage("workerSelectedTab")
    private var workerSelectedTab = 0

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = WorkerRequestsViewModel()

    @State private var selectedRequest: WorkerRequest?
    @State private var requestToDecline: WorkerRequest?

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 16) {
                header

                ScrollView {
                    Group {
                        if isPad {
                            LazyVGrid(
                                columns: [
                                    GridItem(
                                        .flexible(),
                                        spacing: 16,
                                        alignment: .top
                                    ),
                                    GridItem(
                                        .flexible(),
                                        spacing: 16,
                                        alignment: .top
                                    )
                                ],
                                alignment: .leading,
                                spacing: 16
                            ) {
                                requestList
                            }
                        } else {
                            LazyVStack(spacing: 14) {
                                requestList
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                .overlay {
                    if viewModel.isLoading && viewModel.all.isEmpty {
                        ProgressView("Loading requests...")
                            .tint(blue)
                    }
                }
            }
            .padding(.horizontal, isPad ? 28 : 20)
            .padding(.top, 8)
            .frame(maxWidth: isPad ? 1100 : .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .sheet(item: $selectedRequest) { request in
            WorkerRequestDetailView(
                request: request,
                viewModel: viewModel
            )
        }
        .alert(
            "Decline this request?",
            isPresented: Binding(
                get: { requestToDecline != nil },
                set: { newValue in
                    if !newValue {
                        requestToDecline = nil
                    }
                }
            )
        ) {
            Button("Yes, Decline", role: .destructive) {
                if let request = requestToDecline {
                    Task {
                        _ = await viewModel.respond(
                            to: request,
                            accept: false
                        )
                        requestToDecline = nil
                    }
                }
            }

            Button("Keep", role: .cancel) {
                requestToDecline = nil
            }
        } message: {
            if let request = requestToDecline {
                Text(
                    "\(request.customerName) will be told you can't take this job."
                )
            }
        }
        .alert(
            "Error",
            isPresented: $viewModel.showError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                viewModel.errorMessage
                ?? "Something went wrong."
            )
        }
    }

    

    @ViewBuilder
    private var requestList: some View {
        ForEach(viewModel.newRequests) { request in
            requestCard(request)
        }

        if !viewModel.isLoading && viewModel.newRequests.isEmpty {
            emptyState
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        }
    }

    

    private var header: some View {
        ZStack {
            Text("New Requests")
                .font(.title3)
                .fontWeight(.bold)

            HStack {
                Button {
                    workerSelectedTab = 0
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Go back")

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

   

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 38))
                .foregroundStyle(.secondary)

            Text("No new requests right now.")
                .font(.headline)
                .foregroundStyle(.primary)

            Text("New customer requests will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    

    private func requestCard(
        _ request: WorkerRequest
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // Request information
            Button {
                selectedRequest = request
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(request.customerName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Text(request.service)
                                .font(.subheadline)
                                .foregroundStyle(blue)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    Label {
                        Text(addressText(request))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        Text(viewModel.scheduleText(request))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

           
            HStack(spacing: 12) {
                Button {
                    requestToDecline = request
                } label: {
                    Label(
                        "Decline",
                        systemImage: "xmark"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.gray.opacity(0.3),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)

                Button {
                    Task {
                        _ = await viewModel.respond(
                            to: request,
                            accept: true
                        )
                    }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.respondingID == request.id {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark")

                            Text("Accept")
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(blue)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                }
                .buttonStyle(.plain)
            }
            .disabled(viewModel.isResponding)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    

    private func addressText(
        _ request: WorkerRequest
    ) -> String {
        guard let distance = viewModel.distanceText(request) else {
            return request.address
        }

        return "\(request.address) (\(distance))"
    }
}
