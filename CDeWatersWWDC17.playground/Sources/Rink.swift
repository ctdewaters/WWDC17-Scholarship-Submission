import SpriteKit
import UIKit
import GameplayKit

public let rinkSize = CGSize(width: 513, height: 1024)
public let rinkCenterCircleWidth: CGFloat = 155

public let sceneBackgroundColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)

public struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let puck   : UInt32 = 0b1 // 1
    static let player: UInt32 = 0b10 // 2
    static let rink: UInt32 = 0b11 // 3
}


open class Rink: SKScene, JoystickDelegate, SwitchPlayerButtonDelegate, SKPhysicsContactDelegate {
    
    open var userTeam: UserTeam?
    open var opposingTeam: Team?
    open var puck: PuckNode?
    
    fileprivate var latestJoystickData: JoystickData?
    
    //Returns the selected player on the user controlled team
    fileprivate var selectedPlayer: UnsafeMutablePointer<UserPlayerNode>? {
        if let userTeam = userTeam {
            for player in userTeam {
                if player.isSelected {
                    let pointer = UnsafeMutablePointer<UserPlayerNode>.allocate(capacity: 1)
                    pointer.pointee = player
                    return pointer
                }
            }
        }
        return nil
    }
    
    //Returns the player on either team that is currently carrying the puck
    fileprivate var userPuckCarrier: UnsafeMutablePointer<UserPlayerNode>? {
        if let userTeam = userTeam {
            for player in userTeam {
                if player.playerNode.hasPuck {
                    let pointer = UnsafeMutablePointer<UserPlayerNode>.allocate(capacity: 1)
                    pointer.pointee = player
                    return pointer
                }
            }
        }
        return nil
    }
    
    fileprivate var opposingPuckCarrier: UnsafeMutablePointer<PlayerNode>? {
        if let opposingTeam = opposingTeam {
            for player in opposingTeam {
                if player.hasPuck {
                    let pointer = UnsafeMutablePointer<PlayerNode>.allocate(capacity: 1)
                    pointer.pointee = player
                    return pointer
                }
            }
        }
        return nil
    }

    //The camera for the scene
    let cameraNode: SKCameraNode = SKCameraNode()
    
    fileprivate var backgroundNode: SKSpriteNode!
        
    public override init(size: CGSize) {
        super.init(size: size)
        
        //Setting anchor point in the center
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.backgroundNode = SKSpriteNode(imageNamed: "rinkBackground.png")
        self.backgroundNode.size = size
        self.addChild(self.backgroundNode)
        
        self.backgroundColor = sceneBackgroundColor
        
        
        //Adding the camera
        self.addChild(cameraNode)
        camera = cameraNode
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    //Sets the physics body shape, gravity, and contact properties
    open func setPhysicsWorld() {
        self.physicsWorld.gravity = CGVector.zero
        self.position = CGPoint(x: 0, y: 0)
        self.physicsWorld.contactDelegate = self
        
        let pathFrame = CGRect(x: (self.frame.origin.y + rinkSize.width / 4) - 16, y: self.frame.origin.y - 143, width: rinkSize.width, height: rinkSize.height)
        let bezierPath = UIBezierPath(roundedRect: pathFrame, cornerRadius: rinkSize.width / 4)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: bezierPath.cgPath)
        self.physicsBody?.categoryBitMask = PhysicsCategory.rink
        self.physicsBody?.collisionBitMask = PhysicsCategory.all
        self.physicsBody?.contactTestBitMask =  PhysicsCategory.puck
    }
    
    //Generates and adds nodes for both teams, the puck, and the rink
    open func generateAndAddNodes(withTeamSize teamSize: TeamSize = .five, andHomeTeamColor homeColor: SKColor = .red) {
        generateTeams(withPlayers: teamSize.intVal, andHomeTeamColor: homeColor)
        add(userTeam!)
        add(opposingTeam!)
        generateAndAddPuck()
    }
    
