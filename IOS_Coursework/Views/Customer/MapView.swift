//
//  MapView.swift
//  IOS_Coursework
//

//


import SwiftUI
import MapKit

struct WorkerMapView: View {

    @ObservedObject var viewModel: SearchViewModel
    var onChoose: (WorkerResult) -> Void = { _ in }
    var onBackToHome: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedID: String?
    @State private var chosenWorkerID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var selectedWorker: WorkerResult? {
        guard let selectedID else { return nil }
        return viewModel.results.first { $0.id == selectedID }
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            ZStack(alignment: .top) {

               

                Map(position: $position, selection: $selectedID) {
                    UserAnnotation()

                    ForEach(viewModel.results) { worker in
                        Marker(
                            worker.name,
                            systemImage: "wrench.and.screwdriver.fill",
                            coordinate: worker.coordinate
                        )
                        .tint(worker.isAvailableNow ? blue : .gray)
                        .tag(worker.id)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea()

               

                VStack(spacing: 0) {
                    topBar(isPad: isPad)
                    Spacer(minLength: 0)
                }
                .padding(.top, isPad ? 16 : 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)
            }
            .overlay(alignment: isPad ? .trailing : .bottom) {
                if let worker = selectedWorker {
                    selectedCard(worker, isPad: isPad)
                        .frame(
                            maxWidth: isPad ? 380 : .infinity,
                            maxHeight: .infinity,
                            alignment: isPad ? .center : .bottom
                        )
                        .padding(isPad ? 24 : 16)
                        .transition(
                            .move(edge: isPad ? .trailing : .bottom)
                                .combined(with: .opacity)
                        )
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedID)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .workerFlow(
            selection: $chosenWorkerID,
            onBackToHome: onBackToHome
        )
        .onChange(of: selectedID) { _, newValue in
            guard let worker = viewModel.results.first(
                where: { $0.id == newValue }
            ) else {
                return
            }

            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: worker.coordinate,
                        latitudinalMeters: 3000,
                        longitudinalMeters: 3000
                    )
                )
            }
        }
    }

    

    private func topBar(isPad: Bool) -> some View {
        HStack(spacing: 12) {

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(width: 46, height: 46)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 4)
            }
            .accessibilityLabel("Back")

            HStack(spacing: 12) {
                Text(viewModel.mapTitle)
                    .font(isPad ? .headline : .subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Menu {
                    Picker("Filter", selection: $viewModel.filter) {
                        ForEach(SearchViewModel.Filter.allCases) { item in
                            Text(item.rawValue)
                                .tag(item)
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(blue)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Filter workers")
            }
            .padding(.leading, 16)
            .padding(.trailing, 6)
            .frame(height: 52)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.10), radius: 4)
        }
        .padding(.horizontal, isPad ? 24 : 16)
        .frame(maxWidth: isPad ? 900 : .infinity)
        .frame(maxWidth: .infinity)
    }

    

    private func selectedCard(
        _ worker: WorkerResult,
        isPad: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: isPad ? 44 : 38))
                    .foregroundColor(blue.opacity(0.9))

                VStack(alignment: .leading, spacing: 5) {
                    Text(worker.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Text(worker.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 4)

                Button {
                    withAnimation {
                        selectedID = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Close worker details")
            }

            Divider()

            HStack(spacing: 8) {
                if let distance = worker.distanceMiles {
                    Label(
                        String(format: "%.1f miles", distance),
                        systemImage: "mappin.and.ellipse"
                    )
                    .foregroundColor(.secondary)
                }

                Spacer(minLength: 4)

                Text(worker.statusText)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        worker.isAvailableToday ? .green : .secondary
                    )
            }
            .font(.caption)

            Button {
                onChoose(worker)
                chosenWorkerID = worker.id
            } label: {
                HStack {
                    Spacer()
                    Text("Choose Worker")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .background(blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
    }
}

#Preview {
    NavigationStack {
        WorkerMapView(viewModel: SearchViewModel())
    }
}
