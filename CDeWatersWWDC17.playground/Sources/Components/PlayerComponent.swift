//
//  PlayerComponent.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/25/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

public let playerNodeSize = CGSize(width: 25, height: 50)

public class PlayerComponent: GKAgent2D {

    open var node: PlayerNode!
    open var playerNode: PlayerSpriteNode!
    open var selectionNode = SKShapeNode()
    open var pSpeed: CGFloat = 3
    
    public var animatingSkating = false
    
    fileprivate var dekeSide = DekeSide.none
    
    var hasPuck = false
    
    public init(withColor color: SKColor = .white, andTexture texture: SKTexture? = nil) {
        super.init()
        
        node = PlayerNode(toComponent: self)
        
        self.playerNode = PlayerSpriteNode(texture: texture, color: color, size: playerNodeSize)
        self.playerNode.texture = PlayerTexture.faceoff
        self.playerNode.colorBlendFactor = 0.75
        self.playerNode.zPosition = 1
        self.node.addChild(self.playerNode)
        
        self.node.zPosition = 0
        
        self.setPhysicsBody()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPhysicsBody() {
        self.playerNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let path = NSBezierPath(ovalIn: NSRect(x: self.playerNode.frame.origin.x, y: self.playerNode.frame.origin.y + 10, width: self.playerNode.frame.size.width * 0.75, height: self.playerNode.frame.size.height / 2))
        self.physicsBody = SKPhysicsBody(polygonFrom: path.cgPath)

        self.physicsBody?.isDynamic = true
        self.physicsBody?.mass = 0.25
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.all
        self.physicsBody?.contactTestBitMask = PhysicsCategory.puck | PhysicsCategory.player
        self.physicsBody?.affectedByGravity = false
    }
    
    open func passPuck(toPlayer player: Player) {
        self.movePuck(withForceMagnitude: 3.5, toPoint: player.position)
    }
    
    
    //MARK: - Picking up and releasing the puck
    
    //Taking control of the puck
    public func pickUpPuck() {
        Puck.shared.node.removeAllActions()
        Puck.shared.node.removeFromParent()
        Puck.shared.node.physicsBody = nil
        Puck.shared.position = CGPoint(x: -9, y: 17)
        node.addChild(Puck.shared.node)
        self.hasPuck = true
        
        if !isOnOpposingTeam {
            self.playerEntity?.select()
        }
        
        self.playerEntity?.delegate?.playerDidPickUpPuck(self.playerEntity!)
    }
    
    //Remove puck and add it to the rink at its current position
    fileprivate func addPuckBackToRink() {
        //Convert position of puck in this node to the rink's coordinate system
        let puckPosition = Rink.shared.convert(Puck.shared.position, from: Puck.shared.node.parent!)
        
        Puck.shared.node.removeFromParent()
        Puck.shared.position = puckPosition
        Rink.shared.addChild(Puck.shared.node)
        
        Rink.shared.bringNetsToFront()
        
        self.hasPuck = false
        
        self.playerEntity?.delegate?.playerDidReleasePuck(playerEntity!)
    }
    
    //Shoots the puck at a point
    open func shootPuck(atPoint point: CGPoint) {
        if hasPuck {
            if !facingNorth {
                let rotateAction = SKAction.rotateAction(toFacePoint: point, currentPoint: node.position, withDuration: 0.22)
                node.run(rotateAction, completion: {
                    self.node.removeAllActions()
                    self.movePuck(withForceMagnitude: 10, toPoint: point)
                })
            }
            else {
                self.movePuck(withForceMagnitude: 10, toPoint: point)
            }
        }
    }
    
    //Moves puck to a point with an entered magnitude
    fileprivate func movePuck(withForceMagnitude magnitude: CGFloat, toPoint point: CGPoint, withPreliminaryActions actions: [SKAction]? = nil) {
        self.addPuckBackToRink()
        
        Puck.shared.node.removeAllActions()
        let action = SKAction.vectorAction(withPointA: point, andPointB: self.node.position, withMagnitude: magnitude, andDuration: 3.5 / Double(magnitude))
        
        var seqAction: SKAction!
        if var actions = actions {
            actions.append(action)
            seqAction = SKAction.sequence(actions)
        }
        else {
            seqAction = action
        }
        
        Puck.shared.puckComponent.setPhysicsBody()
        self.physicsBody = nil
        Puck.shared.node.run(seqAction)
        
        let shootingAction = SKAction.animate(with: PlayerTexture.shootingTextures, timePerFrame: 0.1, resize: false, restore: true)
        playerNode.run(shootingAction)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {
            timer in
            DispatchQueue.main.async {
                self.setPhysicsBody()
                self.physicsBody?.categoryBitMask = PhysicsCategory.player
                self.physicsBody?.collisionBitMask = PhysicsCategory.all
            }
        })
    }

