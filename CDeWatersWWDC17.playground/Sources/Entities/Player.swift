//
//  PlayerEntity.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/25/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

public class Player: GKEntity {
        
    var pPosition: PlayerPosition!
    public var isOnOpposingTeam = false
    
    public init(withColor color: SKColor = .white, andPosition playerPosition: PlayerPosition) {
        super.init()
        
        //Setting the player's position
        self.pPosition = playerPosition
        
        let playerComponent = PlayerComponent(withColor: color, andTexture: PlayerTexture.faceoff)
        self.addComponent(playerComponent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addMovement() {
        let moveBehavior = MoveBehavior(forPlayerOnTeam: (self.playerComponent?.team)!, withPlayerPosition: self.pPosition, withTargetSpeed: 100)
        let moveComponent = MoveComponent(maxSpeed: 100, maxAcceleration: 75, radius: Float(playerNodeSize.width / 2), mass: 0.3, withBehavior: moveBehavior)
        self.addComponent(moveComponent)
            
    }
    
    public func removeMovement() {
        self.removeComponent(ofType: MoveComponent.self)
    }
    
    public func distance(fromNode node: SKNode) -> CGFloat {
        let xDiff = self.node!.position.x - node.position.x
        let yDiff = self.node!.position.y - node.position.y
        
        return sqrt(pow(xDiff, 2) + pow(yDiff, 2))
    }
    
    public func position(atFaceoffLocation faceoffLocation: FaceoffLocation) {
        playerNode?.removeAllActions()
        node?.removeAllActions()
        node?.position = faceoffLocation.playerPosition(forPlayer: self)
        self.rotate(toFacePoint: faceoffLocation.coordinate, withDuration: 0.1)
    }
    
    public func select() {
        self.removeMovement()
        //Joystick.shared.delegate = userComponent
        self.addComponent(UserComponent.shared)
        self.playerComponent?.select()
    }
    
    public func deselect() {
        self.removeComponent(ofType: UserComponent.self)
        self.playerComponent?.deselect()
    }
    
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
    
    public var node: PlayerNode? {
        set {
            self.playerComponent?.node = newValue
        }
        get {
            return self.playerComponent?.node
        }
    }
    
    public var playerNode: PlayerSpriteNode? {
        set {
            self.playerComponent?.playerNode = newValue
        }
        get {
            return self.playerComponent?.playerNode
        }
    }
    
    public var texture: SKTexture? {
        set {
            self.playerNode?.texture = newValue
        }
        get {
            return self.playerNode?.texture
        }
    }
    
    public var selectionNode: SKShapeNode? {
        set {
            self.playerComponent?.selectionNode = newValue!
        }
        get {
            return self.playerComponent?.selectionNode
        }
    }
    
    public var hasPuck: Bool {
        set {
            self.playerComponent!.hasPuck = newValue
        }
        get {
            return self.playerComponent!.hasPuck
        }
    }
    
    public var position: CGPoint {
        set {
            self.node?.position = newValue
        }
        get {
            return self.node!.position
        }
    }
        
    public var userComponent: UserComponent? {
        return self.component(ofType: UserComponent.self)
    }
    
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
