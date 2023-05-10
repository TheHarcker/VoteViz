//
//  FPTPResult.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 12/04/2023.
//
import GameplayKit
import SwiftUI

struct FPTPDistrictResult {
    let district: String
    let result: [UUID: Int]
    
    func findDistrictWinner() -> UUID? {
        var currentBest: (key: UUID, value: Int)?
        var topIsTied = false
        for i in result {
            if currentBest?.value == i.value {
                topIsTied = true
            } else if currentBest?.value ?? -1 < i.value {
                currentBest = i
                topIsTied = false
            }
        }
        return topIsTied ? nil : currentBest?.key
    }
}

class FPTPResult: ObservableObject {
    internal init(districtCount: Int, candidateIds: [UUID], votersPerDistrict: Int) {
        self.candidateIds = candidateIds
        self.votersPerDistrict = votersPerDistrict
        self.districtResults = getNormalDistributedFPTPResult(districtsCount: districtCount, votersPerDistrict: votersPerDistrict, candidates: candidateIds)
    }

    @Published private(set) var districtResults: [FPTPDistrictResult] = []

    private var candidateIds: [UUID]
    private let votersPerDistrict: Int
}

extension FPTPResult {
    func simulateRandom() {
        self.districtResults = getNormalDistributedFPTPResult(districtsCount: districtResults.count, votersPerDistrict: votersPerDistrict, candidates: candidateIds)
    }

    func simulateUnderepresentation() {
        var candidates = candidateIds.shuffled()
        let formalWinner = candidates.popLast()!
        let popularWinner = candidates.popLast()!
        let districtsCount = districtResults.count
        let districtsToWin = districtsCount / 2 + 1
        let winningDistricts = Set((0..<districtsCount).shuffled()[0..<districtsToWin])
        let votesToWinADistrict = votersPerDistrict / 2 + 1

        districtResults = (0..<districtsCount).map { district in
            if winningDistricts.contains(district) {
                return FPTPDistrictResult(district: String(district + 1), result: [formalWinner: votesToWinADistrict, popularWinner: votersPerDistrict - votesToWinADistrict])
            } else {
                return FPTPDistrictResult(district: String(district + 1), result: [formalWinner: 0, popularWinner: votersPerDistrict])
            }
        }
    }

    func updateCandidates(newCandidates: [UUID]) {
        if newCandidates != candidateIds {
            self.districtResults = getNormalDistributedFPTPResult(districtsCount: districtResults.count, votersPerDistrict: votersPerDistrict, candidates: newCandidates)
        }
        self.candidateIds = newCandidates
    }

    private func getNormalDistributedFPTPResult(districtsCount: Int, votersPerDistrict: Int, candidates: [UUID]) -> [FPTPDistrictResult] {
        guard districtsCount >= 1 else {
            return []
        }
        guard candidates.count >= 1 else {
            return (0..<districtsCount).map {FPTPDistrictResult(district: String($0 + 1), result: [:])}
        }
        let distribution = GKGaussianDistribution(lowestValue: 0, highestValue: votersPerDistrict)
        let districtsToWin = districtsCount / 2 + 1
        let winningDistricts = Set((0..<districtsCount).shuffled()[0..<districtsToWin])
        let prefferedCandidate = candidates.randomElement()!
        return (0..<districtsCount).map { i in
            let forcesWin = winningDistricts.contains(i)
            let candidates = candidates.shuffled()
            var result = [UUID: Int]()
            let prefferedCandidateHeadStart: Int
            if forcesWin {
                let minimumHeadStart = (votersPerDistrict / candidates.count) + 1
                prefferedCandidateHeadStart = distribution.nextInt(upperBound: votersPerDistrict - minimumHeadStart) + minimumHeadStart
                result[prefferedCandidate] = prefferedCandidateHeadStart
            } else {
                prefferedCandidateHeadStart = votersPerDistrict
            }
            for candidate in candidates where !forcesWin || candidate != prefferedCandidate {
                result[candidate] = distribution.nextInt(upperBound: min(votersPerDistrict - result.values.reduce(0, +), prefferedCandidateHeadStart - 1))
            }
            if forcesWin {
                result[prefferedCandidate]! += votersPerDistrict - result.values.reduce(0, +)
            } else {
                result[candidates.first!]! += votersPerDistrict - result.values.reduce(0, +)
            }
            return FPTPDistrictResult(district: String(i + 1), result: result)
        }
    }
}
