//
//  Map.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 03/04/2023.
//
import SwiftUI
struct Map: Equatable {
    var tiles: [MapTile]
}

struct MapTile: Identifiable, Equatable {
    var id: String
    let color: CGColor
    let rect: CGRect
    let text: String
    let extraText: String?
}