    fileprivate func generateTeams(withPlayers playerCount: Int, andHomeTeamColor homeColor: SKColor) {
        userTeam = UserTeam()
        opposingTeam = Team()
        
        //Generate team 1 (user team)
        for i in 0..<playerCount {
            let player = UserPlayerNode(withColor: homeColor, andPosition: PlayerPosition(rawValue: i)!)
            player.playerNode.isOnOpposingTeam = false
            userTeam?.append(player)
        }
        
        //Generate team 2 (opposing team)
        for i in 0..<playerCount {
            let player = PlayerNode(withColor: .white, andPosition: PlayerPosition(rawValue: i)!)
            player.isOnOpposingTeam = true
            opposingTeam?.append(player)
        }
    }
    
    ///Adds opposing teams players to the ice
    fileprivate func add(_ team: Team) {
        for player in team {
            player.position = self.position(forPlayer: player, atFaceoffLocation: .centerIce)
            player.rotate(toFacePoint: FaceoffLocation.centerIce.coordinate, withDuration: 0.25)
            self.addChild(player)
        }
    }
    
    ///Adds user teams players to the ice
    fileprivate func add(_ userTeam: UserTeam) {
        for player in userTeam {
            player.position = self.position(forPlayer: player.playerNode, atFaceoffLocation: .centerIce)
            player.rotate(toFacePoint: FaceoffLocation.centerIce.coordinate, withDuration: 0.25)
            self.addChild(player)
        }
    }
    
    
    fileprivate func generateAndAddPuck() {
        self.puck = PuckNode()
        self.puck?.position = CGPoint(x: 0, y: 0)
        self.addChild(puck!)
        
        self.cameraNode.position = (self.puck?.position)!
    }
    
    public func positionPlayers(atFaceoffLocation location: FaceoffLocation) {
        for player in userTeam! {
            player.rotate(toFacePoint: location.coordinate, withDuration: 0.1)
            player.position = position(forPlayer: player.playerNode, atFaceoffLocation: location)
        }
        for player in opposingTeam! {
            player.rotate(toFacePoint: location.coordinate, withDuration: 0.1)
            player.position = position(forPlayer: player, atFaceoffLocation: location)
        }
    }
    
    //Computes position to set player for a faceoff location
    fileprivate func position(forPlayer player: PlayerNode, atFaceoffLocation location: FaceoffLocation) -> CGPoint {
        return location.playerPosition(forPlayerNode: player)
    }
    
    open func selectPlayerClosestToPuck() {
        if var userTeam = userTeam {
            userTeam = userTeam.sorted(by: {
                player1, player2 in
                return player1.distance(fromNode: self.puck!) < player2.distance(fromNode: self.puck!)
            })
            
            //Deselect currently selected player
            if let selectedPlayer = selectedPlayer {
                selectedPlayer.pointee.deselect()
            }
            
            //Select the player
            if !userTeam[0].isSelected {
                userTeam[0].select()
            }
            else {
                userTeam[1].select()
            }
        }
    }
    
    open override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        //Check if we have joystick data
        if let joystickData = latestJoystickData, let selectedPlayer = selectedPlayer {
            selectedPlayer.pointee.move(withJoystickData: joystickData)
        }
        
