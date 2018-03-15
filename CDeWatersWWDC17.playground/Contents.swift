//: # Creating a 2D Hockey Game
//: ## Using GameplayKit and SpriteKit
import Cocoa
import PlaygroundSupport
import SpriteKit
//: ## Creating the `GameView`.
//: First, we create our `GameView`, which is a subclass of `SKView`.
//: We set it's `frame` and background color.
let skView = GameView(frame: CGRect(x: 0, y: 0, width: 728, height: 728))
skView.layer?.backgroundColor = sceneBackgroundColor.cgColor
//: ## Creating the `Rink`.
//: We set the `scaleMode` of the shared `Rink` object, and present it to the scene.
Rink.shared.scaleMode = .aspectFill
skView.presentScene(Rink.shared)

//: ## Adding the nodes to the `Rink`.
//: This function adds all of the players, the nets, and the puck to the `Rink`. We can also specify a color for the home team players.
Rink.shared.generateAndAddNodes(withTeamSize: .five, andHomeTeamColor: .red)

//: ## Adding the scoreboard
//: We create the amount of time we want the game to last, set the shared
//: `Scoreboard` frame, and add it to `skView`.
let time = TimeInterval(withMinutes: 2, andSeconds: 0)
Scoreboard.shared = Scoreboard(frame: NSRect(x: 20, y: skView.frame.maxY - 50, width: 250, height: 30), withTotalTime: time)
skView.addSubview(Scoreboard.shared)

//: ## Set the Playground's `liveView`.
PlaygroundPage.current.liveView = skView
