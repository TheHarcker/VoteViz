# VoteViz
 
My winning submission for Apple's annual [Swift Student Challenge](https://developer.apple.com/wwdc23/swift-student-challenge/).

# Running
The app can be run using Swift Playgrounds on iPad and Mac, as well as in Xcode on Mac.

# Description
Fair elections are a cornerstone of modern democracies, but not every electoral system is created equal. This app, VoteViz, explores and teaches its users about two ends of the spectrum: that is, “First Past The Post,” where a majority of the majority rules, and “Single Transferable Vote” where the candidates/parties that the most people can accept, win. The two systems are explored through interactive random elections where the user can tweak different parameters. As these systems work regardless of local conditions, the app is relevant worldwide. 

## Technical description
This app uses SwiftUI and SFSymbols to create an engaging and dynamic user interface that allows the user to experiment with different electoral systems and see how much the choice of system affects the outcome of the election. SwiftCharts is used to create one of these visualizations and to highlight an extreme case.
Due to the lack of support for non-Swift Targets in App Playgrounds, I could not use Swift Collections. Instead, I have implemented my own ordered-dictionary for quick and ordered lookup of candidates.
