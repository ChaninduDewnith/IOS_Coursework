//
//  WorkerMainTabView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-13.
//
import SwiftUI


struct WorkerMainTabView: View {

    private enum Tab: Int, CaseIterable, Identifiable {

        
        case dashboard = 0, requests = 1, jobs = 2, profile = 3
        case availability = 4, notifications = 5

     
        var id: Self { self }

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .requests: return "Requests"
            case .jobs: return "Jobs"
            case .profile: return "Profile"
            case .availability: return "Availability"
            case .notifications: return "Notifications"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .requests: return "list.bullet"
            case .jobs: return "calendar"
            case .profile: return "person"
            case .availability: return "calendar.badge.clock"
            case .notifications: return "bell"
            }
        }

         
        var inTabBar: Bool { rawValue <= Tab.profile.rawValue }
    }

    @Environment(\.horizontalSizeClass) private var sizeClass
    @AppStorage("workerSelectedTab") private var selectedRaw = 0

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var selection: Binding<Tab> {
        Binding(
            get: {
                let tab = Tab(rawValue: selectedRaw) ?? .dashboard
                if sizeClass != .regular && !tab.inTabBar { return .dashboard }
                return tab
            },
            set: { selectedRaw = $0.rawValue }
        )
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                sidebarLayout
            } else {
                tabLayout
            }
        }
        .tint(blue)
  
        .onAppear { selectedRaw = 0 }
    }

   

    private var tabLayout: some View {
        TabView(selection: selection) {
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
                    get: { selection.wrappedValue },
                    set: { if let value = $0 { selection.wrappedValue = value } }
                )
            ) { tab in
                Label(tab.title, systemImage: tab.icon)
            }
            .navigationTitle("Workly")
        } detail: {
            NavigationStack {
                screen(for: selection.wrappedValue)
            }
            .id(selection.wrappedValue)
        }
    }

  

    @ViewBuilder
    private func screen(for tab: Tab) -> some View {
        switch tab {
        case .dashboard:
            WorkerDashboardView()
        case .requests:
            WorkerRequestsView().workerReadable()
        case .jobs:
            WorkerJobsView().workerReadable()
        case .profile:
            WorkerProfileView().workerReadable()
        case .availability:
            WorkerAvailabilityView().workerReadable()
        case .notifications:
            NotificationsView().workerReadable()
        }
    }
}

private extension View {

    
    func workerReadable(_ maxWidth: CGFloat = 720) -> some View {
        frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    WorkerMainTabView()
}
