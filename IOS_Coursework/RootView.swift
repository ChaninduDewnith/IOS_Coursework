//
//  RootView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI

struct RootView: View {
    @StateObject private var vm = LoginViewModel()

    var body: some View {
        Group {
            if vm.isLoggedIn {
                switch vm.role {
                case .customer:
                    MainTabView()
                case .worker:
                    WorkerMainTabView()
                case nil:
                    ProgressView()
                }
            } else {
                LandingView(viewModel: vm)
            }
        }
        .environmentObject(vm)
        .task { await vm.restoreSession() }
    }
}
