//
//  RateServiceView.swift
//  IOS_Coursework
//

import SwiftUI


struct RateServiceView: View {

    let booking: BookingItem
    @ObservedObject var viewModel: BookingHistoryViewModel

    @Environment(\.dismiss) var dismiss

    @State private var rating = 0
    @State private var comment = ""

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var ratingLabel: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very good"
        case 5: return "Excellent"
        default: return "Tap a star to rate"
        }
    }

    var body: some View {
        VStack(spacing: 18) {

            VStack(spacing: 4) {
                Text("Rate this Service")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(booking.workerName) · \(booking.service)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)

         
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        rating = star
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 34))
                            .foregroundColor(star <= rating ? .orange : Color.gray.opacity(0.4))
                    }
                }
            }

            Text(ratingLabel)
                .font(.footnote)
                .foregroundColor(.gray)

          
            ZStack(alignment: .topLeading) {
                TextEditor(text: $comment)
                    .font(.subheadline)
                    .frame(height: 110)
                    .padding(8)

                if comment.isEmpty {
                    Text("Share your experience (optional)")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            Spacer()

            Button {
                Task {
                    if await viewModel.submitReview(for: booking, rating: rating, comment: comment) {
                        dismiss()
                    }
                }
            } label: {
                Group {
                    if viewModel.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Submit Rating")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(rating == 0 ? Color.gray.opacity(0.4) : blue)
                .cornerRadius(10)
            }
            .disabled(rating == 0 || viewModel.isSubmitting)
        }
        .padding(20)
        .presentationDetents([.medium, .large])
    }
}

