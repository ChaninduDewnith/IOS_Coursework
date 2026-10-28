//
//  Untitled.swift
//  IOS_Coursework
//
//

import SwiftUI

struct WorkerRequestDetailView: View {

    let request: WorkerRequest
    @ObservedObject var viewModel: WorkerRequestsViewModel

    @Environment(\.dismiss) private var dismiss

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            VStack(alignment: .leading, spacing: 20) {

                HStack {
                    Text("Service Request")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Text("NEW REQUEST")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(blue.opacity(0.1))
                        .clipShape(Capsule())
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        customerHeader

                        VStack(alignment: .leading, spacing: 20) {
                            field(
                                "CUSTOMER",
                                request.customerName,
                                icon: "person"
                            )

                            field(
                                "SERVICE",
                                request.service,
                                icon: "wrench.and.screwdriver"
                            )

                            field(
                                "DATE & TIME",
                                viewModel.scheduleText(request),
                                icon: "calendar"
                            )

                            field(
                                "ADDRESS",
                                request.address,
                                icon: "mappin.and.ellipse"
                            )

                            field(
                                "ISSUE",
                                request.issue,
                                icon: "text.alignleft"
                            )
                        }
                        .padding(20)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(Color.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color.gray.opacity(0.22),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .frame(maxWidth: isPad ? 700 : .infinity)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
                }

                actionButtons(isPad: isPad)
            }
            .padding(.horizontal, isPad ? 32 : 20)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var customerHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(request.customerName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(request.service)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.gray.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    private func actionButtons(isPad: Bool) -> some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await respond(accept: false)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                    Text("Decline")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.red.opacity(0.5),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    await respond(accept: true)
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isResponding {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark")
                        Text("Accept")
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: isPad ? 700 : .infinity)
        .frame(maxWidth: .infinity)
        .disabled(viewModel.isResponding)
    }

    private func field(
        _ title: String,
        _ value: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(blue)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text(value.isEmpty ? "--" : value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 0)
        }
    }

    private func respond(accept: Bool) async {
        if await viewModel.respond(
            to: request,
            accept: accept
        ) {
            dismiss()
        }
    }
}
