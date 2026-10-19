//
//  WorkerDashboardView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//

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

    @State private var showAlert = false
    @State private var selectedCustomer = ""

   
    let upcomingJobs = 5
    let completedJobs = 142

   
    let requests = [
        JobRequest(customerName: "Silva", service: "Leak Diagnostics & Repair",
                   location: "NO 55, Galle Road, Colombo 04.", schedule: "Today, 3:30 PM"),
        JobRequest(customerName: "Silva", service: "Leak Diagnostics & Repair",
                   location: "NO 55, Galle Road, Colombo 04.", schedule: "Today, 3:30 PM"),
        JobRequest(customerName: "Silva", service: "Leak Diagnostics & Repair",
                   location: "NO 55, Galle Road, Colombo 04.", schedule: "Today, 3:30 PM")
    ]

    
    var firstName: String {
        return userName.split(separator: " ").first.map(String.init) ?? userName
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

                    Toggle("", isOn: $isAvailable)
                        .labelsHidden()
                        .tint(Color(red: 0.23, green: 0.49, blue: 0.94))
                }

            
                HStack(spacing: 12) {

                   
                    VStack(spacing: 4) {
                        Text("\(requests.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))
                        Text("Pending Req.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                 
                    VStack(spacing: 4) {
                        Text("\(upcomingJobs)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Upcoming Jobs")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                    
                    VStack(spacing: 4) {
                        Text("\(completedJobs)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("Completed")
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

               
                HStack {
                    Text("New Requests (\(requests.count))")
                        .fontWeight(.bold)
                    Spacer()
                    Button("See All") {
                        workerSelectedTab = 1
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.23, green: 0.49, blue: 0.94))
                }

               
                ForEach(requests) { request in
                    VStack(alignment: .leading, spacing: 6) {

                        Text(request.customerName)
                            .fontWeight(.bold)

                        Text(request.service)
                            .font(.footnote)

                        Text("Location: \(request.location)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("Schedule: \(request.schedule)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Button {
                            selectedCustomer = request.customerName
                            showAlert = true
                        } label: {
                            Text("View Request")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
        .alert("Request", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Request details from \(selectedCustomer) go here.")
        }
    }
}

#Preview {
    WorkerDashboardView()
}
