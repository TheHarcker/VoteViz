//
//  PopularVoteChart.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 14/04/2023.
//
import SwiftUI
import Charts
struct PopularVoteChart: View {
    @ObservedObject var candidatesViewModel: CandidatesViewModel
    @ObservedObject var results: FPTPResult
    let votersPerDistrict: Int
    var iterableResults: [(district: String, results: [(candidate: UUID, votes: Int)])] {
        results.districtResults.map { districtResult in
            let results = candidatesViewModel.latestValidCandidates.keys.compactMap { candidate -> (candidate: UUID, votes: Int)? in
                guard let result = districtResult.result[candidate] else {
                    return nil
                }
                return (candidate: candidate, votes: result)
            }
            return (district: districtResult.district, results: results)
        }
    }

    var body: some View {
        VStack(spacing: 17) {
            // Chart
            Chart {
                ForEach(iterableResults, id: \.district) { district, results in
                    ForEach(results, id: \.candidate) { candidate, votes in
                        BarMark(
                            x: .value("District", district),
                            y: .value("Votes", votes)
                        )
                        .foregroundStyle(Color(candidatesViewModel.latestValidCandidates[candidate]!.color))
                    }
                }
            }
            // Legend
            LazyVGrid(columns: [.init(.adaptive(minimum: 120), alignment: .topLeading)], alignment: .leading, spacing: 15) {
                ForEach(candidatesViewModel.latestValidCandidates.getValues()) { candidate in
                    HStack(alignment: .firstTextBaseline) {
                        Circle().foregroundColor(Color(candidate.color))
                            .frame(width: 10, height: 10)
                        Text(candidate.name)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}
