//
//  AvatarView.swift
//  IOS_Coursework
//
//  Created by cobsccomp251p-055 on 2026-10-28.
//

import SwiftUI
import UIKit


struct AvatarView: View {

    var base64: String = ""
    var url: String? = nil
    let name: String
    let size: CGFloat

    private let blue = Color(red: 0.23, green: 0.49, blue: 0.94)

    private var savedImage: UIImage? {
        guard !base64.isEmpty, let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    private var initial: String {
        let letter = String(name.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
        return letter.isEmpty ? "?" : letter
    }

    var body: some View {
        Group {
            if let savedImage {
                Image(uiImage: savedImage)
                    .resizable()
                    .scaledToFill()
            } else if let url, !url.isEmpty, let link = URL(string: url) {
                AsyncImage(url: link) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        initialTile
                    }
                }
            } else {
                initialTile
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.27, style: .continuous))
        .accessibilityLabel("Profile photo")
    }

    private var initialTile: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(blue)
    }
}
