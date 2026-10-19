//
//  SearchView.swift
//  IOS_Coursework
//

//

import SwiftUI


struct SearchResult: Identifiable {
    let id = UUID()
    var name: String
    var job: String
    var category: String
    var rating: Double
    var distance: Double
    var isAvailable: Bool
    var nextSlot: String
}

struct SearchView: View {

    
    var showBackButton = false


    @Environment(\.dismiss) var dismiss

    @State private var searchText = "Plumber"
    @State private var selectedFilter = "Near Me"

    let filters = ["Near Me", "Top Rated", "Available Today"]

    
    let allWorkers = [
        SearchResult(name: "Sahan Perera", job: "Certified Plumber & Heating", category: "Plumber",
                     rating: 4.9, distance: 1.2, isAvailable: true, nextSlot: ""),
        SearchResult(name: "Kamal", job: "Vence & Sons Plumbing Experts", category: "Plumber",
                     rating: 4.7, distance: 2.4, isAvailable: true, nextSlot: ""),
        SearchResult(name: "Sarath", job: "Master Plumber & Pipefitter", category: "Plumber",
                     rating: 4.6, distance: 3.1, isAvailable: false, nextSlot: "4PM"),
        SearchResult(name: "Nimal Fernando", job: "Licensed Home Electrician", category: "Electrician",
                     rating: 4.7, distance: 2.1, isAvailable: true, nextSlot: ""),
        SearchResult(name: "Pathum Silva", job: "Eco-Friendly Home Cleaning", category: "Cleaner",
                     rating: 4.8, distance: 0.5, isAvailable: true, nextSlot: "")
    ]

    
    var results: [SearchResult] {

    
        var list = allWorkers
        if searchText != "" {
            let text = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(text) ||
                $0.job.lowercased().contains(text) ||
                $0.category.lowercased().contains(text)
            }
        }

    
        if selectedFilter == "Near Me" {
            list = list.sorted { $0.distance < $1.distance }
        } else if selectedFilter == "Top Rated" {
            list = list.sorted { $0.rating > $1.rating }
        } else if selectedFilter == "Available Today" {
            list = list.filter { $0.isAvailable }
        }

        return list
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

    
            if showBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
            }

    
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))

                TextField("What service do you need?", text: $searchText)

            
                if searchText != "" {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

            
                NavigationLink {
                    
                } label: {
                    Image(systemName: "map")
                        .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))
                }
            }
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.23, green: 0.49, blue: 0.94), lineWidth: 1.5)
            )

    
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(selectedFilter == filter ? .white : Color(red: 0.23, green: 0.49, blue: 0.94))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? Color(red: 0.23, green: 0.49, blue: 0.94) : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(red: 0.23, green: 0.49, blue: 0.94), lineWidth: 1)
                                )
                        }
                    }
                }
            }

        
            ScrollView {
                VStack(spacing: 12) {

                    if results.isEmpty {
                        Text("No workers found.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }

                
                    ForEach(results) { worker in
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
                                Text(String(format: "%.1f miles", worker.distance))
                                    .font(.caption)
                                    .foregroundColor(.gray)

                            
                                if worker.isAvailable {
                                    Text("Available")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.green)
                                        .padding(5)
                                        .background(Color.green.opacity(0.15))
                                        .cornerRadius(6)
                                } else {
                                    Text("Next Slot: \(worker.nextSlot)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.orange)
                                        .padding(5)
                                        .background(Color.orange.opacity(0.15))
                                        .cornerRadius(6)
                                }

                                Spacer()

                    
                                NavigationLink {
                                   
                                } label: {
                                    Text("Choose")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(20)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
