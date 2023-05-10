//
//  STVVisualization.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 14/04/2023.
//

import SwiftUI

struct SingleTransferableVoteVisualization: View {
    init(numberOfVoters: Int = 100, candidates: [Candidate]) {
        self.numberOfVoters = numberOfVoters
        let candidatesViewModel = CandidatesViewModel(candidates)
        self.candidatesViewModel = candidatesViewModel
        self.numberOfSeats = 1
        let results = STVResult(candidates: candidatesViewModel.latestValidCandidates, numberOfSeats: 1, numberOfVoters: numberOfVoters)
        self.results = results
    }

    let numberOfVoters: Int
    @ObservedObject var candidatesViewModel: CandidatesViewModel
    @ObservedObject var results: STVResult
    @State var numberOfSeats: Int
    @State var fPTPWinner: String = ""

    var body: some View {
        ScrollViewReader { scrollProxy in
            ColumnLayout {
                VStack(alignment: .leading) {
                    Text("""
                        Single Transferrable Vote is an electoral system where voters rank all candidates. If a voter's preferred candidate cannot win, the vote goes to the second priority on the ballot, and so forth. Ensuring that the vote is not wasted. This allows voters to vote for the candidate they agree with the most and hence eliminates the need for tactical voting.

                        The system works through a series of rounds where candidates are either elected or eliminated. Change the parameters and candidates below and see how that effects the results in the table on the right.
                        """)

                    HStack(spacing: 5) {
                        FullWidthButton(text: "Randomize votes") {
                            withAnimation {
                                results.update(with: candidatesViewModel.latestValidCandidates, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters, forceGeneration: true)
                                updatePopularVoteText(newValue: candidatesViewModel.latestValidCandidates)
                            }
                        }
                        FullWidthButton(text: "Edit ballots") {
                            withAnimation {
                                scrollProxy.scrollTo(ScrollPoints.ballot, anchor: .top)
                            }
                        }
                    }

                    Stepper("Adjust the number of seats (\(numberOfSeats))", value: $numberOfSeats, in: 1...candidatesViewModel.latestValidCandidates.count) { _ in
                        withAnimation {
                            results.update(with: candidatesViewModel.latestValidCandidates, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters)
                            updatePopularVoteText(newValue: candidatesViewModel.latestValidCandidates)
                        }
                    }
                    Text("Number of votes to get elected: \(numberOfVoters / (numberOfSeats + 1) + 1)")

                    CandidatesView(viewModel: candidatesViewModel)
                        .padding(.top)
                }
                .multilineTextAlignment(.leading)
            } trailingColumn: {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(fPTPWinner)
                            .lineLimit(3, reservesSpace: true)
                        RoundVisualizationView(results: results)
                            .padding(.bottom, 5)

                        Text("13\t\tNumber of votes received\n") +
                        Text(Image(systemName: "checkmark.seal.fill")).foregroundColor(.green) +
                        Text("\t\tThe candidate has been elected\n") +
                        Text(Image(systemName: "xmark")).foregroundColor(.red) +
                        Text("\t\tThe candidate has been eliminated")

                        Text("Ballots")
                            .font(.title)
                            .padding(.top)
                            .id(ScrollPoints.ballot)
                        Text("Here are the prioritized ballots from the election, reorder the ballot by dragging candidates around. See how that changes the election.")
                        STVBallotView(results: results)
                    }
                    .multilineTextAlignment(.leading)
                    .padding()
                    .padding(.leading, 20)
                }
            }
        }
        .onReceive(candidatesViewModel.$latestValidCandidates) { newValue in
            if numberOfSeats > newValue.count {
                numberOfSeats = newValue.count
            }
            results.update(with: newValue, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters)
            updatePopularVoteText(newValue: newValue)
        }
    }

    func updatePopularVoteText(newValue: OrderedDictionary<UUID, Candidate>) {
        let firstPriorityVotes = results.getFirstPriorityVotes()
        guard let winner = firstPriorityVotes.max(by: { $0.value < $1.value }) else {
            fPTPWinner = "No winner could be found"
            return
        }

        let winners = firstPriorityVotes
            .filter {$0.value == winner.value}
            .compactMap {newValue[$0.key]?.name}
            .sorted()
        let popVotePercentage = String(format: "%.2f%%", Double(winner.value) / Double(numberOfVoters) * 100)

        switch winners.count {
        case 0:
            preconditionFailure("This case should have been handled above")
        case 1:
            fPTPWinner = "If everybody voted for their first priority, the winner would be \(winners[0]) with \(winner.value) first priority votes, this equals \(popVotePercentage) of the popular vote"
        default:
            let winnerNames: String
            if winners.count == 2 {
                winnerNames = winners.joined(separator: " and ")
            } else {
                winnerNames = winners[0..<winners.count - 1].joined(separator: ", ") + ", and " + winners.last!
            }
            fPTPWinner = "If everybody voted for their first priority, \(winnerNames) would be tied with \(winner.value) first priority votes, this equals \(popVotePercentage) of the popular vote each"
        }
    }
}
