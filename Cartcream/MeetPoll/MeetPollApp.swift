import SwiftUI

@main
struct MeetPollApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Text("MeetPoll")
                    .font(.largeTitle)
                Text("This is the container app for the Messages extension.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
