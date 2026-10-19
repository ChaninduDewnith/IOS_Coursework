//
//  IOS_CourseworkApp.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-03.
//

import SwiftUI
import FirebaseCore

@main
struct IOS_CourseworkApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
