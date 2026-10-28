//
//  WorkerAvailabilityView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI

struct WorkerAvailabilityView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WorkerAvailabilityViewModel()

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 20)

                    
                    Text("Weekly Schedule")
                        .font(.title3)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        ForEach(viewModel.allDays, id: \.self) { day in
                            dayChip(day)
                        }
                    }

                    
                    Text("Working Hours")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 6)

                    HStack {
                        timeColumn(title: "START TIME",
                                   selection: $viewModel.startTime,
                                   alignment: .leading)

                        Spacer()

                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 16, height: 1)

                        Spacer()

                        timeColumn(title: "END TIME",
                                   selection: $viewModel.endTime,
                                   alignment: .trailing)
                    }
                    .padding(16)
                    .background(cardBackground)

                
                    Text("Service Area Radius")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 6)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Maximum Distance")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(viewModel.radiusMiles)) miles")
                                .fontWeight(.semibold)
                                .foregroundColor(blue)
                        }

                        Slider(value: $viewModel.radiusMiles, in: 1...30, step: 1)
                            .tint(blue)
                    }
                    .padding(16)
                    .background(cardBackground)
                }
                .padding(20)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }

            
            Button {
                Task {
                    if await viewModel.saveAvailability() {
                        dismiss()
                    }
                }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save Availability")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(blue)
                .cornerRadius(14)
            }
            .disabled(viewModel.isSaving || viewModel.isLoading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadAvailability()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
    }

    private func dayChip(_ day: String) -> some View {
        let isSelected = viewModel.selectedDays.contains(day)

        return Button {
            viewModel.toggle(day)
        } label: {
            VStack(spacing: 8) {
                Text(day)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? blue : .black)

                Circle()
                    .fill(isSelected ? blue : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? blue.opacity(0.1) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? blue : Color.gray.opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private func timeColumn(title: String,
                            selection: Binding<Date>,
                            alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }
}
