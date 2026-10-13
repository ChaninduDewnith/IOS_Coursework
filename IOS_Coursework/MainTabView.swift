//
//  MainTabView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//
import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {

            
            NavigationStack {
                
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

        
            NavigationStack {
                
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            
            NavigationStack {
                
            }
            .tabItem {
                Label("Bookings", systemImage: "calendar")
            }

        
            NavigationStack {
                
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
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
    MainTabView()
}
