//
//  MoveComponent.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/25/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

public class MoveComponent: GKAgent2D, GKAgentDelegate {
    
    var mBehavior: MoveBehavior!
    
    public init(maxSpeed: Float, maxAcceleration: Float, radius: Float, mass: Float, withBehavior behavior: MoveBehavior) {
        super.init()
        
        self.delegate = self
        
        self.maxSpeed = maxSpeed
        self.maxAcceleration = maxAcceleration
        self.radius = radius
        self.mass = mass
        
        self.behavior = behavior
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func agentWillUpdate(_ agent: GKAgent) {
        guard let playerComponent = playerComponent else {
            return
        }
        
        position = float2(withCGPoint: playerComponent.node.position)
        rotation = Float(playerComponent.node.zRotation)
    }
    
    public func agentDidUpdate(_ agent: GKAgent) {
        guard let playerComponent = playerComponent else {
            return
        }
        
        playerComponent.node.physicsBody?.velocity = CGVector(dx: CGFloat(self.velocity.x), dy: CGFloat(self.velocity.y))
        playerComponent.node.zRotation = CGFloat(self.rotation)
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
    
    //MARK: - Movement functions
        
    //MARK: - Calculated variables
    
    //The player entity
    fileprivate var player: Player? {
        return self.entity as? Player
    }
    
    //The player component
    fileprivate var playerComponent: PlayerComponent? {
        return self.player?.playerComponent
    }
    
    var moveBehavior: MoveBehavior {
        set {
            self.behavior = newValue
        }
        get {
            return self.behavior as! MoveBehavior
        }
    }



}

public extension CGPoint {
    init(x: Float, y: Float) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}

public extension float2 {
    init(withCGPoint point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
}

public extension GKAgent2D {
    var cgPosition: CGPoint {
        return CGPoint(x: self.position.x, y: self.position.y)
    }
}