    //MARK: - Selection methods
    
    //Selects player
    open func select() {
        if self.selectionNode.parent == nil {
            self.selectionNode = SKShapeNode(circleOfRadius: playerNodeSize.width / 2)
            self.selectionNode.fillColor = SKColor.blue.withAlphaComponent(0.3)
            self.selectionNode.strokeColor = SKColor.blue
            self.selectionNode.position = self.playerNode.position
            self.selectionNode.zPosition = 0
            
            self.node.addChild(self.selectionNode)
        }
    }
    
    //Deselects player
    open func deselect() {
        self.selectionNode.removeFromParent()
    }
    
    //MARK: - Movement functions
    
    //Rotates node to face a point (with an entered duration)
    open func rotate(toFacePoint point: CGPoint, withDuration duration: TimeInterval) {
        self.node.run(SKAction.rotateAction(toFacePoint: point, currentPoint: self.node.position, withDuration: duration))
    }
    
    //Applies a force to the node after user input has ceased
    open func applySkatingImpulse() {
        //Remove previous physics
        self.setPhysicsBody()
        
        let vector = CGVector(withMagnitude: self.playerNode.speed * 25, andDirectionAngle: self.node.zRotation)
        let impulseAction = SKAction.applyImpulse(vector, duration: 0.35)
        self.node.run(impulseAction, withKey: "skatingImpulse")
    }
    
    //Animates the skating textures
    open func animateSkatingTextures() {
        if !self.animatingSkating {
            self.animatingSkating = true
            self.setPhysicsBody()
            let skatingAction = SKAction.repeatForever(SKAction.animate(with: PlayerTexture.skatingTextures, timePerFrame: 0.05))
            self.playerNode.run(skatingAction, withKey: "skatingAction")
            
            if self.hasPuck {
                let moveAction = SKAction.moveTo(x: -4, duration: 0.15)
                Puck.shared.node.run(moveAction)
            }
        }
    }
    
    //Stops skating texture animation
    open func stopSkatingAction() {
        self.playerNode.removeAction(forKey: "skatingAction")
        
        self.playerNode.texture = PlayerTexture.faceoff
        
        if self.hasPuck {
            let moveAction = SKAction.moveTo(x: -9, duration: 0.15)
            Puck.shared.node.run(moveAction)
        }
        self.animatingSkating = false
    }
    
    //Moves with entered data generated by the joystick
    public func move(withControlKeys keys: [ControlKey]) {
        var point = CGPoint.zero
        
        for key in keys {
            switch key {
            case .leftKey :
                point.x = -1
            case .rightKey :
                point.x = 1
            case .upKey :
                point.y = 1
            case .downKey :
                point.y = -1
            default :
                break
            }
        }
        
        if point != CGPoint.zero {
            self.node.removeAction(forKey: "skatingImpulse")
            self.node.run(SKAction.rotateAction(toAngle: self.angle(fromKeyPoint: point)))
            
            let length = sqrt(pow(point.x, 2) + pow(point.y, 2))
            let normalizedPoint = CGPoint(x: point.x / length, y: point.y / length)
            
            let playerSpeed = self.pSpeed
            
            self.node.position.x += normalizedPoint.x * playerSpeed
            self.node.position.y += normalizedPoint.y * playerSpeed
        }
    }
    
    fileprivate func angle(fromKeyPoint point: CGPoint) -> CGFloat {
        return atan2(point.y, point.x)
    }
    
    public func deke(withControlKey key: ControlKey? = nil) {
        if let key = key {
            if key == .leftArrow && dekeSide != .left {
                self.animateDeke(toRight: false)
            }
            else if key == .rightArrow && dekeSide != .right {
                self.animateDeke(toRight: true)
            }
        }
        else {
            if self.dekeSide == .left {
                //Deked left
                let dekeAnimation = SKAction.animate(with: PlayerTexture.dekeLeftTextures.reversed(), timePerFrame: 0.1, resize: false, restore: false)
                self.playerNode.run(dekeAnimation)

            }
            else {
                //Deked right
                let dekeAnimation = SKAction.animate(with: PlayerTexture.dekeRightTextures.reversed(), timePerFrame: 0.1, resize: false, restore: false)
                self.playerNode.run(dekeAnimation)
            }
            let puckAnimation = SKAction.moveTo(x: 0, duration: 0.45)
            Puck.shared.node.run(puckAnimation)
            self.dekeSide = .none
        }
    }
    
