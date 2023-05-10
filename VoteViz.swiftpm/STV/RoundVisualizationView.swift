//
//  RoundVisualizationView.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 16/04/2023.
//

import SwiftUI

struct RoundVisualizationView: View {
    @ObservedObject var results: STVResult
	@Namespace var namespace
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        Color(uiColor: colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.tertiarySystemBackground)
    }

    var roundNumbers: [Int] {
        (results.roundData.max { $0.statuses.count < $1.statuses.count }?.statuses.enumerated().map {$0.offset + 1} ?? [])
    }

    var body: some View {
        Grid {
            GridRow {
                Text("Round")
                    .lineLimit(1)
                    .gridColumnAlignment(.leading)
                ForEach(roundNumbers) { i in
                    Spacer()
                    Text(String(i))
                        .lineLimit(1)
                        .gridColumnAlignment(.center)
                        .matchedGeometryEffect(id: "Round:\(i)", in: namespace)
                }
                Spacer()
            }
            .bold()
            ForEach(results.roundData) { data in
                Divider()
                    .gridCellUnsizedAxes(.horizontal)
                GridRow {
                    Text(data.candidate.name)
                        .lineLimit(2)
                        .frame(minWidth: 60, alignment: .leading)
                        .matchedGeometryEffect(id: "Candidate:\(data.id)", in: namespace)
                    ForEach(data.statuses, id: \.id) { _, status in
                        Spacer()
                        switch status {
                        case .elected:
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .matchedGeometryEffect(id: "Seal:\(data.id)", in: namespace)
                        case .eliminated:
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .matchedGeometryEffect(id: "Xmark:\(data.id)", in: namespace)
                        case .votes(let votes):
                            Text(String(votes))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .foregroundColor(Color(data.candidate.color))
            }
        }
        .padding()
        .background(backgroundColor)
    }
}

extension Int: Identifiable {
    public var id: Int {self}
}
