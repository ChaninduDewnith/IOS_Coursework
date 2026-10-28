//
//  WorkerFlowView.swift
//  IOS_Coursework
//
//

import SwiftUI



extension View {
    func workerFlow(selection: Binding<String?>,
                    onBackToHome: @escaping () -> Void = {}) -> some View {
        navigationDestination(
            isPresented: Binding(
                get: { selection.wrappedValue != nil },
                set: { if !$0 { selection.wrappedValue = nil } }
            )
        ) {
            if let workerID = selection.wrappedValue {
                WorkerFlowView(
                    workerID: workerID,
                    onClose: { selection.wrappedValue = nil },
                    onBackToHome: onBackToHome
                )
            }
        }
    }
}


struct WorkerFlowView: View {

    let workerID: String
    
    var onClose: () -> Void
    var onBackToHome: () -> Void

    @State private var bookingWorkerID: String?
    @State private var detailsBookingID: String?

    var body: some View {
        WorkerProfileDisplayView(workerID: workerID) { profile in
            bookingWorkerID = profile.id
        }
        
        .navigationDestination(
            isPresented: Binding(
                get: { bookingWorkerID != nil },
                set: { if !$0 { bookingWorkerID = nil } }
            )
        ) {
            BookingRequestView(
                workerID: bookingWorkerID ?? workerID,
                onViewBooking: { bookingID in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        detailsBookingID = bookingID
                    }
                },
                onBackToHome: {
                    onClose()
                    onBackToHome()
                }
            )
        }
   
        .navigationDestination(
            isPresented: Binding(
                get: { detailsBookingID != nil },
                set: { if !$0 { detailsBookingID = nil } }
            )
        ) {
            if let bookingID = detailsBookingID {
                BookingDetailsView(bookingID: bookingID)
            }
        }
    }
}
