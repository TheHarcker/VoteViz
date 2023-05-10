//
//  STVResult.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 17/04/2023.
//

import Combine
import Foundation
import SwiftUI

enum RoundStatus {
    case elected
    case eliminated
    case votes(Int)
}

struct RoundData: Identifiable {
    init(candidate: Candidate, statuses: [RoundStatus]) {
        self.candidate = candidate
        self.statuses = statuses.map { (id: UUID(), status: $0) }
    }

    init(candidate: Candidate, statuses: [(id: UUID, status: RoundStatus)]) {
        self.candidate = candidate
        self.statuses = statuses
    }

    var id: UUID {candidate.id}
    let candidate: Candidate
    let statuses: [(id: UUID, status: RoundStatus)]
}

class STVResult: ObservableObject {
    // The ballot currently presented in the UI
    @Published var activeBallot: Int = 0
    var activeBallotIndex: Int {
        ((activeBallot % numberOfVoters) + numberOfVoters) % numberOfVoters // Handles modulo of negative values
    }

    var aBallot: [(order: Int, candidate: Candidate)] {
        get {
            guard Set(votes[activeBallotIndex]).isSubset(of: candidates.keys) else {
                return []
            }
            return votes[activeBallotIndex]
                .reversed()
                .enumerated()
                .map { (order: $0.offset + 1, candidate: self.candidates[$0.element]!) }
        }
        set(newVotes) {
            let newValue = newVotes.reversed().map(\.candidate.id)
            if votes[activeBallotIndex] != newValue {
                votes[activeBallotIndex] = newValue
                (self.roundData, self.elected) = getRoundData(votes: self.votes, candidates: self.candidates, numberOfSeats: self.numberOfSeats, numberOfVoters: self.numberOfVoters)
            }
        }
    }

    private var votes: [[UUID]]
    @Published private(set) var roundData: [RoundData] = []
    @Published private(set) var elected: [UUID] = []

    private var candidates: OrderedDictionary<UUID, Candidate>
    private var numberOfSeats: Int
    private var numberOfVoters: Int

    init(candidates: OrderedDictionary<UUID, Candidate>, numberOfSeats: Int, numberOfVoters: Int) {
        self.candidates = candidates
        self.numberOfSeats = numberOfSeats
        self.numberOfVoters = numberOfVoters
        // Last is topPriority
        let votes = (0..<numberOfVoters).map { _ in candidates.keys.shuffled()}
        self.votes = votes

        (roundData, elected) = getRoundData(votes: votes, candidates: candidates, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters)
    }

    func update(with candidates: OrderedDictionary<UUID, Candidate>, numberOfSeats: Int, numberOfVoters: Int, forceGeneration: Bool = false) {
        if forceGeneration || numberOfVoters != self.numberOfVoters || candidates.keys != self.candidates.keys {
            votes = (0..<numberOfVoters).map { _ in candidates.keys.shuffled()}
            (roundData, elected) = getRoundData(votes: votes, candidates: candidates, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters)
        } else if numberOfSeats != self.numberOfSeats && numberOfSeats != elected.count {
            (roundData, elected) = getRoundData(votes: votes, candidates: candidates, numberOfSeats: numberOfSeats, numberOfVoters: numberOfVoters)
        } else if zip(candidates.getValues(), self.candidates.getValues()).contains(where: { $0.color != $1.color || $0.name != $1.name }) {
            roundData = roundData.map { data in
                return RoundData(candidate: candidates[data.id]!, statuses: data.statuses)
            }
        }

        self.candidates = candidates
        self.numberOfSeats = numberOfSeats
        self.numberOfVoters = numberOfVoters
    }

