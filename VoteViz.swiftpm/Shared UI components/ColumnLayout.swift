//
//  ColumnLayout.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 14/04/2023.
//

import SwiftUI

enum ScrollPoints: Hashable {
    case ballot
}

struct ColumnLayout<Leading: View, Trailing: View>: View {
    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder var leadingColumn: () -> Leading
    @ViewBuilder var trailingColumn: () -> Trailing

    let landscapeWidthRatio: CGFloat = 0.45
    let verticalWidthRatio: CGFloat = 0.5
    var body: some View {
        GeometryReader { proxy in
            let widthRatio = proxy.size.width >= proxy.size.height ? landscapeWidthRatio : verticalWidthRatio
            ScrollView(.vertical) {
                leadingColumn()
                    .padding(.trailing, 20)
            }
            .clipped()
            .frame(width: widthRatio * proxy.size.width)
            .position(CGPoint(x: (proxy.size.width * widthRatio) / 2, y: proxy.size.height / 2))

            trailingColumn()
                .background(Color(uiColor: colorScheme == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground))
                .clipped()
                .frame(width: (1 - widthRatio) * (proxy.size.width))
                .position(CGPoint(x: proxy.size.width * (1 + widthRatio) / 2, y: proxy.size.height / 2))
        }
        .padding(.horizontal)
    }
}
