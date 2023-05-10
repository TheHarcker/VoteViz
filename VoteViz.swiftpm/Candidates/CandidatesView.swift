//
//  CandidatesView.swift
//  VoteViz
//
//  Created by Hans Harck Tønning on 15/04/2023.
//

import SwiftUI

struct CandidatesView: View {
    @ObservedObject var viewModel: CandidatesViewModel
    @FocusState var focusedField: UUID?
    var body: some View {
        VStack {
            Text("Add, remove, recolor, or rename candidates")
                .bold()
                .frame(alignment: .leading)
            if let candidatesError = viewModel.candidatesError {
                TintedBackgroundView(color: .cyan) {
                    Spacer()
                    switch candidatesError {
                    case .twoOrMoreNeeded:
                        Label("Two or more candidates are required", systemImage: "exclamationmark.triangle.fill")
                    case .notAllNamesAreUnique:
                        Label("Some candidates has the same name", systemImage: "exclamationmark.triangle.fill")
                    }
                    Spacer()
                }
                .foregroundColor(.red)
                .padding(.horizontal)
            }

            ForEach($viewModel.candidates) { candidate in
                TintedBackgroundView(color: .cyan) {
                    TextField("Candiate", text: candidate.name)
                        .focused($focusedField, equals: candidate.id)
                        .onSubmit {
                            if !candidate.name.wrappedValue.isEmpty {
                                if let nextEmpty = viewModel.candidates.first(where: \.name.isEmpty) {
                                    focusedField = nextEmpty.id
                                } else if viewModel.candidates.count < 20 {
                                    addCandidate()
                                } else {
                                    focusedField = nil
                                }
                            } else {
                                focusedField = candidate.id
                            }
                        }
                    ColorPicker("", selection: candidate.color, supportsOpacity: true)
                        .aspectRatio(1, contentMode: .fit)
                    Button {
                        viewModel.candidates.removeAll {$0.id == candidate.id}
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(viewModel.candidates.count > 2 ? .red : .secondary)
                    }
                    .padding(.leading)
                    .disabled(viewModel.candidates.count <= 2)

                }
                .padding(.horizontal)
            }

            if viewModel.candidates.count < 20 {
                Button(action: addCandidate) {
                    TintedBackgroundView(color: .cyan) {
                        Text("Add candidate")
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func addCandidate() {
        withAnimation {
            let newCandidate = Candidate(name: "")
            viewModel.candidates.append(newCandidate)
            focusedField = newCandidate.id
        }
    }
}
