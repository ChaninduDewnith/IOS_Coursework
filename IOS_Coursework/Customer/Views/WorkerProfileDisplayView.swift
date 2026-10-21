//
//  WorkerProfileDisplayView.swift
//  IOS_Coursework
//
//

import SwiftUI


struct WorkerProfileDisplayView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: WorkerProfileDisplayViewModel
    @State private var showAllReviews = false

    var onRequestService: (WorkerProfile) -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    init(workerID: String,
         onRequestService: @escaping (WorkerProfile) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: WorkerProfileDisplayViewModel(workerID: workerID))
        self.onRequestService = onRequestService
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    topBar

                    if let profile = viewModel.profile {
                        header(profile)
                        statsCard
                        aboutSection(profile)
                        hoursSection
                        reviewsSection
                    }
                }
                .padding(20)
            }
            .overlay {
                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView()
                }
            }

            requestButton
        }
        .navigationBarBackButtonHidden(true)
        .task { await viewModel.load() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

   

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }

            Spacer()

            Button {
                Task { await viewModel.toggleFavorite() }
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? .red : .black)
                    .frame(width: 38, height: 38)
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
            .disabled(viewModel.profile == nil)
        }
    }



    private func header(_ profile: WorkerProfile) -> some View {
        VStack(spacing: 6) {
            avatar(profile)
                .padding(.bottom, 8)

            Text(profile.name)
                .font(.title2)
                .fontWeight(.bold)

            if !profile.category.isEmpty {
                Text(profile.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if let rate = viewModel.hourlyRateText {
                Text(rate)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(blue)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func avatar(_ profile: WorkerProfile) -> some View {
        let placeholder = Image(systemName: "person.crop.circle.fill")
            .resizable()
            .foregroundColor(Color.gray.opacity(0.4))

        Group {
            if let url = profile.photoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(Circle())
    }

   

    private var statsCard: some View {
        HStack(spacing: 0) {
            statColumn(top: AnyView(
                HStack(spacing: 4) {
                    Image(systemName: "star")
                        .foregroundColor(.orange)
                    Text(viewModel.ratingText)
                        .fontWeight(.semibold)
                }
            ), caption: viewModel.reviewCountText)

            Divider().frame(height: 34)

            statColumn(top: AnyView(Text(viewModel.distanceText).fontWeight(.semibold)),
                       caption: "Distance")

            Divider().frame(height: 34)

            statColumn(top: AnyView(Text(viewModel.experienceText).fontWeight(.semibold)),
                       caption: "Experience")
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func statColumn(top: AnyView, caption: String) -> some View {
        VStack(spacing: 2) {
            top.font(.subheadline)
            Text(caption)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    

    private func aboutSection(_ profile: WorkerProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            Text(profile.about.isEmpty ? "This worker hasn't added a description yet." : profile.about)
                .font(.subheadline)
                .foregroundColor(profile.about.isEmpty ? .gray : .primary)
        }
    }

   

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Working Hours")
                .font(.headline)

            HStack {
                Text(viewModel.workingDaysText)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.workingHoursText)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
        }
    }

    

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reviews")
                    .font(.headline)
                Spacer()
                if viewModel.reviews.count > 1 {
                    Button(showAllReviews ? "Show Less" : "See All") {
                        withAnimation { showAllReviews.toggle() }
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(blue)
                }
            }

            if viewModel.reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                let shown = showAllReviews ? viewModel.reviews : Array(viewModel.reviews.prefix(1))
                ForEach(shown) { review in
                    reviewCard(review)
                }
            }
        }
    }

    private func reviewCard(_ review: WorkerReview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.customerName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "star")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(String(format: "%.1f", review.rating))
                    .font(.footnote)
                    .fontWeight(.semibold)
            }

            if !review.comment.isEmpty {
                Text("\"\(review.comment)\"")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

  

    private var requestButton: some View {
        Button {
            if let profile = viewModel.profile {
                onRequestService(profile)
            }
        } label: {
            Text("Request Service")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(blue)
                .cornerRadius(12)
        }
        .disabled(viewModel.profile == nil)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
