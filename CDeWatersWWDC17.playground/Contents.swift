import Cocoa
import PlaygroundSupport
import SpriteKit

let skView = GameView(frame: CGRect(x: 0, y: 0, width: 728, height: 728))
skView.layer?.backgroundColor = sceneBackgroundColor.cgColor

skView.showsPhysics = false

Rink.shared.scaleMode = .aspectFill
skView.presentScene(Rink.shared)

//Adding the scoreboard
Scoreboard.shared = Scoreboard(frame: NSRect(x: 20, y: skView.frame.maxY - 50, width: 250, height: 30))
skView.addSubview(Scoreboard.shared)


PlaygroundPage.current.liveView = skView
