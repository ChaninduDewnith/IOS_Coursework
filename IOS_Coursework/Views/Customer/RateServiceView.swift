//
//  RateServiceView.swift
//  IOS_Coursework
//


import SwiftUI

struct RateServiceView: View {

    let booking: BookingItem
    @ObservedObject var viewModel: BookingHistoryViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var rating = 0
    @State private var comment = ""

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

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
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 600

            VStack(spacing: isPad ? 24 : 18) {

             
                VStack(spacing: 6) {
                    Text("Rate this Service")
                        .font(isPad ? .title : .title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("\(booking.workerName) · \(booking.service)")
                        .font(isPad ? .subheadline : .footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.top, 8)

              
                VStack(spacing: 10) {
                    HStack(spacing: isPad ? 18 : 10) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(
                                    systemName: star <= rating
                                    ? "star.fill"
                                    : "star"
                                )
                                .font(
                                    .system(
                                        size: isPad ? 42 : 34
                                    )
                                )
                                .foregroundStyle(
                                    star <= rating
                                    ? .orange
                                    : Color.gray.opacity(0.4)
                                )
                                .frame(
                                    width: isPad ? 54 : 40,
                                    height: isPad ? 54 : 40
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                            .accessibilityAddTraits(
                                rating == star ? .isSelected : []
                            )
                        }
                    }

                    Text(ratingLabel)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(rating > 0 ? blue : .secondary)
                }

                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Review")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ZStack(alignment: .topLeading) {
                        if comment.isEmpty {
                            Text("Share your experience (optional)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary.opacity(0.8))
                                .padding(.horizontal, 13)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $comment)
                            .font(.subheadline)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .frame(height: isPad ? 150 : 110)
                            .accessibilityLabel("Your review")
                    }
                    .background(
                        Color(
                            red: 0.96,
                            green: 0.96,
                            blue: 0.97
                        )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.gray.opacity(0.25),
                                lineWidth: 1
                            )
                    }
                }

                Spacer(minLength: 8)

              
                Button {
                    Task {
                        let success = await viewModel.submitReview(
                            for: booking,
                            rating: rating,
                            comment: comment
                        )

                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")

                            Text("Submit Rating")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isPad ? 56 : 50)
                    .background(
                        rating == 0 || viewModel.isSubmitting
                        ? Color.gray.opacity(0.4)
                        : blue
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                }
                .buttonStyle(.plain)
                .disabled(rating == 0 || viewModel.isSubmitting)
            }
            .padding(isPad ? 32 : 20)
            .frame(maxWidth: isPad ? 560 : .infinity)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
