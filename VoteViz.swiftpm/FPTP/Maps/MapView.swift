//
//  MapView.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 16/04/2023.
//

import SwiftUI

struct MapView: View {
    @Binding var map: Map
    @State var focus: (id: String, text: String)?

    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        Color(uiColor: colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground)
    }
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ForEach(map.tiles) { tile in
                    let rect: CGRect = tile.rect.scale(with: proxy.size)
                    let width = max(0, rect.width - 2)
                    let height = max(0, rect.height - 2)

                    Rectangle()
                        .foregroundColor(Color(tile.color))
                        .frame(width: width, height: height, alignment: .center)
                        .position(CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2))
                        .overlay {
                            Text(tile.text)
                                .multilineTextAlignment(.center)
                                .font(.system(.caption, design: .rounded))
                                .padding()
                                .frame(width: width, height: height, alignment: .center)
                                .position(rect.center)
                        }

                        .onChange(of: map) { newMap in
                            guard let focus else { return }
                            if let focusText = newMap.tiles.first(where: { $0.id == focus.id })?.extraText {
                                self.focus?.text = focusText
                            } else {
                                withAnimation {
                                    self.focus = nil
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                if focus != nil {
                                    focus = nil
                                } else if let extraText = tile.extraText {
                                    focus = (id: tile.id, text: extraText)
                                }
                            }
                        }
                }
            }
            .blur(radius: focus == nil ? 0 : 5)

            if let focus {
                Text(focus.text)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            self.focus = nil
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(uiColor: .systemBackground))
                            .opacity(0.7)
                    }
                    .transition(.scale)
            }
        }
    }
}

extension CGRect {
    func scale(with size: CGSize) -> CGRect {
        CGRect(x: minX * size.width, y: minY * size.height, width: width * size.width, height: height * size.height)
    }
    var center: CGPoint {
        CGPoint(x: minX + width / 2, y: minY + height / 2)
    }
}
