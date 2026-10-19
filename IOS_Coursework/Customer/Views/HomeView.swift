//
//  HomeView.swift
//  IOS_Coursework
//
//


import SwiftUI


struct Worker: Identifiable {
    let id = UUID()
    var name: String
    var job: String
    var category: String
    var rating: Double
    var distance: String
    var isAvailable: Bool
}

struct HomeView: View {

    
    @AppStorage("userName") var userName = "Silva"

    @State private var searchText = ""
    @State private var selectedCategory = ""
    @State private var showAlert = false
    @State private var bookedName = ""

    
    let categoryNames = ["Electrician", "Plumber", "Cleaner", "Painter", "Carpenter", "AC Tech"]
    let categoryIcons = ["bolt", "drop", "sparkles", "paintbrush", "hammer", "wind"]

    
    let workers = [
        Worker(name: "Sahan Perera", job: "Certified Plumber & Heating", category: "Plumber",
               rating: 4.9, distance: "1.2 miles", isAvailable: true),
        Worker(name: "Pathum Silva", job: "Eco-Friendly Home Cleaning", category: "Cleaner",
               rating: 4.8, distance: "0.5 miles", isAvailable: true),
        Worker(name: "Nimal Fernando", job: "Licensed Home Electrician", category: "Electrician",
               rating: 4.7, distance: "2.1 miles", isAvailable: true),
        Worker(name: "Kasun Jayasinghe", job: "Custom Furniture & Repairs", category: "Carpenter",
               rating: 4.6, distance: "3.4 miles", isAvailable: false)
    ]

    
    var filteredWorkers: [Worker] {
        var result = workers

        if selectedCategory != "" {
            result = result.filter { $0.category == selectedCategory }
        }

        if searchText != "" {
            result = result.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.job.lowercased().contains(searchText.lowercased())
            }
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

            
                HStack {
                    VStack(alignment: .leading) {
                        Text("Welcome back")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Hello, \(userName)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()

                    
                    Text(String(userName.prefix(1)).uppercased())
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))
                        .frame(width: 40, height: 40)
                        .background(Color(red: 0.23, green: 0.49, blue: 0.94).opacity(0.15))
                        .clipShape(Circle())

                    Image(systemName: "bell.fill")
                }

        
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("What service do you need?", text: $searchText)
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("UPCOMING BOOKING")
                            .font(.system(size: 9, weight: .semibold))
                            .padding(5)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(6)
                        Spacer()
                        Text("Today, 2:00 PM")
                            .font(.caption)
                    }
                    Text("Saman Perera")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Professional Plumbing Service")
                        .font(.footnote)
                }
                .foregroundColor(.white)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                .cornerRadius(16)

                
                Text("Popular Categories")
                    .font(.headline)

            
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 16) {

                    
                    ForEach(0..<categoryNames.count, id: \.self) { i in
                        Button {
                    
                            if selectedCategory == categoryNames[i] {
                                selectedCategory = ""
                            } else {
                                selectedCategory = categoryNames[i]
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: categoryIcons[i])
                                    .font(.title3)
                                    .foregroundColor(selectedCategory == categoryNames[i] ? .white : Color(red: 0.23, green: 0.49, blue: 0.94))
                                    .frame(width: 56, height: 56)
                                    .background(selectedCategory == categoryNames[i] ? Color(red: 0.23, green: 0.49, blue: 0.94) : Color(red: 0.96, green: 0.96, blue: 0.97))
                                    .clipShape(Circle())

                                Text(categoryNames[i])
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }

           
                HStack {
                    Text("Workers Near You")
                        .font(.headline)
                    Spacer()
                    Button("See All") {

                        selectedCategory = ""
                        searchText = ""
                    }
                    .font(.footnote)
                }

                if filteredWorkers.isEmpty {
                    Text("No workers found.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }

         
                ForEach(filteredWorkers) { worker in
                    VStack(alignment: .leading, spacing: 8) {

                        HStack {
                            Text(worker.name)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", worker.rating))
                                .font(.caption)
                                .fontWeight(.bold)
                        }

                        Text(worker.job)
                            .font(.footnote)
                            .foregroundColor(.gray)

                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(worker.distance)
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(worker.isAvailable ? "Available" : "Busy")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(worker.isAvailable ? .green : .gray)
                                .padding(5)
                                .background(worker.isAvailable ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                                .cornerRadius(6)

                            Spacer()

                            Button {
                                bookedName = worker.name
                                showAlert = true
                            } label: {
                                Text("Book Now")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                                    .cornerRadius(8)
                            }
                            .disabled(!worker.isAvailable)
                            .opacity(worker.isAvailable ? 1 : 0.4)
                        }
                    }
                    .padding(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
        .alert("Booking", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Booking screen for \(bookedName) goes here.")
        }
    }
}

#Preview {
    HomeView()
}

