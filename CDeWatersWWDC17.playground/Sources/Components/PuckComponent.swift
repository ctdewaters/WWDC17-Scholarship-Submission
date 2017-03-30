//
//  PuckComponent.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/27/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import GameplayKit
import SpriteKit

public let puckDiameter: CGFloat = 4

public class PuckComponent: GKAgent2D, GKAgentDelegate {
    
    public var node: SKShapeNode!
    
    override public init() {
        super.init()
        
        node = SKShapeNode()
        
        node.path = CGPath(ellipseIn: CGRect(origin: CGPoint.zero, size: CGSize(width: puckDiameter, height: puckDiameter)), transform: nil)
        node.fillColor = .black
        
        node.strokeColor = .clear
        node.zPosition = 0
        
        setPhysicsBody()
        
        self.delegate = self

    }
    
    public func setPhysicsBody() {
        node.physicsBody = SKPhysicsBody(circleOfRadius: puckDiameter / 2, center: CGPoint(x: puckDiameter / 2, y: puckDiameter / 2))
        node.physicsBody?.mass = 0.01
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.puck
        node.physicsBody?.collisionBitMask = PhysicsCategory.net | PhysicsCategory.rink
        node.physicsBody?.contactTestBitMask = PhysicsCategory.rink | PhysicsCategory.player
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.restitution = 0
    }
    
    //MARK: - GKAgentDelegate
    
    public func agentWillUpdate(_ agent: GKAgent) {
        self.position = float2(withCGPoint: self.node.position)
    }
    
    public func agentDidUpdate(_ agent: GKAgent) {
        
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
