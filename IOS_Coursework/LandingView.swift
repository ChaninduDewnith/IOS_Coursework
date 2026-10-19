//
//  ContentView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-03.
//

import SwiftUI

struct LandingView: View {

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {

        NavigationStack {
            ZStack(alignment: .bottom) {

                Color(red: 0.31, green: 0.56, blue: 0.97)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(height: 200)
                }

                VStack(spacing: 20) {

                    HStack(spacing: 10) {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                            .cornerRadius(8)

                        Text("Workly")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text("Join thousands of professionals finding their next great opportunity.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    NavigationLink {
                        LoginView(viewModel: viewModel)
                    } label: {
                        Text("Get Started")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.23, green: 0.49, blue: 0.94))
                            .cornerRadius(30)
                    }
                }
                .padding(24)
                .padding(.bottom, 10)
                .background(
                    Color.white
                        .cornerRadius(30)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}

#Preview {
    LandingView(viewModel: LoginViewModel())
}
