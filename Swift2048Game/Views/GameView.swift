import SwiftUI

extension Edge {

    static func from(_ from: GameLogic.Direction) -> Self {
        switch from {
        case .down:
            return .top
        case .up:
            return .bottom
        case .left:
            return .trailing
        case .right:
            return .leading
        }
    }

}

struct GameView : View {

    @State var ignoreGesture = false
    @EnvironmentObject var gameLogic: GameLogic

    fileprivate struct LayoutTraits {
        let bannerOffset: CGSize
        let showsBanner: Bool
        let containerAlignment: Alignment
    }

    fileprivate func layoutTraits(`for` proxy: GeometryProxy) -> LayoutTraits {
        let landscape = proxy.size.width > proxy.size.height

        return LayoutTraits(
            bannerOffset: landscape
                ? .init(width: 32, height: 0)
                : .init(width: 0, height: 32),
            showsBanner: landscape ? proxy.size.width > 720 : proxy.size.height > 550,
            containerAlignment: landscape ? .leading : .top
        )
    }

    var gestureEnabled: Bool {
        return true
    }

    var gesture: some Gesture {
        let threshold: CGFloat = 44
        let drag = DragGesture()
            .onChanged { v in
                guard !self.ignoreGesture else { return }

                guard abs(v.translation.width) > threshold ||
                    abs(v.translation.height) > threshold else {
                    return
                }

                withTransaction(Transaction(animation: .spring())) {
                    self.ignoreGesture = true

                    if v.translation.width > threshold {
                        self.gameLogic.move(.right)
                    } else if v.translation.width < -threshold {
                        self.gameLogic.move(.left)
                    } else if v.translation.height > threshold {
                        self.gameLogic.move(.down)
                    } else if v.translation.height < -threshold {
                        self.gameLogic.move(.up)
                    }
                }
            }
            .onEnded { _ in
                self.ignoreGesture = false
            }
        return drag
    }

    var content: some View {
        GeometryReader { proxy in
            bind(self.layoutTraits(for: proxy)) { layoutTraits in
                ZStack(alignment: layoutTraits.containerAlignment) {
                    if layoutTraits.showsBanner {
                        Text("2048")
                            .font(Font.system(size: 48).weight(.black))
                            .foregroundColor(Color(red:0.47, green:0.43, blue:0.40, opacity:1.00))
                            .offset(layoutTraits.bannerOffset)
                    }

                    ZStack(alignment: .center) {
                        BlockGridView(matrix: self.gameLogic.blockMatrix,
                                      blockEnterEdge: .from(self.gameLogic.lastGestureDirection))
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .background(
                    Rectangle()
                        .fill(Color(red:0.96, green:0.94, blue:0.90, opacity:1.00))
                        .edgesIgnoringSafeArea(.all)
                )
            }
        }
    }

    var body: AnyView {
        return gestureEnabled ? (
            content
                .gesture(gesture, including: .all).eraseToAnyView()
        ) : content.eraseToAnyView()
    }

}

func bind<T, U>(_ x: T, _ closure: (T) -> U) -> U {
    return closure(x)
}

// MARK: - Previews

#if DEBUG
struct GameView_Previews : PreviewProvider {

    static var previews: some View {
        GameView()
            .environmentObject(GameLogic())
    }

}
#endif
