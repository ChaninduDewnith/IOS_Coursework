//
//  WorkerMainTabView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//
import SwiftUI


struct WorkerTabView: View {
    var body: some View {
        TabView{
            NavigationStack {
                WorkerDashboardView()
            }
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
               

    
            Text("")
                .tabItem {
                    Label("Requests", systemImage: "list.bullet")
                }
               

            Text("")
                .tabItem {
                    Label("Jobs", systemImage: "calendar")
                }
               

            NavigationStack {
                
            }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                
        }
        .tint(Color(red: 0.23, green: 0.49, blue: 0.94))
    }
}

#Preview {
    WorkerTabView()
}

