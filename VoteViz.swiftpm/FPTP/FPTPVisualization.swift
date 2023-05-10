//
//  FPTPVisualization.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 03/04/2023.
//
import SwiftUI

struct FPTPVisualization: View {
    enum FPTPView: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case Map, Chart
    }

    init(votersPerDistrict: Int = 100, candidates: [Candidate]) {
        self.votersPerDistrict = votersPerDistrict
        let results = FPTPResult(districtCount: Map.Voteistan.tileCount, candidateIds: candidates.map(\.id), votersPerDistrict: votersPerDistrict)
        self.results = results
        let candidatesViewModel = CandidatesViewModel(candidates)
        self.candidatesViewModel = candidatesViewModel
        self.map = Map.Voteistan.withResults(results, candidates: candidatesViewModel.latestValidCandidates)
    }

    let votersPerDistrict: Int

    @ObservedObject var candidatesViewModel: CandidatesViewModel

    @ObservedObject var results: FPTPResult
    @State var hasSimulatedUnderrepresentation = false
    @State var map: Map
    @State var currentView: FPTPView = .Map

    var winnerText: String {
        let winner = results.districtResults
            .compactMap { $0.findDistrictWinner() }
            .reduce(into: [UUID: Int]()) { partialResult, candidate in
                partialResult[candidate, default: 0] += 1
            }
            .max { a, b in
                a.value < b.value
            }
            .map { (candidate: $0.key, districts: $0.value)}

        guard let winner, winner.districts >= map.tiles.count / 2 + 1 else {
            return "No candidate is ahead"
        }
        guard let winnerName = candidatesViewModel.latestValidCandidates[winner.candidate]?.name else {
            return ""
        }

        let totalVotes = CGFloat(results.districtResults.flatMap {$0.result.values}.reduce(0, +))
        let votesForWinner = CGFloat(results.districtResults.map {$0.result[winner.candidate] ?? 0}.reduce(0, +))
        let percentage = votesForWinner / totalVotes
        let percentageString = String(format: "%.2f%%", percentage * 100)

        return  winnerName + " won with " + percentageString + " of the popular vote\n\(winner.districts) / \(map.tiles.count) districts"
    }

    var body: some View {
        ColumnLayout {
            VStack(alignment: .leading) {
                Text("""
                           In a First past the post (FPTP) electoral system, the candidate with the most votes in a district gets elected.

                           One of the benefits of this system is that to improve the chance of getting reelected, every candidate will work in the interest of the district that elected them.

                           Another aspect of this system is that the ruling candidate/party is those who won the most districts, not the popular vote. As can be seen by tapping:
                           """)
                FullWidthButton(text: "Simulate a non representative election") {
                    results.simulateUnderepresentation()
                    updateMap(results: results, candidates: candidatesViewModel.latestValidCandidates)

                    if !hasSimulatedUnderrepresentation {
                        withAnimation {
                            hasSimulatedUnderrepresentation = true
                        }
                    }
                }

                if hasSimulatedUnderrepresentation {
                    Text("On the ") + Text("map").bold() + Text(" this looks like a toss-up. The ") + Text("chart").bold() +
                    Text(" shows the large difference, with the most popular candidate losing even though they have nearly three-quarters of the combined popular vote. This shows that in FPTP, a majority of local majorities rule. Now take a look at a random election:")

                    FullWidthButton(text: "Randomize votes") {
                        results.simulateRandom()
                        updateMap(results: results, candidates: candidatesViewModel.latestValidCandidates)
                    }
                    CandidatesView(viewModel: candidatesViewModel)
                        .padding(.top)
                }
            }
            .multilineTextAlignment(.leading)
        } trailingColumn: {
            VStack(alignment: .leading, spacing: 0) {
                Text(winnerText)
                    .font(.title)
                    .padding(.bottom)
                Picker("DDD", selection: $currentView) {
                    ForEach(FPTPView.allCases) { view in
                        Text(view.rawValue).tag(view)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)

                if currentView == .Map {
                    Text("Map of Voteistan, tap the districts to see how they voted")
                        .font(.title3)
                        .padding(.bottom)
                    MapView(map: $map)
                        .onReceive(candidatesViewModel.$latestValidCandidates) { newCandidates in
                            results.updateCandidates(newCandidates: newCandidates.keys)
                            if zip(newCandidates.getValues(), candidatesViewModel.latestValidCandidates.getValues()).contains(where: { $0.color != $1.color || $0.name != $1.name }) {
                                updateMap(results: results, candidates: newCandidates)
                            }
                        }
                } else if currentView == .Chart {
                    Text("See how the votes were distributed in each district")
                        .font(.title3)
                        .padding(.bottom)
                    PopularVoteChart(
                        candidatesViewModel: candidatesViewModel,
                        results: results,
                        votersPerDistrict: votersPerDistrict)
                }
            }
            .padding()
            .padding(.leading, 20)
        }
    }

    func updateMap(results: FPTPResult, candidates: OrderedDictionary<UUID, Candidate>) {
        map = Map.Voteistan.withResults(results, candidates: candidates)
    }
}
