//
//  WorkerProfileEdit.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-19.
//

import SwiftUI

struct WorkerEditProfileView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EditProfileViewModel()

    @State private var isEditingRate = false
    @State private var showPhotoAlert = false

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        VStack(spacing: 0) {

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }

                    .padding(.bottom, 6)

                    Text("SERVICE CATEGORY")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                              spacing: 10) {
                        ForEach(viewModel.categories) { item in
                            categoryChip(item)
                        }
                    }

                    HStack {
                        Text("HOURLY PRICE RATE")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Button(isEditingRate ? "Done" : "Edit") {
                            isEditingRate.toggle()
                        }
                        .font(.caption)
                        .foregroundColor(blue)
                    }

                    HStack {
                        if isEditingRate {
                            Text("Rs.")
                                .font(.footnote)
                            TextField("900", text: $viewModel.rate)
                                .keyboardType(.decimalPad)
                                .font(.footnote)
                        } else {
                            Text("Rs.\(viewModel.formattedRate) / hr")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                    Text("EXPERIENCE LEVEL")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)

                    Picker("Experience", selection: $viewModel.experience) {
                        ForEach(viewModel.experienceOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                    Text("ABOUT ME BRIEF")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)

                    TextEditor(text: $viewModel.about)
                        .font(.footnote)
                        .frame(height: 110)
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(20)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }

            HStack(spacing: 12) {

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }

                Button {
                    Task {
                        if await viewModel.saveProfile() {
                            dismiss()
                        }
                    }
                } label: {
                    Group {
                        if viewModel.isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Save Profile")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(blue)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isSaving || viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadProfile()
        }
        .alert("Change Photo", isPresented: $showPhotoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Photo picker goes here.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
    }

    private func categoryChip(_ item: ServiceCategory) -> some View {
        let isSelected = viewModel.category == item.name

        return Button {
            viewModel.category = item.name
        } label: {
            VStack(spacing: 6) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                Text(item.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? blue : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? blue.opacity(0.1) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
