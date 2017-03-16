
import UIKit
import SpriteKit
import PlaygroundSupport

/*:
 # Creating a 2D Hockey Game Using SpriteKit

 ## Creating the View:
 First we create our `SKView` using `CGRect` to define its position and size. Then we initialize our `Rink` and set its background color and physics world attributes. The `Rink` is then presented to the view.
 */
let skView = SKView(frame: CGRect(x: 0, y: 0, width: 414, height: 736))
skView.contentMode = .scaleToFill
skView.backgroundColor = sceneBackgroundColor
skView.showsFields = true
skView.showsPhysics = true

let rink = Rink(size: CGSize(width: 728, height: 1024))
rink.scaleMode = .resizeFill
skView.presentScene(rink)
/*:
 Next, we will set up the physics world for our `rink`. This function sets the shape of it's `physicsBody` to that of its texture, and this will keep both the players and the puck in play.
 */
rink.setPhysicsWorld()
/*:
 ## Adding to the `Rink`'s World:
 
 `Rink`'s function `generateAndAddNodes` creates nodes for both teams, the puck, and the rink, and adds them to the scene. This function can take an argument of type `TeamSize`, which defines the amount of players on each team (this defaults to `five` if no argument is passed), and `SKColor`, which defines the color of the players on the "home" team (this defaults to `red`).
 */
rink.generateAndAddNodes(withTeamSize: TeamSize.five, andHomeTeamColor: SKColor.red)
rink.puck?.position = FaceoffLocation.centerIce.coordinate
rink.positionPlayers(atFaceoffLocation: .centerIce)

let action = SKAction.applyImpulse(CGVector(dx: 30, dy: 5), duration: 0.5)
rink.puck?.run(action)

rink.selectPlayerClosestToPuck()

let joystick = Joystick(frame: CGRect(x: 20, y: skView.frame.maxY - joystickSize - 20, width: joystickSize, height: joystickSize))
joystick.delegate = rink
skView.addSubview(joystick)

PlaygroundPage.current.liveView = skView

