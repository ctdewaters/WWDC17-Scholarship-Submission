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
    
    
    public init(maxSpeed: Float, maxAcceleration: Float, radius: Float, mass: Float, withBehaviorType type: BehaviorType) {
        super.init()
        
        self.delegate = self
        
        self.maxSpeed = maxSpeed
        self.maxAcceleration = maxAcceleration
        self.radius = radius
        self.mass = mass

        self.behavior = GKBehavior(goals: type.goals, andWeights: type.weights)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(withBehaviorType type: BehaviorType) {
        self.behavior?.removeAllGoals()
        for i in 0..<type.goals.count {
            let goal = type.goals[i]
            let weight = type.weights[i]
            self.behavior?.setWeight(Float(weight), for: goal)
        }
    }
    
    //MARK: - GKAgentDelegate
    
    public func agentWillUpdate(_ agent: GKAgent) {
        guard let playerComponent = playerComponent else {
            return
        }
        
        position = float2(withCGPoint: playerComponent.node.position)
        //rotation = Float(playerComponent.node.zRotation - (CGFloat.pi / 2))
    }
    
    public func agentDidUpdate(_ agent: GKAgent) {
        guard let playerComponent = playerComponent else {
            return
        }
        
        let velocityVector = CGVector(dx: CGFloat(self.velocity.x), dy: CGFloat(self.velocity.y))
        
        playerComponent.node.physicsBody?.velocity = velocityVector

        let facePoint = CGPoint(x: playerComponent.node.position.x + CGFloat(self.velocity.x), y: playerComponent.node.position.y + CGFloat(self.velocity.y))
        let faceAction = SKAction.rotateAction(toFacePoint: facePoint, currentPoint: playerComponent.node.position, withDuration: 0.1)
        playerComponent.node.run(faceAction)
        
        if playerComponent.hasPuck && playerComponent.isOnOpposingTeam {
            //Determine what we will do with the puck
            
            let rand = Int.random(lowerBound: 0, upperBound: Int(playerComponent.node.position.distance(fromPoint: Net.bottomNet.node.position)))
            
            if rand == 7 {
                //Shoot the puck
                playerComponent.shootPuck(atPoint: Net.bottomNet.node.position)
            }
            else if rand < 5 && rand.isEven {
                //Pass to another player
                playerComponent.passPuck(toPlayer: opposingTeam![Int.random(lowerBound: 0, upperBound: opposingTeam!.count - 1)])
            }
        }
        
        if !playerComponent.animatingSkating {
            playerComponent.animateSkatingTextures()
        }
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
}

public extension CGPoint {
    init(x: Float, y: Float) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
    
    func distance(fromPoint point: CGPoint) -> CGFloat {
        return CGFloat(abs(sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))))
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

public extension CGVector {
    var magnitude: CGFloat {
        return atan2(self.dy, self.dx)
    }
}

fileprivate extension Int {
    static func random (lowerBound: Int , upperBound: Int) -> Int {
        let param = UInt32(upperBound - lowerBound + 1)
        return lowerBound + Int(arc4random_uniform(param))
    }
    
    var isEven: Bool {
        if self % 2 == 0 {
            return true
        }
        return false
    }
}