        //Follow puck location
        updateCameraPosition()
    }
    
    fileprivate func updateCameraPosition(toPosition position: CGPoint? = nil) {
        var point: CGPoint!
        if let position = position {
            point = position
        }
        else if let userPuckCarrier = userPuckCarrier {
            point = userPuckCarrier.pointee.position
        }
        else if let opposingPuckCarrier = opposingPuckCarrier {
            point = opposingPuckCarrier.pointee.position
        }
        else if let puck = puck {
            //calculate point to move camera to
            point = puck.position
        }
        
        //Keeping view on the ice
        if point.x < -180 {
            point.x = -180
        }
        else if point.x > 180 {
            point.x = 180
        }
        if point.y > 380 {
            point.y = 380
        }
        else if point.y < -380 {
            point.y = -380
        }

        let action = SKAction.move(to: point, duration: 0.25)
        cameraNode.run(action)

    }
    
    public func faceoffDotCoordinate(forLocation location: FaceoffLocation) -> CGPoint {
        return location.coordinate
    }
    
    //MARK: - SKPhysicsContactDelegate
    public func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        
        if bodyA.categoryBitMask == PhysicsCategory.rink && bodyB.categoryBitMask == PhysicsCategory.puck {
            //Puck hit the boards
            //SoundEffectPlayer.boards.play(soundEffect: .puckHitBoards)
        }
        
        if bodyA.categoryBitMask == PhysicsCategory.player && bodyB.categoryBitMask == PhysicsCategory.puck {
            //Puck hit player
            
            if let playerNode = bodyA.node as? UserPlayerNode {
                playerNode.playerNode.pickUp(puck: &self.puck!)
            }
            
            
        }
    }
    
    public func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    //MARK: - JoystickDelegate
    
    public func joystickDidExitIdle(_ joystick: Joystick) {
        if let selectedPlayer = selectedPlayer {
            selectedPlayer.pointee.playerNode.animateSkatingTextures()
        }
    }
    
    public func joystick(_ joystick: Joystick, didGenerateData joystickData: JoystickData) {
        self.latestJoystickData = joystickData
    }
    
    public func joystickDidReturnToIdle(_ joystick: Joystick) {
        self.latestJoystickData = nil
        
        if let selectedPlayer = selectedPlayer {
            selectedPlayer.pointee.playerNode.stopSkatingAction()
            selectedPlayer.pointee.playerNode.texture = faceoffTexture
            selectedPlayer.pointee.applySkatingImpulse()
        }
    }
    
    //MARK: - SwitchPlayerButtonDelegate
    
    public func buttonDidRecieveUserInput(switchPlayerButton button: SwitchPlayerButton) {
        self.selectPlayerClosestToPuck()
    }
}

//Pair of SKPhysicsBodies
fileprivate class PhysicsBodyPair {
    var bodyA, bodyB: SKPhysicsBody!
    
    init(a: SKPhysicsBody, andB b: SKPhysicsBody) {
        self.bodyA = a
        self.bodyB = b
    }
}

//Faceoff locations on the playing surface
public enum FaceoffLocation {
    case offsideTopRight, offsideTopLeft, offsideBottomRight, offsideBottomLeft, centerIce
    
    public var coordinate: CGPoint {
        switch self {
        case .offsideTopRight :
            return CGPoint(x: 126, y: 147)
        case .offsideTopLeft :
            return CGPoint(x: -126, y: 147)
        case .offsideBottomRight :
            return CGPoint(x: 126, y: -147)
        case .offsideBottomLeft :
            return CGPoint(x: -126, y: -147)
        case .centerIce :
            return CGPoint(x: 0, y: 0)
        }
    }
    
    public var isOffsideLocation: Bool {
        switch self {
        case .offsideTopLeft, .offsideTopRight, .offsideBottomLeft, .offsideBottomRight :
            return true
        default :
            return false
        }
    }
    
    public func playerPosition(forPlayerNode player: PlayerNode) -> CGPoint {
        var point = self.coordinate
        
        //Check if player is on opposing team
        if player.isOnOpposingTeam == true {
            if player.playerPosition.isForward {
                point.y += player.frame.height / 1.9
                
                if player.playerPosition == .leftWing {
                    point.x += rinkCenterCircleWidth / 2
                }
                else if player.playerPosition == .rightWing {
                    point.x -= rinkCenterCircleWidth / 2
                }
            }
            else if player.playerPosition.isDefenseman {
                point.y += rinkCenterCircleWidth / 2
                if player.playerPosition == .leftDefense {
                    point.x -= rinkCenterCircleWidth / 3
                }
                else {
                    point.x += rinkCenterCircleWidth / 3
                }
            }
            
            return point
        }
        
        //Player is on the user controlled team
        
        if player.playerPosition.isForward {
            point.y -= player.frame.height / 1.9
            
            if player.playerPosition == .leftWing {
                point.x -= rinkCenterCircleWidth / 2
            }
            else if player.playerPosition == .rightWing {
                point.x += rinkCenterCircleWidth / 2
            }
        }
        else if player.playerPosition.isDefenseman {
            point.y -= rinkCenterCircleWidth / 2
            if player.playerPosition == .leftDefense {
                point.x -= rinkCenterCircleWidth / 3
            }
            else {
                point.x += rinkCenterCircleWidth / 3
            }
        }
        
        return point
    }
}
