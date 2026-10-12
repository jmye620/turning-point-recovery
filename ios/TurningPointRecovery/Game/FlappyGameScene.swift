import SpriteKit
import AVFoundation

class FlappyGameScene: SKScene, SKPhysicsContactDelegate {

    enum State { case ready, playing, over }

    struct Physics {
        static let bird:   UInt32 = 0x1 << 0
        static let pipe:   UInt32 = 0x1 << 1
        static let ground: UInt32 = 0x1 << 2
        static let score:  UInt32 = 0x1 << 3
    }

    // Tuning (art is 2x the original 288x512 pixel art)
    let artScale: CGFloat = 2.0
    let pipeSpeed: CGFloat = 215
    let pipeGap: CGFloat = 255
    let pipeSpacing: CGFloat = 430
    let flapVelocity: CGFloat = 640
    let gravityY: CGFloat = -2150

    var state: State = .ready
    var bird: SKSpriteNode!
    var birdFrames: [SKTexture] = []
    var groundH: CGFloat = 150
    var score = 0
    var best: Int { get { UserDefaults.standard.integer(forKey: "flappy_best") } }
    var scoreLabel: SKNode!
    var uiLayer: SKNode!
    var panel: SKNode?
    var distanceSincePipe: CGFloat = 0
    var players: [String: AVAudioPlayer] = [:]
    var dead = false

