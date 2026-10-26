import SwiftUI


struct JobRequest: Identifiable {
    let id = UUID()
    var customerName: String
    var service: String
    var location: String
    var schedule: String
}

struct WorkerDashboardView: View {

    @AppStorage("userName") var userName = "Sahan Perera"
    @AppStorage("isAvailable") var isAvailable = true
    @AppStorage("workerSelectedTab") var workerSelectedTab = 0

    @State private var selectedRequest: WorkerRequest?
    @StateObject private var locationVM = WorkerLocationViewModel()
    @StateObject private var requestsVM = WorkerRequestsViewModel()

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    
    var firstName: String {
        let full = requestsVM.workerName.isEmpty ? userName : requestsVM.workerName
        return full.split(separator: " ").first.map(String.init) ?? full
    }

   
    private var shownRequests: [WorkerRequest] {
        Array(requestsVM.newRequests.prefix(3))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                
                HStack(spacing: 12) {

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.gray.opacity(0.4))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome back")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Hello, \(firstName)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    Text("Available")
                        .font(.caption)
                        .fontWeight(.medium)

                    Toggle("", isOn: Binding(
                        get: { isAvailable },
                        set: { newValue in
                            isAvailable = newValue
                            Task {
                                let saved = await locationVM.setAvailable(newValue)
                                if !saved { isAvailable = !newValue }
                            }
                        }
                    ))
                    .labelsHidden()
                    .disabled(locationVM.isUpdating)
                    .tint(blue)
                }

            
                HStack(spacing: 12) {
                    statBox(value: requestsVM.pendingCount, title: "Pending Req.", color: blue)
                    statBox(value: requestsVM.upcomingCount, title: "Upcoming Jobs", color: .green)
                    statBox(value: requestsVM.completedCount, title: "Completed", color: .black)
                }

                WorkerLocationCard(viewModel: locationVM)

                
                HStack {
                    Text("New Requests (\(requestsVM.pendingCount))")
                        .fontWeight(.bold)
                    Spacer()
                    Button("See All") {
                        workerSelectedTab = 1
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(blue)
                }

                if shownRequests.isEmpty {
                    Text(requestsVM.isLoading ? "Loading requests..." : "No new requests right now.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                }

                ForEach(shownRequests) { request in
                    requestCard(request)
                }
            }
            .padding(20)
        }
        .onAppear { requestsVM.start() }
        .onDisappear { requestsVM.stop() }
        .task {
            await locationVM.loadSavedLocation()
            if let saved = locationVM.remoteIsAvailable {
                isAvailable = saved
            }
        }
        .sheet(item: $selectedRequest) { request in
            WorkerRequestDetailView(request: request, viewModel: requestsVM)
        }
        .alert("Error", isPresented: $requestsVM.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(requestsVM.errorMessage ?? "Something went wrong.")
        }
    }

  

    private func statBox(value: Int, title: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func requestCard(_ request: WorkerRequest) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(request.customerName)
                .fontWeight(.bold)

            Text(request.service)
                .font(.footnote)

            Text("Location: \(request.address)")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Schedule: \(requestsVM.scheduleText(request))")
                .font(.caption)
                .foregroundColor(.gray)

            Button {
                selectedRequest = request
            } label: {
                Text("View Request")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(blue)
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    WorkerDashboardView()
}
