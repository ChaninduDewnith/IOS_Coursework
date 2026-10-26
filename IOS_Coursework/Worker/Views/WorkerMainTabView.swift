//
//  WorkerMainTabView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//
import SwiftUI


struct WorkerMainTabView: View {
    var body: some View {
        TabView{
            NavigationStack {
                WorkerDashboardView()
            }
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
               

    
            NavigationStack {
                WorkerRequestsView()
            }
                .tabItem {
                    Label("Requests", systemImage: "list.bullet")
                }
               

            Text("")
                .tabItem {
                    Label("Jobs", systemImage: "calendar")
                }
               

            NavigationStack {
                WorkerProfileView()
            }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                
        }
        .tint(Color(red: 0.23, green: 0.49, blue: 0.94))
    }
}

#Preview {
    WorkerMainTabView()
}