    // MARK: - Setup

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: gravityY)
        physicsWorld.contactDelegate = self
        groundH = max(120, size.height * 0.17)
        loadSounds()
        buildBackground()
        buildGround()
        buildBird()
        buildScoreLabel()
        showReady()
    }

    func tex(_ name: String) -> SKTexture {
        let t = SKTexture(imageNamed: name)
        t.filteringMode = .nearest
        return t
    }

    func loadSounds() {
        for s in ["wing", "point", "hit", "die", "swooshing"] {
            if let url = Bundle.main.url(forResource: s, withExtension: "m4a") {
                players[s] = try? AVAudioPlayer(contentsOf: url)
                players[s]?.prepareToPlay()
            }
        }
    }

    func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    func buildBackground() {
        let t = tex("bg_day")
        let s = max(size.width / t.size().width, size.height / t.size().height)
        let bg = SKSpriteNode(texture: t)
        bg.size = CGSize(width: t.size().width * s, height: t.size().height * s)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)
    }

    func buildGround() {
        let t = tex("ground")
        let h = groundH
        let w = t.size().width * (h / t.size().height)
        // two tiles side by side, recycled in update()
        for i in 0..<3 {
            let g = SKSpriteNode(texture: t)
            g.size = CGSize(width: w, height: h)
            g.anchorPoint = CGPoint(x: 0, y: 0)
            g.position = CGPoint(x: CGFloat(i) * w, y: 0)
            g.zPosition = 5
            g.name = "ground"
            let body = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h),
                                     center: CGPoint(x: w / 2, y: h / 2))
            body.isDynamic = false
            body.categoryBitMask = Physics.ground
            body.contactTestBitMask = Physics.bird
            body.collisionBitMask = Physics.bird
            g.physicsBody = body
            addChild(g)
            groundNodes.append(g)
        }
    }
    var groundNodes: [SKSpriteNode] = []

    func buildBird() {
        birdFrames = [tex("bird_0"), tex("bird_1"), tex("bird_2")]
        bird = SKSpriteNode(texture: birdFrames[0])
        let s = birdFrames[0].size()
        bird.size = CGSize(width: s.width * artScale, height: s.height * artScale)
        bird.position = CGPoint(x: size.width * 0.35, y: size.height * 0.6)
        bird.zPosition = 4
        let body = SKPhysicsBody(circleOfRadius: bird.size.width * 0.32)
        body.categoryBitMask = Physics.bird
        body.contactTestBitMask = Physics.pipe | Physics.ground | Physics.score
        body.collisionBitMask = Physics.ground
        body.allowsRotation = false
        bird.physicsBody = body
        addChild(bird)
    }

    func buildScoreLabel() {
        scoreLabel = SKNode()
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 110)
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        renderScore()
    }

    func renderScore() {
        scoreLabel.removeAllChildren()
        let digits = Array(String(score))
        let texs = digits.map { tex("num_\($0)") }
        let widths = texs.map { $0.size().width * artScale }
        let total = widths.reduce(0, +) + CGFloat(digits.count - 1) * 6
        var x = -total / 2
        for (t, w) in zip(texs, widths) {
            let n = SKSpriteNode(texture: t)
            n.size = CGSize(width: w, height: t.size().height * artScale)
            n.position = CGPoint(x: x + w / 2, y: 0)
            scoreLabel.addChild(n)
            x += w + 6
        }
    }

    // MARK: - Screens

    func showReady() {
        state = .ready
        scoreLabel.isHidden = true
        uiLayer = SKNode()
        uiLayer.zPosition = 30
        addChild(uiLayer)
        let title = SKSpriteNode(texture: tex("getready"))
        let ts = title.texture!.size()
        title.size = CGSize(width: ts.width * artScale, height: ts.height * artScale)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        uiLayer.addChild(title)
        bird.position = CGPoint(x: size.width * 0.35, y: size.height * 0.55)
        bird.physicsBody?.isDynamic = false
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 14, duration: 0.4),
            SKAction.moveBy(x: 0, y: -14, duration: 0.4)])
        bird.run(SKAction.repeatForever(bob), withKey: "bob")
        animateBird()
        play("swooshing")
    }

    func startPlay() {
        state = .playing
        scoreLabel.isHidden = false
        uiLayer.removeFromParent()
        bird.removeAction(forKey: "bob")
        bird.physicsBody?.isDynamic = true
        animateBird()
        distanceSincePipe = pipeSpacing // spawn first pipe soon
    }

    func animateBird() {
        bird.removeAction(forKey: "flap")
        let anim = SKAction.animate(with: birdFrames, timePerFrame: 0.12)
        bird.run(SKAction.repeatForever(anim), withKey: "flap")
    }

    func gameOver(hitGround: Bool) {
        guard !dead else { return }
        dead = true
        state = .over
        play("hit")
        bird.removeAction(forKey: "flap")
        // white flash
        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 40
        flash.alpha = 0
        addChild(flash)
        flash.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.9, duration: 0.08),
                                     SKAction.fadeOut(withDuration: 0.4),
                                     SKAction.removeFromParent()]))
        // bird keeps falling via physics; only the ground can touch it now
        // (update() stops scrolling pipes/ground once dead == true)
        bird.physicsBody?.contactTestBitMask = Physics.ground
        bird.physicsBody?.collisionBitMask = Physics.ground
        if !hitGround {
            run(SKAction.sequence([SKAction.wait(forDuration: 0.45),
                                   SKAction.run { [weak self] in self?.play("die") }]))
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.9),
                               SKAction.run { [weak self] in self?.showPanel() }]))
    }

    func showPanel() {
        play("swooshing")
        let layer = SKNode()
        layer.zPosition = 30
        addChild(layer)
        panel = layer

        let title = SKSpriteNode(texture: tex("gameover"))
        let ts = title.texture!.size()
        title.size = CGSize(width: ts.width * artScale, height: ts.height * artScale)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        title.setScale(0.01)
        layer.addChild(title)
        title.run(SKAction.scale(to: 1.0, duration: 0.25))

        let ptex = tex("panel")
        let ps = ptex.size()
        let panelNode = SKSpriteNode(texture: ptex)
        panelNode.size = CGSize(width: ps.width * artScale, height: ps.height * artScale)
        panelNode.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        layer.addChild(panelNode)

        // medal
        let medalName: String?
        if score >= 40 { medalName = "medal_platinum" }
        else if score >= 30 { medalName = "medal_gold" }
        else if score >= 20 { medalName = "medal_silver" }
        else if score >= 10 { medalName = "medal_bronze" }
        else { medalName = nil }
        if let mn = medalName {
            let m = SKSpriteNode(texture: tex(mn))
            let ms = m.texture!.size()
            m.size = CGSize(width: ms.width * artScale, height: ms.height * artScale)
            m.position = CGPoint(x: panelNode.position.x - panelNode.size.width * 0.28,
                                 y: panelNode.position.y - 8)
            layer.addChild(m)
        }

        // score + best digits on panel
        drawNumber(score, at: CGPoint(x: panelNode.position.x + panelNode.size.width * 0.32,
                                      y: panelNode.position.y + 38), in: layer, scale: 1.4)
        let isBest = score > best && score > 0
        if isBest { UserDefaults.standard.set(score, forKey: "flappy_best") }
        drawNumber(isBest ? score : best,
                   at: CGPoint(x: panelNode.position.x + panelNode.size.width * 0.32,
                               y: panelNode.position.y - 52), in: layer, scale: 1.4)
        if isBest {
            let nb = SKSpriteNode(texture: tex("new_badge"))
            let ns = nb.texture!.size()
            nb.size = CGSize(width: ns.width * artScale, height: ns.height * artScale)
            nb.position = CGPoint(x: panelNode.position.x + panelNode.size.width * 0.05,
                                  y: panelNode.position.y - 52)
            layer.addChild(nb)
        }

        // buttons
        let playB = SKSpriteNode(texture: tex("btn_play"))
        let bs = playB.texture!.size()
        playB.size = CGSize(width: bs.width * 1.6, height: bs.height * 1.6)
        playB.position = CGPoint(x: size.width / 2 - 110, y: size.height * 0.22)
        playB.name = "btn_play"
        layer.addChild(playB)
        let menuB = SKSpriteNode(texture: tex("btn_menu"))
        let ms2 = menuB.texture!.size()
        menuB.size = CGSize(width: ms2.width * 1.6, height: ms2.height * 1.6)
        menuB.position = CGPoint(x: size.width / 2 + 110, y: size.height * 0.22)
        menuB.name = "btn_menu"
        layer.addChild(menuB)
    }

    func drawNumber(_ value: Int, at pos: CGPoint, in layer: SKNode, scale: CGFloat) {
        let digits = Array(String(value))
        let texs = digits.map { tex("num_\($0)") }
        let widths = texs.map { $0.size().width * scale }
        let total = widths.reduce(0, +) + CGFloat(digits.count - 1) * 4
        var x = pos.x - total / 2
        for (t, w) in zip(texs, widths) {
            let n = SKSpriteNode(texture: t)
            n.size = CGSize(width: w, height: t.size().height * scale)
            n.position = CGPoint(x: x + w / 2, y: pos.y)
            layer.addChild(n)
            x += w + 4
        }
    }

    func restart() {
        // remove pipes, score triggers, panel
        for child in children where child.name == "pipe" || child.name == "score" { child.removeFromParent() }
        panel?.removeFromParent()
        panel = nil
        score = 0
        dead = false
        renderScore()
        bird.position = CGPoint(x: size.width * 0.35, y: size.height * 0.6)
        bird.zRotation = 0
        bird.physicsBody?.velocity = .zero
        showReady()
    }

    // MARK: - Pipes

    func spawnPipePair() {
        let pipeW: CGFloat = 52 * artScale
        let capH: CGFloat = 26 * artScale
        let minCenter = groundH + 90 + pipeGap / 2
        let maxCenter = size.height - 90 - pipeGap / 2
        guard minCenter < maxCenter else { return }
        let gapY = CGFloat.random(in: minCenter...maxCenter)
        let x = size.width + pipeW

        let bodyTex = tex("pipe_body")
        let capTex = tex("pipe_cap")

        // bottom pipe: ground -> gap bottom
        let botTop = gapY - pipeGap / 2
        let botH = botTop - groundH
        if botH > 0 {
            addPipePart(texture: bodyTex, width: pipeW, height: botH, x: x,
                        bottomY: groundH, capAtTop: true, capTex: capTex, capH: capH)
        }
        // top pipe: gap top -> sky
        let topBottom = gapY + pipeGap / 2
        let topH = size.height - topBottom
        if topH > 0 {
            addPipePart(texture: bodyTex, width: pipeW, height: topH, x: x,
                        bottomY: topBottom, capAtTop: false, capTex: capTex, capH: capH)
        }
        // score trigger
        let trigger = SKNode()
        trigger.name = "score"
        trigger.position = CGPoint(x: x, y: gapY)
        let sbody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height: pipeGap))
        sbody.isDynamic = false
        sbody.categoryBitMask = Physics.score
        sbody.contactTestBitMask = Physics.bird
        sbody.collisionBitMask = 0
        trigger.physicsBody = sbody
        addChild(trigger)
    }

    func addPipePart(texture: SKTexture, width: CGFloat, height: CGFloat, x: CGFloat,
                     bottomY: CGFloat, capAtTop: Bool, capTex: SKTexture, capH: CGFloat) {
        let holder = SKNode()
        holder.name = "pipe"
        holder.position = CGPoint(x: x, y: 0)
        holder.zPosition = 3

        let bodyH = max(height - capH, 20)
        let body = SKSpriteNode(texture: texture)
        body.size = CGSize(width: width, height: bodyH)
        let bodyBottom = capAtTop ? bottomY : bottomY + capH
        body.position = CGPoint(x: 0, y: bodyBottom + bodyH / 2)

        let cap = SKSpriteNode(texture: capTex)
        cap.size = CGSize(width: width, height: capH)
        let capY = capAtTop ? (bottomY + height - capH / 2) : (bottomY + capH / 2)
        cap.position = CGPoint(x: 0, y: capY)

        let physH = height
        let phys = SKPhysicsBody(rectangleOf: CGSize(width: width - 8, height: physH),
                                 center: CGPoint(x: 0, y: bottomY + physH / 2))
        phys.isDynamic = false
        phys.categoryBitMask = Physics.pipe
        phys.contactTestBitMask = Physics.bird
        phys.collisionBitMask = 0
        holder.physicsBody = phys

        holder.addChild(body)
        holder.addChild(cap)
        addChild(holder)
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        switch state {
        case .ready:
            startPlay()
            flap()
        case .playing:
            flap()
        case .over:
            guard let panel = panel else { return }
            for node in panel.nodes(at: p) {
                if node.name == "btn_play" { play("swooshing"); restart(); return }
                if node.name == "btn_menu" { play("swooshing"); restart(); return }
            }
        }
    }

    func flap() {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: flapVelocity)
        play("wing")
        // tilt is handled per-frame in update()
    }

    // MARK: - Physics

    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask & Physics.score != 0 {
            if state == .playing && !dead {
                if contact.bodyA.categoryBitMask == Physics.score {
                    contact.bodyA.node?.removeFromParent()
                } else {
                    contact.bodyB.node?.removeFromParent()
                }
                score += 1
                renderScore()
                play("point")
            }
            return
        }
        if dead { return }
        if mask & Physics.ground != 0 {
            gameOver(hitGround: true)
        } else if mask & Physics.pipe != 0 {
            gameOver(hitGround: false)
        }
    }

    // MARK: - Frame

    override func update(_ currentTime: TimeInterval) {
        guard state == .playing && !dead else {
            if state == .ready { return }
            return
        }
        // scroll ground
        let dx = pipeSpeed * (1.0 / 60.0)
        for g in groundNodes {
            g.position.x -= dx
            let w = g.size.width
            if g.position.x <= -w { g.position.x += w * CGFloat(groundNodes.count) }
        }
        // scroll pipes + score triggers
        for child in children where child.name == "pipe" || child.name == "score" {
            child.position.x -= dx
            if child.position.x < -120 { child.removeFromParent() }
        }
        distanceSincePipe += dx
        if distanceSincePipe >= pipeSpacing {
            distanceSincePipe = 0
            spawnPipePair()
        }
        // bird tilt
        if let v = bird.physicsBody?.velocity.dy {
            let target = v > 0 ? 0.35 : max(-1.35, v / 900 * 0.9)
            let cur = bird.zRotation
            bird.zRotation = cur + (target - cur) * 0.18
        }
        // fell below screen (safety)
        if bird.position.y < -60 { gameOver(hitGround: true) }
    }
}
