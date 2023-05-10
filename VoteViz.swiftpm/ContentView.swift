import SwiftUI
enum PresentableViews: Hashable {
    case firstPastThePost
    case stv
}

struct ContentView: View {
    @State var navigationStack: [PresentableViews] = []

    let candidates: [Candidate] = [
        .init(name: "Apple", color: .init(red: 0.59, green: 0.83, blue: 0.37, alpha: 1)),
        .init(name: "Orange", color: .init(red: 1, green: 0.64, blue: 0, alpha: 1)),
        .init(name: "Melon", color: .init(red: 0.04, green: 0.41, blue: 0, alpha: 1)),
        .init(name: "Strawberry", color: .init(red: 1, green: 0, blue: 0, alpha: 1)),
    ]

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width < 600 {
                VStack {
                    Spacer()
                    Text("This app has to be experienced in fullscreen")
                        .font(.title)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding()
            } else {
                NavigationStack(path: $navigationStack) {
                    FrontpageView { newState in
                        guard navigationStack.last != newState else {
                            return
                        }
                        navigationStack.append(newState)
                    }
                    .navigationBarHidden(true)
                    .navigationTitle("Frontpage")
                    .navigationDestination(for: PresentableViews.self) { state in
                        switch state {
                        case .firstPastThePost:
                            FPTPVisualization(candidates: candidates)
                                .navigationTitle("First Past The Post")
                                .navigationBarTitleDisplayMode(.inline)
                        case .stv:
                            SingleTransferableVoteVisualization(candidates: candidates)
                                .navigationTitle("Single Transferable Vote")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
                .font(.system(.title3, design: .rounded))
            }
        }
    }
}
