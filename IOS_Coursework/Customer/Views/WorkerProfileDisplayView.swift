//
//  WorkerProfileDisplayView.swift
//  IOS_Coursework
//
//




import SwiftUI

struct WorkerProfileDisplayView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WorkerProfileDisplayViewModel
    @State private var showAllReviews = false

    var onRequestService: (WorkerProfile) -> Void

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)
    private let maxContentWidth: CGFloat = 850

    init(
        workerID: String,
        onRequestService: @escaping (WorkerProfile) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: WorkerProfileDisplayViewModel(workerID: workerID)
        )
        self.onRequestService = onRequestService
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: isPad ? 24 : 18) {

                        topBar

                        if let profile = viewModel.profile {
                            if isPad {
                                ipadProfileContent(profile)
                            } else {
                                iphoneProfileContent(profile)
                            }
                        }
                    }
                    .frame(maxWidth: maxContentWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, isPad ? 32 : 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .overlay {
                    if viewModel.isLoading && viewModel.profile == nil {
                        ProgressView("Loading profile...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.background.opacity(0.8))
                    }
                }

                requestButton(isPad: isPad)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

 

    private func iphoneProfileContent(_ profile: WorkerProfile) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            header(profile)
            statsCard
            aboutSection(profile)
            hoursSection
            reviewsSection
        }
    }

    

    private func ipadProfileContent(_ profile: WorkerProfile) -> some View {
        VStack(alignment: .leading, spacing: 24) {

            HStack(alignment: .center, spacing: 24) {
                avatar(profile, size: 130)

                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if !profile.category.isEmpty {
                        Text(profile.category)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    if let rate = viewModel.hourlyRateText {
                        Text(rate)
                            .font(.headline)
                            .foregroundStyle(blue)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            statsCard

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 24) {
                    aboutSection(profile)
                    hoursSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                reviewsSection
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Go back")

            Spacer()

            Button {
                Task {
                    await viewModel.toggleFavorite()
                }
            } label: {
                Image(
                    systemName: viewModel.isFavorite
                        ? "heart.fill"
                        : "heart"
                )
                .font(.title3)
                .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(viewModel.profile == nil)
            .accessibilityLabel(
                viewModel.isFavorite
                    ? "Remove from favorites"
                    : "Add to favorites"
            )
        }
    }

    

    private func header(_ profile: WorkerProfile) -> some View {
        VStack(spacing: 8) {
            avatar(profile, size: 110)
                .padding(.bottom, 4)

            Text(profile.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if !profile.category.isEmpty {
                Text(profile.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let rate = viewModel.hourlyRateText {
                Text(rate)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(blue)
            }
        }
        .frame(maxWidth: .infinity)
    }

   

    @ViewBuilder
    private func avatar(
        _ profile: WorkerProfile,
        size: CGFloat
    ) -> some View {
        Group {
            if let url = profile.photoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .empty:
                        avatarPlaceholder

                    case .failure:
                        avatarPlaceholder

                    @unknown default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        }
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(Color.gray.opacity(0.4))
    }

    

    private var statsCard: some View {
        HStack(spacing: 0) {
            statColumn(
                top: AnyView(
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)

                        Text(viewModel.ratingText)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                ),
                caption: viewModel.reviewCountText
            )

            statDivider

            statColumn(
                top: AnyView(
                    Text(viewModel.distanceText)
                        .fontWeight(.semibold)
                ),
                // Says why when it can't be worked out (no worker location / location off)
                caption: viewModel.distanceIssue == nil ? "Distance" : "Unavailable"
            )

            statDivider

            statColumn(
                top: AnyView(
                    Text(viewModel.experienceText)
                        .fontWeight(.semibold)
                ),
                caption: "Experience"
            )
        }
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        }
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: 1, height: 36)
    }

    private func statColumn(
        top: AnyView,
        caption: String
    ) -> some View {
        VStack(spacing: 5) {
            top
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }

    

    private func aboutSection(_ profile: WorkerProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("About")

            Text(
                profile.about.isEmpty
                    ? "This worker hasn't added a description yet."
                    : profile.about
            )
            .font(.subheadline)
            .foregroundStyle(
                profile.about.isEmpty ? Color.secondary : Color.primary
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

  

    private var hoursSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Working Hours")

            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Label("Days", systemImage: "calendar")
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 8)

                    Text(viewModel.workingDaysText)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.trailing)
                }

                Divider()

                HStack(spacing: 12) {
                    Label("Hours", systemImage: "clock")
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 8)

                    Text(viewModel.workingHoursText)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                }
            }
            .font(.footnote)
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

   

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("Reviews")

                Spacer()

                if viewModel.reviews.count > 1 {
                    Button(showAllReviews ? "Show Less" : "See All") {
                        withAnimation(.easeInOut) {
                            showAllReviews.toggle()
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(blue)
                }
            }

            if viewModel.reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                let shownReviews = showAllReviews
                    ? viewModel.reviews
                    : Array(viewModel.reviews.prefix(1))

                ForEach(shownReviews) { review in
                    reviewCard(review)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reviewCard(_ review: WorkerReview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text(review.customerName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(2)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)

                    Text(String(format: "%.1f", review.rating))
                        .fontWeight(.semibold)
                }
                .font(.footnote)
                .fixedSize()
            }

            if !review.comment.isEmpty {
                Text("“\(review.comment)”")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
    }

  

    private func requestButton(isPad: Bool) -> some View {
        Button {
            if let profile = viewModel.profile {
                onRequestService(profile)
            }
        } label: {
            Text("Request Service")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: isPad ? 500 : .infinity)
                .padding(.vertical, 16)
                .background(blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
        }
        .disabled(viewModel.profile == nil)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1)
        }
    }
}
