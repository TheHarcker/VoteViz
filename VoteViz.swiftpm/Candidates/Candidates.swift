//
//  Candidates.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 16/04/2023.
//

import SwiftUI
enum CandidatesError {
    case twoOrMoreNeeded
    case notAllNamesAreUnique
}

struct Candidate: Identifiable, Hashable, ExpressibleByStringLiteral {
    let id = UUID()
    var name: String
    var color: CGColor
    init(name: String, color: CGColor = .init(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)) {
        self.name = name
        self.color = color
    }
    init(stringLiteral value: String) {
        self.init(name: value)
    }
}

class CandidatesViewModel: ObservableObject {
    init(_ candidates: [Candidate]) {
        self.candidates = candidates
        self.latestValidCandidates = .init(candidates, key: \.id)
    }

    var candidatesError: CandidatesError? {
        let candidates = candidates.filter { !$0.name.isEmpty }
        if candidates.count < 2 {
            return .twoOrMoreNeeded
        }
        if Set(candidates.map(\.name)).count != candidates.count {
            return .notAllNamesAreUnique
        }
        return nil
    }

    @Published var candidates: [Candidate] {
        didSet {
            guard candidatesError == nil, candidates != oldValue else { return }
            latestValidCandidates = .init(candidates.filter { !$0.name.isEmpty }, key: \.id)
        }
    }

    @Published var latestValidCandidates: OrderedDictionary<UUID, Candidate>
}
