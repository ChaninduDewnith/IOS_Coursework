
import SwiftUI

struct JobRequest: Identifiable {
    let id = UUID()
    var customerName: String
    var service: String
    var location: String
    var schedule: String
}

struct WorkerDashboardView: View {

    @AppStorage("userName") private var userName = "Sahan Perera"
    @AppStorage("isAvailable") private var isAvailable = true
    @AppStorage("workerSelectedTab") private var workerSelectedTab = 0

    @State private var selectedRequest: WorkerRequest?

    @StateObject private var locationVM = WorkerLocationViewModel()
    @StateObject private var requestsVM = WorkerRequestsViewModel()

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    private var firstName: String {
        let full = requestsVM.workerName.isEmpty
            ? userName
            : requestsVM.workerName

        return full.split(separator: " ").first.map(String.init) ?? full
    }

    private var shownRequests: [WorkerRequest] {
        Array(requestsVM.newRequests.prefix(3))
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ScrollView {
                VStack(alignment: .leading, spacing: isPad ? 28 : 20) {

                    
                    header(isPad: isPad)

                   
                    ProfileIncompleteBanner()

                    
                    if isPad {
                        HStack(spacing: 16) {
                            statBox(
                                value: requestsVM.pendingCount,
                                title: "Pending Requests",
                                color: blue,
                                isPad: true
                            )

                            statBox(
                                value: requestsVM.upcomingCount,
                                title: "Upcoming Jobs",
                                color: .green,
                                isPad: true
                            )

                            statBox(
                                value: requestsVM.completedCount,
                                title: "Completed",
                                color: .primary,
                                isPad: true
                            )
                        }
                    } else {
                        HStack(spacing: 10) {
                            statBox(
                                value: requestsVM.pendingCount,
                                title: "Pending Req.",
                                color: blue,
                                isPad: false
                            )

                            statBox(
                                value: requestsVM.upcomingCount,
                                title: "Upcoming Jobs",
                                color: .green,
                                isPad: false
                            )

                            statBox(
                                value: requestsVM.completedCount,
                                title: "Completed",
                                color: .primary,
                                isPad: false
                            )
                        }
                    }

                    
                    WorkerLocationCard(viewModel: locationVM)

                  
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("New Requests (\(requestsVM.pendingCount))")
                                .font(isPad ? .title3 : .headline)
                                .fontWeight(.bold)

                            Spacer()

                            Button {
                                workerSelectedTab = 1
                            } label: {
                                HStack(spacing: 4) {
                                    Text("See All")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(blue)
                            }
                            .buttonStyle(.plain)
                        }

                        if shownRequests.isEmpty {
                            emptyRequestsView
                        } else if isPad {
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
                                ForEach(shownRequests) { request in
                                    requestCard(
                                        request,
                                        isPad: true
                                    )
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(shownRequests) { request in
                                    requestCard(
                                        request,
                                        isPad: false
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(isPad ? 28 : 20)
                .frame(maxWidth: isPad ? 1100 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            requestsVM.start()
        }
        .onDisappear {
            requestsVM.stop()
        }
        .task {
            await locationVM.loadSavedLocation()

            if let saved = locationVM.remoteIsAvailable {
                isAvailable = saved
            }
        }
        .sheet(item: $selectedRequest) { request in
            WorkerRequestDetailView(
                request: request,
                viewModel: requestsVM
            )
        }
        .alert(
            "Error",
            isPresented: $requestsVM.showError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                requestsVM.errorMessage
                ?? "Something went wrong."
            )
        }
    }

    

    private func header(isPad: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(
                    width: isPad ? 58 : 44,
                    height: isPad ? 58 : 44
                )
                .foregroundStyle(Color.gray.opacity(0.4))

            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Hello, \(firstName)")
                    .font(isPad ? .title2 : .title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            VStack(spacing: 4) {
                Text(isAvailable ? "Available" : "Unavailable")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        isAvailable ? .green : .secondary
                    )

                Toggle(
                    "Availability",
                    isOn: Binding(
                        get: { isAvailable },
                        set: { newValue in
                            let previousValue = isAvailable
                            isAvailable = newValue

                            Task {
                                let saved = await locationVM.setAvailable(
                                    newValue
                                )

                                if !saved {
                                    isAvailable = previousValue
                                }
                            }
                        }
                    )
                )
                .labelsHidden()
                .fixedSize()
                .disabled(locationVM.isUpdating)
                .tint(blue)
            }

            NavigationLink {
                NotificationsView()
            } label: {
                Image(systemName: "bell")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.gray.opacity(0.15),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Notifications")
        }
        .padding(.vertical, 4)
    }

    

    private func statBox(
        value: Int,
        title: String,
        color: Color,
        isPad: Bool
    ) -> some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(isPad ? .largeTitle : .title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(title)
                .font(isPad ? .subheadline : .caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: isPad ? 110 : 85)
        .padding(.horizontal, 8)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

  

    private var emptyRequestsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text(
                requestsVM.isLoading
                    ? "Loading requests..."
                    : "No new requests right now."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            if requestsVM.isLoading {
                ProgressView()
                    .tint(blue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

   

    private func requestCard(
        _ request: WorkerRequest,
        isPad: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: isPad ? 38 : 32))
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

                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Label {
                Text(request.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            } icon: {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
            }

            Label {
                Text(requestsVM.scheduleText(request))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
            }

            Button {
                selectedRequest = request
            } label: {
                HStack(spacing: 8) {
                    Text("View Request")
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
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
            .padding(.top, 2)
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
}

#Preview {
    NavigationStack {
        WorkerDashboardView()
    }
}
