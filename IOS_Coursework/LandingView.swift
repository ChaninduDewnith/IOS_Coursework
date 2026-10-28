//
//  ContentView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-03.
//



import SwiftUI

struct LandingView: View {

    @ObservedObject var viewModel: LoginViewModel

    private let blue = Color(
        red: 0.23,
        green: 0.49,
        blue: 0.94
    )

    private let heroBlue = Color(
        red: 0.31,
        green: 0.56,
        blue: 0.97
    )

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 700

            NavigationStack {
                Group {
                    if isPad {
                        iPadLayout
                    } else {
                        iPhoneLayout
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .background(heroBlue)
            }
        }
    }

   

    private var iPhoneLayout: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {

                heroBackground(isPad: false)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                welcomePanel(isPad: false)
                    .frame(maxWidth: .infinity)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

   

    private var iPadLayout: some View {
        HStack(spacing: 0) {

         
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)

                Text("Your Services,\nSimplified.")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Connect with trusted professionals.")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(heroBlue)

            
            VStack {
                Spacer()

                welcomePanel(isPad: true)
                    .frame(maxWidth: 460)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(24)
        .background(Color(uiColor: .systemBackground))
    }

    

    private func heroBackground(isPad: Bool) -> some View {
        GeometryReader { geometry in
            ZStack {
                heroBlue

                VStack(spacing: 16) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(
                            .system(
                                size: min(
                                    geometry.size.width * 0.25,
                                    105
                                )
                            )
                        )
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)

                    Text("Your Services,\nSimplified.")
                        .font(
                            .system(
                                size: isPad ? 36 : 28,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text("Connect with trusted professionals.")
                        .font(isPad ? .title3 : .subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.27
                )
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .accessibilityElement(children: .contain)
    }

    

    private func welcomePanel(isPad: Bool) -> some View {
        VStack(spacing: 22) {

            
            HStack(spacing: 10) {
                Image(systemName: "briefcase.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(blue)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )

                Text("Workly")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Text(
                "Join thousands of professionals finding their next great opportunity."
            )
            .font(isPad ? .body : .subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
            .frame(maxWidth: 380)

        
            NavigationLink {
                LoginView(viewModel: viewModel)
            } label: {
                HStack {
                    Text("Get Started")

                    Spacer()

                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity)
                .background(blue)
                .clipShape(Capsule())
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(isPad ? 32 : 26)
        .frame(maxWidth: .infinity)
        .background {
            if !isPad {
                UnevenRoundedRectangle(
                    topLeadingRadius: 30,
                    topTrailingRadius: 30
                )
                .fill(Color(uiColor: .systemBackground))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LandingView(viewModel: LoginViewModel())
    }
}
