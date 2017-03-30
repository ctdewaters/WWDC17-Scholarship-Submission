//
//  NetComponent.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/26/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import GameplayKit
import SpriteKit

fileprivate let netWidth: CGFloat = 55
fileprivate let netDepth: CGFloat = 21.9

public class NetComponent: GKAgent2D, GKAgentDelegate {
    
    var node: SKSpriteNode!

    public init(atRinkEnd rinkEnd: RinkEnd) {
        super.init()
        
        self.node = SKSpriteNode(texture: SKTexture(imageNamed: "netTexture"), color: SKColor.clear, size: CGSize(width: netWidth, height: netDepth))
        node.position = rinkEnd.point
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.setPhysicsBody()
        node.zPosition = 1
        
        if rinkEnd == .top {
            node.zRotation = CGFloat.pi
        }

        self.speed = 0
        self.maxSpeed = 0
        self.maxAcceleration = 0
        self.mass = 100
        
        self.position = float2(withCGPoint: self.node.position)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Sets the physics body
    fileprivate func setPhysicsBody() {
        let postSize = CGSize(width: 3, height: self.node.frame.height * 0.8)
        let backSize = CGSize(width: self.node.frame.width, height: 3)
        
        let post1 = SKPhysicsBody(rectangleOf: postSize, center: CGPoint(x: self.node.frame.minX, y: 0))
        let post2 = SKPhysicsBody(rectangleOf: postSize, center: CGPoint(x: self.node.frame.maxX, y: 0))
        let back = SKPhysicsBody(rectangleOf: backSize, center: CGPoint(x: 0, y: -10))
        
        node.physicsBody = SKPhysicsBody(bodies: [post1, post2, back])
        node.physicsBody?.restitution = 0.1
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.net
        node.physicsBody?.usesPreciseCollisionDetection = true
    }
        
    //MARK: - Calculated variables
    
    var net: Net {
        return self.entity as! Net
    }

}


public enum RinkEnd {
    case top, bottom
    
    var point: CGPoint {
        if self == .top {
            return CGPoint(x: 2, y: 452)
        }
        return CGPoint(x: 2, y: -452)
    }
}
