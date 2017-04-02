//
//  PlayerEntity.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/25/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol PlayerDelegate {
    func playerDidPickUpPuck(_ player: Player)
    func playerDidReleasePuck(_ player: Player)
}

public class Player: GKEntity {
        
    var pPosition: PlayerPosition!
    public var isOnOpposingTeam = false
    
    var delegate: PlayerDelegate?
    
    ///Creates a Player instance with a specified color (defaults to white), and PlayerPosition.
    public init(withColor color: SKColor = .white, andPosition playerPosition: PlayerPosition) {
        super.init()
        
        self.delegate = Rink.shared
        
        //Setting the player's position
        self.pPosition = playerPosition
        
        let playerComponent = PlayerComponent(withColor: color, andTexture: PlayerTexture.faceoff)
        self.addComponent(playerComponent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Adds a MoveComponent to the player.
    public func addMovement() {
        self.playerComponent?.animateSkatingTextures()
        let moveComponent = MoveComponent(maxSpeed: 150, maxAcceleration: 100, radius: Float(playerNodeSize.width / 2), mass: 0.3, withBehaviorType: .chasePuck)
        self.addComponent(moveComponent)
    }
    
    ///Updates the behavior of the player's MoveComponent.
    public func updateMoveComponent(withType type: BehaviorType) {
        self.moveComponent?.update(withBehaviorType: type)
    }
    
    ///Removes the player's MoveComponent.
    public func removeMovement() {
        self.removeComponent(ofType: MoveComponent.self)
        self.playerComponent?.stopSkatingAction()
    }
    
    public func distance(fromNode node: SKNode) -> CGFloat {
        let xDiff = self.node!.position.x - node.position.x
        let yDiff = self.node!.position.y - node.position.y
        
        return sqrt(pow(xDiff, 2) + pow(yDiff, 2))
    }
    
    ///Positions this player at a specified faceoff location.
    public func position(atFaceoffLocation faceoffLocation: FaceoffLocation, withDuration duration: TimeInterval? = nil) {
        
        //Remove all actions the player's holding and sprite nodes are running.
        playerNode?.removeAllActions()
        node?.removeAllActions()
        
        //Check for a specified duration.
        guard let duration = duration else {
            //No duration specified, move player to position immediately.
            node?.position = faceoffLocation.playerPosition(forPlayer: self)
            self.rotate(toFacePoint: faceoffLocation.coordinate, withDuration: 0.1)
            return
        }
        let skatePoint = faceoffLocation.playerPosition(forPlayer: self)
        //Rotate the player to face the point they are skating to.
        self.rotate(toFacePoint: skatePoint, withDuration: 0.2)
        
        //Begin the player's skating animation
        self.playerComponent?.animateSkatingTextures()
        
        //Move the player to the skate point
        let moveAction = SKAction.move(to: skatePoint, duration: duration - 0.3)
        //Rotate the player to face the faceoff dot.
        let rotateAction = SKAction.rotateAction(toFacePoint: faceoffLocation.coordinate, currentPoint: skatePoint, withDuration: 0.3)
        //Stop the skating animation
        let removeSkatingAnimation = SKAction.run {
            self.playerComponent?.stopSkatingAction()
        }
        
        //Sequence of above actions
        let seq = SKAction.sequence([moveAction, rotateAction, removeSkatingAnimation])
        //Run the sequence
        self.node?.run(seq)
    }
    
    ///Selects the player
    public func select() {
        self.removeMovement()
        //Joystick.shared.delegate = userComponent
        self.addComponent(UserComponent.shared)
        self.playerComponent?.select()
        
        self.playerComponent?.stopSkatingAction()
    }
    
    ///Deselects the player
    public func deselect() {
        self.removeComponent(ofType: UserComponent.self)
        self.playerComponent?.deselect()
        self.playerComponent?.animateSkatingTextures()
        self.addMovement()
    }
    
    ///Calls on the player component to pass the puck to a specified player
    open func passPuck(toPlayer player: Player) {
        self.playerComponent?.passPuck(toPlayer: player)
        
    }
    
    //Rotates node to face a point (with an entered duration)
    open func rotate(toFacePoint point: CGPoint, withDuration duration: TimeInterval) {
        node?.run(SKAction.rotateAction(toFacePoint: point, currentPoint: node!.position, withDuration: duration))
    }
    
    //MARK: - Calculated variables
    
    //The player component
    public var playerComponent: PlayerComponent? {
        return self.component(ofType: PlayerComponent.self)!
    }
    
    ///The holding node for this player.
    public var node: PlayerNode? {
        set {
            self.playerComponent?.node = newValue
        }
        get {
            return self.playerComponent?.node
        }
    }
    
    ///The sprite node for this player.
    public var playerNode: PlayerSpriteNode? {
        set {
            self.playerComponent?.playerNode = newValue
        }
        get {
            return self.playerComponent?.playerNode
        }
    }
    
    ///The texture of this player's sprite node.
    public var texture: SKTexture? {
        set {
            self.playerNode?.texture = newValue
        }
        get {
            return self.playerNode?.texture
        }
    }
    
    ///If selected, this will retrieve the player's selection node.
    public var selectionNode: SKShapeNode? {
        set {
            self.playerComponent?.selectionNode = newValue!
        }
        get {
            return self.playerComponent?.selectionNode
        }
    }
    
    ///Does this player have the puck?
    public var hasPuck: Bool {
        set {
            self.playerComponent!.hasPuck = newValue
        }
        get {
            return self.playerComponent!.hasPuck
        }
    }
    
    ///The position in the scene this player's node is.
    public var position: CGPoint {
        set {
            self.node?.position = newValue
        }
        get {
            return self.node!.position
        }
    }
    
    ///The team this player is on
    public var team: Team {
        if self.isOnOpposingTeam {
            return opposingTeam!
        }
        return userTeam!
    }
    
    ///The team this player's team is facing.
    public var oppositeTeam: Team {
        if self.isOnOpposingTeam {
            return userTeam!
        }
        return opposingTeam!
    }
    
    ///The player's agent. If selected, will return the userComponent, otherwise the moveComponent.
    var agent: GKAgent2D {
        if let moveComponent = self.moveComponent {
            return moveComponent
        }
        return userComponent!
    }
    
    ///This player's userComponent. (If not selected, returns nil.)
    public var userComponent: UserComponent? {
        return self.component(ofType: UserComponent.self)
    }
    
    //This player's move component. (Returns nil if selected.)
    public var moveComponent: MoveComponent? {
        return self.component(ofType: MoveComponent.self)
    }
    
    //Is the player selected?
    public var isSelected: Bool {
        if self.userComponent != nil {
            return true
        }
        return false
    }

}

public class PlayerSpriteNode: SKSpriteNode {
    var parentNode: PlayerNode {
        return self.parent as! PlayerNode
    }
}

public class PlayerNode: SKNode {
    open var component: PlayerComponent?
    
    init(toComponent comp: PlayerComponent) {
        self.component = comp
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum TeamSize {
    case three, four, five
    
    public var intVal: Int {
        switch self {
        case .three :
            return 3
        case .four :
            return 4
        case .five :
            return 5
        }
    }
}

public enum PlayerPosition: Int {
    case leftWing, rightWing, center, leftDefense, rightDefense, goalie
    
    public var isForward: Bool {
        switch self {
        case .leftWing, .rightWing, .center :
            return true
        default :
            return false
        }
    }
    
    public var isDefenseman: Bool {
        switch self {
        case .leftDefense, .rightDefense :
            return true
        default :
            return false
        }
    }
}

//Extending Array's functionality when it is a Team
extension Array where Element:Player {
    var isUserControlled: Bool {
        if self.count > 0 {
            return !self[0].isOnOpposingTeam
        }
        return false
    }
    
    var oppositeTeam: Team {
        if self.isUserControlled {
            return opposingTeam!
        }
        return userTeam!
    }
    
    var puckCarrier: Player? {
        for player: Player in self {
            if player.hasPuck {
                return player
            }
        }
        return nil
    }
    
    var forwards: Team {
        var array = Team()
        for player: Player in self {
            if player.pPosition.isForward {
                array.append(player)
            }
        }
        return array
    }
    
    var hasPuck: Bool {
        for player: Player in self {
            if player.hasPuck {
                return true
            }
        }
        return false
    }
    
    var defensemen: Team {
        var array = Team()
        for player: Player in self {
            if player.pPosition.isDefenseman {
                array.append(player)
            }
        }
        return array
    }
    
    var goalie: Player? {
        for player: Player in self {
            if player.pPosition == PlayerPosition.goalie {
                return player
            }
        }
        return nil
    }
    
    var agents: [GKAgent2D] {
        var agentArray = [GKAgent2D]()
        for player: Player in self {
            agentArray.append(player.agent)
        }
        return agentArray   
    }
    
    var moveComponents: [MoveComponent] {
        var components = [MoveComponent]()
        for player: Player in self {
            if let moveComponent = player.moveComponent {
                components.append(moveComponent)
            }
        }
        return components
    }
    
    var moveComponentSystem: GKComponentSystem<MoveComponent> {
        let componentSystem = GKComponentSystem(componentClass: MoveComponent.self)
        for component in self.moveComponents {
            componentSystem.addComponent(component)
        }
        return componentSystem as! GKComponentSystem<MoveComponent>
    }
    
    func updateBehaviorToDefense() {
        for player: Player in self {
            if player.pPosition.isDefenseman {
                player.updateMoveComponent(withType: .defendGoal)
            }
            else {
                player.updateMoveComponent(withType: .attackPuckCarrier)
            }
        }
    }
    
    func updateBehaviorToOffense() {
        for player: Player in self {
            if player.hasPuck {
                player.updateMoveComponent(withType: .attackGoal)
                return
            }
            player.updateMoveComponent(withType: .supportPuckCarrier)
        }
    }
    
    func chasePuck() {
        for player: Player in self {
            player.updateMoveComponent(withType: .chasePuck)
        }
    }
    
    func player(withPosition pPosition: PlayerPosition) -> Player? {
        for player: Player in self {
            if player.pPosition == pPosition {
                return player
            }
        }
        return nil
    }
    
    func setPhysicsBodies() {
        for player: Player in self {
            player.playerComponent?.setPhysicsBody()
        }
    }
}