    fileprivate func animateDeke(toRight: Bool) {
        if toRight {
            self.dekeSide = .right
            let dekeAnimation = SKAction.animate(with: PlayerTexture.dekeRightTextures, timePerFrame: 0.1, resize: false, restore: false)
            self.playerNode.run(dekeAnimation)
            
            let puckAnimation = SKAction.moveTo(x: 7, duration: 0.45)
            Puck.shared.node.run(puckAnimation)
        }
        else {
            self.dekeSide = .left
            let dekeAnimation = SKAction.animate(with: PlayerTexture.dekeLeftTextures, timePerFrame: 0.1, resize: false, restore: false)
            self.playerNode.run(dekeAnimation)
            
            let puckAnimation = SKAction.moveTo(x: -15, duration: 0.45)
            Puck.shared.node.run(puckAnimation)
        }
    }
    
    //Returns the player to idle. (No joystick data).
    public func returnToIdle() {
        self.stopSkatingAction()
        self.applySkatingImpulse()
    }
    
    //MARK: - Calculated variables
    
    //Reference to this player's team 
    public var team: Team {
        var team: Team!
        
        if isOnOpposingTeam {
            team = opposingTeam
        }
        else {
            team = userTeam
        }
        return team
    }
    
    //The player entity
    public var playerEntity: Player? {
        return self.entity as? Player
    }
    
    public var isOnOpposingTeam: Bool {
        return self.playerEntity!.isOnOpposingTeam
    }
        
    //Texture of the player node
    fileprivate var texture: SKTexture? {
        return self.playerNode.texture
    }
    
    //Size of the player node
    fileprivate var size: CGSize {
        return self.playerNode.size
    }
    
    //Physics body of the player node
    fileprivate var physicsBody: SKPhysicsBody? {
        set {
            self.node.physicsBody = newValue
        }
        get {
            return self.node.physicsBody
        }
    }
    
    //The point at the front tip of the node
    public var frontPoint: CGPoint {
        let startPoint = node.position // center of node
        let angle = node.zRotation
        let halfLength = node.frame.height / 2
        
        let xDiff = halfLength * cos(angle)
        let yDiff = halfLength * cos(angle)
        
        return CGPoint(x: startPoint.x + xDiff, y: startPoint.y + yDiff)
    }
    
    //Is the player facing north?
    fileprivate var facingNorth: Bool {
        let rotation = node.zRotation + (CGFloat.pi / 2)
        
        if rotation < 0 || rotation > CGFloat.pi {
            return false
        }
        return true
    }
    
    //The point to shoot the puck from
    fileprivate var shootingPoint: CGPoint {
        let startPoint = node.position // center of node
        let angle = node.zRotation
        let length = playerNodeSize.height * 4
        
        let xDiff = length * cos(angle)
        let yDiff = length * cos(angle)
        
        return CGPoint(x: startPoint.x + xDiff, y: startPoint.y + yDiff)
    }
    
}

public enum DekeSide {
    case left, right, none
}

fileprivate extension CGVector {
    init(withMagnitude magnitude: CGFloat, andDirectionAngle angle: CGFloat) {
        var angle = angle
        angle += (CGFloat.pi / 1.9)
        if angle < 0 {
            angle = (2 * CGFloat.pi) + angle
        }
        self.dx = (magnitude * cos(angle))
        self.dy = (magnitude * sin(angle))
    }
}

public extension SKAction {
    public class func vectorAction(withPointA a: CGPoint, andPointB b: CGPoint, withMagnitude magnitude: CGFloat, andDuration duration: TimeInterval) -> SKAction {
        let origin = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let angle = -atan2(origin.y, origin.x)
        
        let dx = magnitude * cos(angle)
        let dy = magnitude * sin(angle)
        
        let vector = CGVector(dx: -dx, dy: dy)
        
        return SKAction.applyImpulse(vector, duration: 0.35)
    }
    
    public class func rotateAction(toFacePoint point: CGPoint, currentPoint: CGPoint, withDuration duration: TimeInterval) -> SKAction {
        let xDiff = currentPoint.x - point.x
        let yDiff = currentPoint.y - point.y
        
        let angle = atan2(yDiff, xDiff) + (90 / 180 * CGFloat.pi)
        
        return SKAction.rotate(toAngle: angle, duration: duration, shortestUnitArc: true)
    }
    
    class func rotateAction(toAngle angle: CGFloat) -> SKAction {
        let angle = angle - (CGFloat.pi / 2)
        return SKAction.rotate(toAngle: angle, duration: 0.1, shortestUnitArc: true)
    }
}