    /// Finds the winner(s) and creates data for visualising the rounds
    /// Ties are handled by the ordering of the candidate's ids as strings
    /// It is assummed that every voter ranks all the candidates
    func getRoundData(votes: [[UUID]], candidates: OrderedDictionary<UUID, Candidate>, numberOfSeats: Int, numberOfVoters: Int) -> (roundData: [RoundData], elected: [UUID]) {
        if numberOfSeats >= candidates.count {
            let finalRoundData: [RoundData] = candidates.map { RoundData(candidate: candidates[$0]!, statuses: [.elected])}
            return (roundData: finalRoundData, elected: candidates.keys)
        }

        // The number of votes required to be elected
        let droopQuota = numberOfVoters / (numberOfSeats + 1) + 1

        var votes = votes
        var topPriority = [UUID?]()
        var noLongerInTheRace: Set<UUID> = []
        var allElected: [UUID] = []
        var roundData: [UUID: [RoundStatus]] = candidates.keys.reduce(into: [UUID: [RoundStatus]]()) { $0[$1] = [] }

        let p = votes.map { votes in
            var votes = votes
            let topPriority = votes.popLast()
            return (votes: votes, topPriority: topPriority)
        }
        votes = p.map(\.votes)
        topPriority = p.map(\.topPriority)

        while allElected.count < numberOfSeats && candidates.count - noLongerInTheRace.count != numberOfSeats - allElected.count {
            // Gives everybody still in the race zero votes
            let zeroVotes = candidates.keys
                .filter { !noLongerInTheRace.contains($0) }
                .reduce(into: [UUID: Int]()) { $0[$1] = 0 }

            // Calculates the number of votes each candidate received in this round
            let votesCount = topPriority.compactMap {$0}.reduce(into: zeroVotes) { $0[$1]! += 1}

            // Adds the number of votes to the round overview
            noLongerInTheRace.symmetricDifference(candidates.keys).forEach { candidate in
                if let votes = votesCount[candidate] {
                    roundData[candidate]?.append(.votes(votes))
                }
            }

            // Attempts to find a candidate who passes the quota
            let topCandidate = votesCount.max { a, b in
                if a.value == b.value {
                    return a.key.uuidString < b.key.uuidString
                } else {
                    return a.value < b.value
                }
            }

            if let topCandidate, topCandidate.value >= droopQuota {
                allElected.append(topCandidate.key)
                noLongerInTheRace.insert(topCandidate.key)

                roundData[topCandidate.key]!.append(.elected)

                // Remove voters who voted for this candidate
                let votesForLastElected = topCandidate.value
                var surplus = votesForLastElected - droopQuota

                // Redistributes votes of the elected candidate
                for i in 0..<votes.count where topCandidate.key == topPriority[i] {
                    if surplus > 0 {
                        var nextPriority = votes[i].popLast()
                        while nextPriority != nil && noLongerInTheRace.contains(nextPriority!) {
                            nextPriority = votes[i].popLast()
                        }
                        if nextPriority != nil {
                            surplus -= 1
                        }
                        topPriority[i] = nextPriority
                    } else {
                        topPriority[i] = nil
                    }
                }
                guard surplus == 0 else {
                    fatalError("Could not satisfy surplus")
                }
            } else {
                // If no one can be elected, we will eliminate a candidate
                let eliminated = votesCount.min(by: { a, b in
                    if a.value == b.value {
                        return a.key.uuidString < b.key.uuidString
                    } else {
                        return a.value < b.value
                    }
                })!.key

                noLongerInTheRace.insert(eliminated)
                roundData[eliminated]!.append(.eliminated)

                // Redistribute votes of the eliminated candidate
                for i in 0..<votes.count {
                    var nextPriority = topPriority[i]
                    while nextPriority != nil && noLongerInTheRace.contains(nextPriority!) {
                        nextPriority = votes[i].popLast()
                    }
                    topPriority[i] = nextPriority
                }
            }
        }

        // Distributes the remaining n seats to the remaining n candidates
        if candidates.count - noLongerInTheRace.count == numberOfSeats - allElected.count {
            let final = candidates.keys.filter { !noLongerInTheRace.contains($0) }
            allElected += final
            final.forEach { roundData[$0]!.append(.elected)}
        }

        let finalRoundData: [RoundData] = candidates.map { candidate in
            RoundData(candidate: candidates[candidate]!, statuses: roundData[candidate]!)
        }

        return (roundData: finalRoundData, elected: allElected)
    }

    func getFirstPriorityVotes() -> [UUID: Int] {
        return votes.compactMap(\.last).reduce(into: [UUID: Int]()) { $0[$1, default: 0] += 1}
    }
}
