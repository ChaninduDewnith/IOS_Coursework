import SwiftUI

private struct HomeCategory: Identifiable {
    let name: String
    let label: String
    let icon: String

    var id: String { name }
}

struct HomeView: View {

    @AppStorage("userName") private var userName = ""

    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var notificationsVM = NotificationsViewModel()

    @State private var chosenWorkerID: String?
    @State private var detailsBookingID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let fieldColor = Color(.secondarySystemBackground)

    private let categories = [
        HomeCategory(name: "Electrician", label: "Electrician", icon: "bolt"),
        HomeCategory(name: "Plumber", label: "Plumber", icon: "drop"),
        HomeCategory(name: "Cleaner", label: "Cleaner", icon: "sparkles"),
        HomeCategory(name: "Painter", label: "Painter", icon: "paintbrush"),
        HomeCategory(name: "Carpenter", label: "Carpenter", icon: "hammer"),
        HomeCategory(name: "AC Technician", label: "AC Tech", icon: "wind")
    ]

    private var displayName: String {
        if !homeVM.firstName.isEmpty {
            return homeVM.firstName
        }

        return userName.isEmpty ? "there" : userName
    }

    private var shownWorkers: [WorkerResult] {
        Array(searchVM.results.prefix(10))
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ScrollView {
                VStack(alignment: .leading, spacing: isPad ? 28 : 20) {

                    header

                    searchField

                    upcomingCard

                    sectionTitle("Popular Categories")
                    categoryGrid(isPad: isPad)

                    HStack {
                        sectionTitle("Workers Near You")

                        Spacer()

                        Button("See All") {
                            searchVM.selectedCategory = ""
                            searchVM.searchText = ""
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(blue)
                    }

                    if shownWorkers.isEmpty {
                        emptyWorkersView
                    } else {
                        LazyVGrid(
                            columns: workerColumns(isPad: isPad),
                            alignment: .leading,
                            spacing: 16
                        ) {
                            ForEach(shownWorkers) { worker in
                                workerCard(worker, isPad: isPad)
                            }
                        }
                    }
                }
                .padding(isPad ? 32 : 20)
                .frame(maxWidth: 1200)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color(uiColor: .systemBackground))
            .refreshable {
                await searchVM.load()
            }
            .task {
                await searchVM.load()
            }
            .onAppear {
                homeVM.start()
                notificationsVM.start()
            }
            .onDisappear {
                homeVM.stop()
                notificationsVM.stop()
            }
            .workerFlow(selection: $chosenWorkerID)
            .navigationDestination(
                isPresented: Binding(
                    get: { detailsBookingID != nil },
                    set: { if !$0 { detailsBookingID = nil } }
                )
            ) {
                if let id = detailsBookingID {
                    BookingDetailsView(bookingID: id)
                }
            }
            .alert("Error", isPresented: $searchVM.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(searchVM.errorMessage ?? "Something went wrong.")
            }
        }
    }

    

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
    }

    

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Hello, \(displayName)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 8)

            NavigationLink {
                NotificationsView()
            } label: {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(blue)
                    .frame(width: 46, height: 46)
                    .background(fieldColor)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        if notificationsVM.unreadCount > 0 {
                            Text(notificationsVM.unreadCount > 9 ? "9+" : "\(notificationsVM.unreadCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Notifications")

            Text(String(displayName.prefix(1)).uppercased())
                .font(.headline)
                .foregroundColor(blue)
                .frame(width: 46, height: 46)
                .background(blue.opacity(0.15))
                .clipShape(Circle())
        }
    }

  

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("What service do you need?", text: $searchVM.searchText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            Image(systemName: "slider.horizontal.3")
                .foregroundColor(blue)
        }
        .padding(15)
        .background(fieldColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    

    @ViewBuilder
    private var upcomingCard: some View {
        if let booking = homeVM.upcoming {
            Button {
                detailsBookingID = booking.id
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("UPCOMING BOOKING")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                        Spacer()

                        Text(homeVM.timeText(booking))
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    Text(booking.workerName)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(booking.service)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [
                            blue,
                            blue.opacity(0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Label("No upcoming bookings", systemImage: "calendar")
                    .font(.headline)

                Text("Choose a worker below to book a service.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fieldColor.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

   

    private func categoryGrid(isPad: Bool) -> some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 14),
                count: isPad ? 6 : 3
            ),
            spacing: 16
        ) {
            ForEach(categories) { category in
                let isSelected = searchVM.selectedCategory == category.name

                Button {
                    searchVM.selectedCategory =
                        isSelected ? "" : category.name
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundColor(isSelected ? .white : blue)
                            .frame(
                                width: isPad ? 64 : 54,
                                height: isPad ? 64 : 54
                            )
                            .background(
                                isSelected ? blue : fieldColor
                            )
                            .clipShape(Circle())

                        Text(category.label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

  

    private func workerColumns(isPad: Bool) -> [GridItem] {
        if isPad {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        } else {
            return [
                GridItem(.flexible())
            ]
        }
    }

    private var emptyWorkersView: some View {
        VStack(spacing: 10) {
            if searchVM.isLoading {
                ProgressView()
                Text("Loading workers...")
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "person.2")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("No workers found.")
                    .foregroundColor(.secondary)

                Text("Try another service or search term.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(fieldColor.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func workerCard(
        _ worker: WorkerResult,
        isPad: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(worker.name)
                        .font(.headline)
                        .lineLimit(2)

                    Text(
                        [worker.category, worker.experience]
                            .filter { !$0.isEmpty }
                            .joined(separator: " · ")
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                }

                Spacer(minLength: 4)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)

                    Text(
                        worker.rating.map {
                            String(format: "%.1f", $0)
                        } ?? "New"
                    )
                    .fontWeight(.semibold)
                }
                .font(.caption)
                .fixedSize()
            }

            HStack(spacing: 8) {
                if let distance = worker.distanceMiles {
                    Label(
                        String(format: "%.1f miles", distance),
                        systemImage: "mappin.and.ellipse"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer(minLength: 4)

                Text(worker.statusText)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        worker.isAvailableToday ? .green : .secondary
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        worker.isAvailableToday
                            ? Color.green.opacity(0.12)
                            : Color.gray.opacity(0.12)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            Button {
                chosenWorkerID = worker.id
            } label: {
                HStack {
                    Spacer()

                    Text("Book Now")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .background(blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
