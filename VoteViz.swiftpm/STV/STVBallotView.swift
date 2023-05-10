//
//  STVBallotView.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 17/04/2023.
//

import SwiftUI
struct STVBallotView: View {
    @ObservedObject var results: STVResult

    @Environment(\.colorScheme) var colorScheme
    var rowBackground: Color {
        Color(uiColor: colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground)
    }
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 7) {
                Button {
                    results.activeBallot -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(rowBackground)
                        }
                }
                Button {
                    results.activeBallot += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(rowBackground)
                        }
                }
                Text("Ballot \(results.activeBallotIndex + 1)")
                    .padding(.leading, 10)
                    .bold()
                Spacer()
            }
            List($results.aBallot, id: \.candidate, editActions: .move) { value in
                let (order, candidate) = value.wrappedValue
                TintedBackgroundView(color: Color(candidate.color)) {
                    Text(String(order))
                        .padding()
                        .overlay {
                            Circle()
                                .strokeBorder(Color.primary, lineWidth: 2)
                        }
                    Spacer()
                    Text(candidate.name)
                }
                .listRowInsets(.none)
                .listRowSeparator(.hidden)
                .listRowBackground(rowBackground)
            }
            .scrollContentBackground(.hidden)
            .listStyle(PlainListStyle())
        }
        .aspectRatio(0.5, contentMode: .fit)
    }
}
