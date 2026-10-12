import SwiftUI
import SpriteKit

/// Emergency distraction tab — a fully playable Flappy Bird game, embedded
/// natively with SpriteKit. Best score is saved on this phone only.
struct DistractView: View {
    @ObservedObject var store: Store
    let s: AppStrings
    let lang: String
    let goTo: (AppTab) -> Void

    var scene: SKScene {
        let scene = FlappyGameScene()
        scene.size = CGSize(width: 400, height: 640)
        scene.scaleMode = .aspectFill
        return scene
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle(text: "🎮 " + s.distractTitle)
            Text(s.distractBody).font(.body).foregroundColor(.warmGray)
                .padding(.bottom, 14)

            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .frame(maxWidth: .infinity)
                .aspectRatio(400.0 / 640.0, contentMode: .fit)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.deepTeal.opacity(0.25), lineWidth: 1)
                )

            RecoveryCard {
                Text("⏱️ " + s.distractTip)
                    .font(.body).foregroundColor(.warmGray)
            }
            .padding(.top, 14)

            Footer(store: store, s: s) { goTo(.distract) }
        }
    }
}
