//
//  Map+Voteistan.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 07/04/2023.
//
import SwiftUI
extension Map {
    enum Voteistan {
        static let tileCount: Int = {
            rects.count
        }()
        static let rects = (0..<20).compactMap { i -> CGRect? in
            var size = CGSize(width: 0.25, height: 0.2)
            var startPosition = CGPoint(x: CGFloat(i % 4) / 4, y: CGFloat(i / 4) / 5)
            switch i {
            case 8:
                size = CGSize(width: size.width * 1.5, height: size.height)
                startPosition = CGPoint(x: CGFloat(i % 4) / 4, y: CGFloat(i / 4) / 5)
            case 9, 13, 14:
                return nil
            case 10:
                startPosition = CGPoint(x: CGFloat(i % 4) / 4 - size.width / 2, y: CGFloat(i / 4) / 5)
                size = CGSize(width: size.width * 1.5, height: size.height * 2)
            default:
                break
            }
            return CGRect(origin: startPosition, size: size)
        }
        static let map: Map = {
            let tiles = rects.enumerated().map { index, rect in
                return MapTile(id: String(index), color: .init(red: 0.0, green: 0.8, blue: 0.3, alpha: 1), rect: rect, text: "District \(index)", extraText: nil)
            }
            return Map(tiles: tiles)
        }()

        static func withResults(_ results: FPTPResult, candidates: OrderedDictionary<UUID, Candidate>) -> Map {
            guard results.districtResults.count == tileCount else {
                fatalError()
            }

            let tiles = zip(rects, results.districtResults).enumerated()
                .map { index, data -> MapTile in
                    let (rect, result) = data
                    let districtName = "District \(index + 1)\n"
                    let tileText: String
                    if let winner = result.findDistrictWinner(), let winnerName = candidates[winner]?.name, let votes = result.result[winner] {
                        tileText = districtName + "\(winnerName) won with \(votes) votes"
                    } else {
                        tileText = districtName + "Candidates were tied for first place"
                    }

                    let extraText = districtName + result.result
                        .map { candidateId, votes in
                            (name: candidates[candidateId]!.name, votes: votes)
                        }
                        .sorted {
                            if $0.votes == $1.votes {
                                return $0.name > $1.name
                            } else {
                                return $0.votes > $1.votes
                            }
                        }
                        .map { name, votes in
                            "- \(name): \(votes) votes"
                        }
                        .joined(separator: "\n")

                    let color = getColorFromWeightedSum(results: result.result, candidates: candidates)
                    return MapTile(id: String(index), color: color, rect: rect, text: tileText, extraText: extraText)
                }
            return Map(tiles: tiles)
        }
    }
}

func getColorFromWeightedSum(results: [UUID: Int], candidates: OrderedDictionary<UUID, Candidate>) -> CGColor {
    var scalingFactorSum: CGFloat = 0
    let colorMap = candidates.mapValues(\.color)
    let RGB = results.map {
        let scalingFactor = CGFloat($0.value) * CGFloat($0.value)
        scalingFactorSum += scalingFactor
        return (colorMap[$0.key]!, scalingFactor)
    }
        .map { color, factor -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) in
            let cicolor = CIColor(cgColor: color)
            let factor = (factor / scalingFactorSum)
            return (red: cicolor.red * factor, green: cicolor.green * factor, blue: cicolor.blue * factor, alpha: cicolor.alpha * factor)
        }
        .reduce(into: (red: CGFloat.zero, green: CGFloat.zero, blue: CGFloat.zero, alpha: CGFloat.zero)) { partialResult, color in
            partialResult.red += color.red
            partialResult.green += color.green
            partialResult.blue += color.blue
            partialResult.alpha += color.alpha
        }
    return CGColor(red: RGB.red, green: RGB.green, blue: RGB.blue, alpha: RGB.alpha)
}
