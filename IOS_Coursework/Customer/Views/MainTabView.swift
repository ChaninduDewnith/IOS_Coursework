//
//  MainTabView.swift
//  IOS_Coursework
//
//
//
import SwiftUI


struct MainTabView: View {

    private enum Tab: String, CaseIterable, Identifiable, Hashable {
        case home, search, bookings, favorites, history, notifications, profile

        var id: Self { self }

        var title: String {
            switch self {
            case .home: return "Home"
            case .search: return "Search"
            case .bookings: return "Bookings"
            case .favorites: return "Favorites"
            case .history: return "History"
            case .notifications: return "Notifications"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .bookings: return "calendar"
            case .favorites: return "heart"
            case .history: return "clock.arrow.circlepath"
            case .notifications: return "bell"
            case .profile: return "person"
            }
        }

    
        var inTabBar: Bool { self != .history && self != .notifications }
    }

    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selection: Tab = .home

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        Group {
            if sizeClass == .regular {
                sidebarLayout
            } else {
                tabLayout
            }
        }
        .tint(blue)
        .onChange(of: sizeClass) { _, newValue in
            if newValue != .regular, !selection.inTabBar { selection = .home }
        }
    }

  

    private var tabLayout: some View {
        TabView(selection: $selection) {
            ForEach(Tab.allCases.filter(\.inTabBar)) { tab in
                NavigationStack {
                    screen(for: tab)
                }
                .tabItem { Label(tab.title, systemImage: tab.icon) }
                .tag(tab)
            }
        }
    }

   

    private var sidebarLayout: some View {
        NavigationSplitView {
            List(
                Tab.allCases,
                selection: Binding<Tab?>(
                    get: { selection },
                    set: { if let value = $0 { selection = value } }
                )
            ) { tab in
                Label(tab.title, systemImage: tab.icon)
            }
            .navigationTitle("Workly")
        } detail: {
            NavigationStack {
                screen(for: selection)
            }
            .id(selection)
        }
    }

  

    @ViewBuilder
    private func screen(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .search:
            SearchView()
        case .bookings:
            MyBookingsView().tabReadable()
        case .favorites:
            FavoritesView().tabReadable()
        case .history:
            BookingHistoryView().tabReadable()
        case .notifications:
            NotificationsView().tabReadable()
        case .profile:
            ProfileView().tabReadable(600)
        }
    }
}

private extension View {
    func tabReadable(_ maxWidth: CGFloat = 720) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
}
