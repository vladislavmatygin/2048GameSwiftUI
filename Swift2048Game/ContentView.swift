import SwiftUI

struct ContentView: View {
    var gameLogic: GameLogic = .init()

    var body: some View {
        GameView()
            .environmentObject(gameLogic)
    }
}

#Preview {
    ContentView()
}
