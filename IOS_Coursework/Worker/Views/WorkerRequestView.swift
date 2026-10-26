//
//  WorkerRequestView.swift
//  IOS_Coursework
//

import SwiftUI


struct WorkerRequestsView: View {

    @AppStorage("workerSelectedTab") var workerSelectedTab = 0
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = WorkerRequestsViewModel()

    @State private var selectedRequest: WorkerRequest?
    @State private var requestToDecline: WorkerRequest?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(spacing: 16) {

            header

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.newRequests) { request in
                        requestCard(request)
                    }

                    if !viewModel.isLoading && viewModel.newRequests.isEmpty {
                        Text("No new requests right now.")
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
        .sheet(item: $selectedRequest) { request in
            WorkerRequestDetailView(request: request, viewModel: viewModel)
        }
        .alert("Decline this request?",
               isPresented: Binding(
                get: { requestToDecline != nil },
                set: { if !$0 { requestToDecline = nil } }
               )) {
            Button("Yes, Decline", role: .destructive) {
                if let request = requestToDecline {
                    Task { _ = await viewModel.respond(to: request, accept: false) }
                }
            }
            Button("Keep", role: .cancel) { }
        } message: {
            if let request = requestToDecline {
                Text("\(request.customerName) will be told you can't take this job.")
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
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
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                Spacer()
            }
        }
    }

   

    private func requestCard(_ request: WorkerRequest) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            
            VStack(alignment: .leading, spacing: 6) {
                Text(request.customerName)
                    .fontWeight(.bold)

                Text(request.service)
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.8))

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.gray)
                    Text(addressText(request))
                        .font(.footnote)
                }
                .padding(.top, 4)

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(viewModel.scheduleText(request))
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { selectedRequest = request }

            HStack(spacing: 10) {
                Button {
                    requestToDecline = request
                } label: {
                    Text("Decline")
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

                Button {
                    Task { _ = await viewModel.respond(to: request, accept: true) }
                } label: {
                    Group {
                        if viewModel.respondingID == request.id {
                            ProgressView().tint(.white)
                        } else {
                            Text("Accept")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(blue)
                    .cornerRadius(8)
                }
            }
            .disabled(viewModel.isResponding)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

   
    private func addressText(_ request: WorkerRequest) -> String {
        guard let distance = viewModel.distanceText(request) else { return request.address }
        return "\(request.address) (\(distance))"
    }
}
