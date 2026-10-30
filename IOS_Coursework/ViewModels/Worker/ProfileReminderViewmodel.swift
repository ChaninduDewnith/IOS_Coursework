//
//  ProfileReminderViewmodel.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-30.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore


@MainActor
final class ProfileReminderViewModel: ObservableObject {

    @Published private(set) var needsSetup = false

    private var listener: ListenerRegistration?

    func start() {
        guard listener == nil,
              let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore()
            .collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard error == nil, let snapshot else { return }
                let data = snapshot.data()

                Task { @MainActor [weak self] in
                    self?.needsSetup = WorkerSetupStatus.needsSetup(data)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }
}
