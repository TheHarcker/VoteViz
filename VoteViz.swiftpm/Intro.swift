//
//  Intro.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 12/04/2023.
//
import SwiftUI

struct FrontpageView: View {
    let navigationTo: (PresentableViews) -> Void

    var body: some View {
        VStack {
            Text("VoteViz")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .padding(.bottom, 22)
            Text("The people of Voteistan are preparing for their first democratic election, but how should the election be done? Explore the options below to see how the system affects the outcome.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 900)
                .padding(.horizontal, 50)

            Spacer()
            HStack(spacing: 0) {
                Spacer()
                FrontpageButton(title: "First Past The Post", flagView: FlagView(flags: (nw: "🇺🇸", ne: "🇬🇧", sw: "🇮🇸", se: "🇰🇷")), color: .blue) {
                    navigationTo(.firstPastThePost)
                }
                Spacer()
                FrontpageButton(title: "Single Transferable Vote", flagView: FlagView(flags: (nw: "🇦🇺", ne: "🇲🇹", sw: "🇨🇮", se: "🇳🇿")), color: .green) {
                    navigationTo(.stv)
                }
                Spacer()
            }
            Spacer()
        }
        .padding(20)
    }
}

struct FrontpageButton: View {
    let title: String
    let flagView: FlagView
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 50) {
                flagView
                    .padding(.horizontal, 70)
                Text(title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .font(.title)
                    .bold()
            }
            .padding(.top, 45)
            .padding(.bottom, 65)
        }
        .background(color)
        .cornerRadius(32)
        .frame(idealWidth: 600, idealHeight: 430)
    }
}

struct FlagView: View {
    let flags: (nw: String, ne: String, sw: String, se: String)

    var body: some View {
        GeometryReader { _ in
            Text(flags.nw)
                .font(.system(size: 108))
                .position(x: 54, y: 79)

            Text(flags.ne)
                .font(.system(size: 85))
                .position(x: 164, y: 43)

            Text(flags.sw)
                .font(.system(size: 85))
                .position(x: 88, y: 152)

            Text(flags.se)
                .font(.system(size: 100))
                .position(x: 188, y: 120)
        }
        .frame(width: 238, height: 196)
    }
}
