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

    @Environment(\.dismiss) var dismiss

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedID: String?

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var selectedWorker: WorkerResult? {
        guard let selectedID else { return nil }
        return viewModel.results.first { $0.id == selectedID }
    }

    var body: some View {
        ZStack(alignment: .top) {

            Map(position: $position, selection: $selectedID) {
                UserAnnotation()

                ForEach(viewModel.results) { worker in
                    Marker(worker.name,
                           systemImage: "wrench.and.screwdriver.fill",
                           coordinate: worker.coordinate)
                        .tint(worker.isAvailableNow ? blue : .gray)
                        .tag(worker.id)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea(edges: .bottom)

            topBar
        }
        .overlay(alignment: .bottom) {
            if let worker = selectedWorker {
                selectedCard(worker)
                    .padding(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedID)
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedID) { _, newValue in
            guard let worker = viewModel.results.first(where: { $0.id == newValue }) else { return }
            withAnimation {
                position = .region(MKCoordinateRegion(center: worker.coordinate,
                                                      latitudinalMeters: 3000,
                                                      longitudinalMeters: 3000))
            }
        }
    }

    

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }

            HStack {
                Text(viewModel.mapTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()

                Menu {
                    Picker("Filter", selection: $viewModel.filter) {
                        ForEach(SearchViewModel.Filter.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(blue)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

  

    private func selectedCard(_ worker: WorkerResult) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(worker.name)
                    .fontWeight(.bold)

                Text(worker.category)
                    .font(.footnote)
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    if let distance = worker.distanceMiles {
                        Text(String(format: "%.1f miles", distance))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Text(worker.statusText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(worker.isAvailableToday ? .green : .gray)
                }
            }

            Spacer()

            Button {
                onChoose(worker)
            } label: {
                Text("Choose")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(blue)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 4)
    }
}
