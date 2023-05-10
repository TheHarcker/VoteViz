//
//  TintedBackgroundView.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 18/04/2023.
//

import SwiftUI

struct TintedBackgroundView<Content: View>: View {
    let color: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack {
            content()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(color)
                .opacity(0.2)
                .background(.clear)
        }
    }
}

struct FullWidthButton: View {
    let text: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(text)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
