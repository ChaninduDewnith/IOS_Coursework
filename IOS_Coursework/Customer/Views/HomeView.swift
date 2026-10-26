//
//  HomeView.swift
//  IOS_Coursework
//
//


import SwiftUI

private struct HomeCategory: Identifiable {
    let name: String
    let label: String
    let icon: String
    var id: String { name }
}

struct HomeView: View {

   
    @AppStorage("userName") var userName = ""

    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var searchVM = SearchViewModel()

    
    @State private var chosenWorkerID: String?
    @State private var detailsBookingID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

   
    private let categories = [
        HomeCategory(name: "Electrician", label: "Electrician", icon: "bolt"),
        HomeCategory(name: "Plumber", label: "Plumber", icon: "drop"),
        HomeCategory(name: "Cleaner", label: "Cleaner", icon: "sparkles"),
        HomeCategory(name: "Painter", label: "Painter", icon: "paintbrush"),
        HomeCategory(name: "Carpenter", label: "Carpenter", icon: "hammer"),
        HomeCategory(name: "AC Technician", label: "AC Tech", icon: "wind")
    ]

    private var displayName: String {
        if !homeVM.firstName.isEmpty { return homeVM.firstName }
        return userName.isEmpty ? "there" : userName
    }

    private var shownWorkers: [WorkerResult] {
        Array(searchVM.results.prefix(10))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                header
                searchField
                upcomingCard

                Text("Popular Categories")
                    .font(.headline)

                categoryGrid

                HStack {
                    Text("Workers Near You")
                        .font(.headline)
                    Spacer()
                    Button("See All") {
                        searchVM.selectedCategory = ""
                        searchVM.searchText = ""
                    }
                    .font(.footnote)
                    .foregroundColor(blue)
                }

                if shownWorkers.isEmpty {
                    Text(searchVM.isLoading ? "Loading workers..." : "No workers found.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                ForEach(shownWorkers) { worker in
                    workerCard(worker)
                }
            }
            .padding(20)
        }
        .refreshable { await searchVM.load() }
        .task { await searchVM.load() }
        .onAppear { homeVM.start() }
        .onDisappear { homeVM.stop() }
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

   

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome back")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Hello, \(displayName)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()

            Text(String(displayName.prefix(1)).uppercased())
                .fontWeight(.bold)
                .foregroundColor(blue)
                .frame(width: 40, height: 40)
                .background(blue.opacity(0.15))
                .clipShape(Circle())
            
            NavigationLink {
                NotificationsView()
            } label: {
                Image(systemName: "bell.fill")}
            
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("What service do you need?", text: $searchVM.searchText)
                .autocorrectionDisabled()
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(blue)
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    

    @ViewBuilder
    private var upcomingCard: some View {
        if let booking = homeVM.upcoming {
            Button {
                detailsBookingID = booking.id
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("UPCOMING BOOKING")
                            .font(.system(size: 9, weight: .semibold))
                            .padding(5)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(6)
                        Spacer()
                        Text(homeVM.timeText(booking))
                            .font(.caption)
                    }
                    Text(booking.workerName)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(booking.service)
                        .font(.footnote)
                }
                .foregroundColor(.white)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(blue)
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("No upcoming bookings")
                    .fontWeight(.bold)
                Text("Choose a worker below to book a service.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
        }
    }

   

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                  spacing: 16) {
            ForEach(categories) { category in
                let isSelected = searchVM.selectedCategory == category.name

                Button {
                    searchVM.selectedCategory = isSelected ? "" : category.name
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .foregroundColor(isSelected ? .white : blue)
                            .frame(width: 56, height: 56)
                            .background(isSelected ? blue : Color(red: 0.96, green: 0.96, blue: 0.97))
                            .clipShape(Circle())

                        Text(category.label)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

   

    private func workerCard(_ worker: WorkerResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(worker.name)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text(worker.rating.map { String(format: "%.1f", $0) } ?? "New")
                    .font(.caption)
                    .fontWeight(.bold)
            }

            Text([worker.category, worker.experience].filter { !$0.isEmpty }.joined(separator: " · "))
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                if let distance = worker.distanceMiles {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f miles", distance))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(worker.statusText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(worker.isAvailableToday ? .green : .gray)
                    .padding(5)
                    .background(worker.isAvailableToday ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                    .cornerRadius(6)

                Spacer()

                Button {
                    chosenWorkerID = worker.id
                } label: {
                    Text("Book Now")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
