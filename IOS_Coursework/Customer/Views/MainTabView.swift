//
//  MainTabView.swift
//  IOS_Coursework
//
//
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {

            
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

        
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            
            NavigationStack {
                MyBookingsView()
            }
            .tabItem {
                Label("Bookings", systemImage: "calendar")
            }

        
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }

            
            NavigationStack {
                ProfileView()
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
