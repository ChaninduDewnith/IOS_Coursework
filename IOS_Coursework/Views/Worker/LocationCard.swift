//
//  LocationCard.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI


struct WorkerLocationCard: View {

   
    @ObservedObject var viewModel: WorkerLocationViewModel

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("My Location")
                        .fontWeight(.semibold)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Button {
                Task { await viewModel.updateLocation() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isUpdating {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "location.fill")
                        Text("Update My Location")
                            .fontWeight(.semibold)
                    }
                }
                .font(.footnote)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(blue)
                .cornerRadius(10)
            }
            .disabled(viewModel.isUpdating)

            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(viewModel.isError ? .red : .green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private var subtitle: String {
        guard let date = viewModel.lastUpdated else {
            return "Not shared yet. Tap below so customers can find you."
        }
        let relative = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
        return "Last updated \(relative)"
    }
}
