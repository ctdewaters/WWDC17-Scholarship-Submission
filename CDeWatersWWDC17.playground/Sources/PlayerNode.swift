import SpriteKit

public typealias Team = [PlayerNode]
public typealias UserTeam = [UserPlayerNode]

fileprivate let nodeSize = CGSize(width: 25, height: 50)

protocol PlayerNodeDelegate {
    func playerNodeDidPickUpPuck(_ node: PlayerNode)
}

open class PlayerNode: SKSpriteNode {
    
    fileprivate var skatingAction: SKAction?
    fileprivate var selectionNode = SKShapeNode()
    
    open var pSpeed: CGFloat = 3
    
    open var playerPosition: PlayerPosition!
    open var isOnOpposingTeam: Bool!
    open var hasPuck = false
    
    open var rinkReference: UnsafeMutablePointer<Rink>?
    
    fileprivate var delegate: PlayerNodeDelegate?
    
    fileprivate var puck: PuckNode? {
        for child in children {
            if let puck = child as? PuckNode {
                return puck
            }
        }
        return nil
    }
    
    public init(withColor color: SKColor = .white, rinkReference rink: Rink, andPosition playerPosition: PlayerPosition) {
        //Load textures
        super.init(texture: nil, color: color, size: nodeSize)
        self.playerPosition = playerPosition
        self.texture = PlayerTexture.faceoff
        self.colorBlendFactor = 0.5
        
        self.zPosition = 0
        
        self.rinkReference = UnsafeMutablePointer<Rink>.allocate(capacity: 1)
        self.rinkReference?.pointee = rink
        
        //Setting physics body
        self.setPhysicsBody()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func pickUp(puck: inout PuckNode) {
        puck.removeAllActions()
        puck.removeFromParent()
        puck.physicsBody = nil
        puck.position = CGPoint(x: -9, y: 17)
        self.addChild(puck)
        self.hasPuck = true
        
        delegate?.playerNodeDidPickUpPuck(self)
    }
    
    fileprivate func setPhysicsBody() {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let path = generatePath()
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody = physicsBody
        self.physicsBody?.isDynamic = true
        self.physicsBody?.mass = 1
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.all
        self.physicsBody?.contactTestBitMask = PhysicsCategory.puck | PhysicsCategory.player
        self.physicsBody?.affectedByGravity = false
    }
    
    fileprivate func generatePath() -> CGPath {
        
        let rect = CGRect(x: self.frame.origin.x + 5, y: self.frame.origin.y + 5, width: self.frame.width - 10, height: self.frame.width - 10)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: self.frame.width / 2)
        
        return path.cgPath
    }
    
    //Remove puck and add it to the rink at its current position
    fileprivate func addPuckBackToRink() -> UnsafeMutablePointer<PuckNode> {
        
        //Convert position of puck in this node to the rink's coordinate system
        let puckPosition = rinkReference?.pointee.convert((rinkReference?.pointee.puck?.position)!, from: self)
        
        let puck = rinkReference?.pointee.puck
        puck?.removeFromParent()
        puck?.position = puckPosition!
        rinkReference?.pointee.addChild(puck!)
        
        self.hasPuck = false
        
        let ptr = UnsafeMutablePointer<PuckNode>.allocate(capacity: 1)
        ptr.pointee = puck!
        
        return ptr
    }
    
    fileprivate func movePuck(withForceMagnitude magnitude: CGFloat, toPoint point: CGPoint, withPreliminaryActions actions: [SKAction]? = nil) {
        let puck = addPuckBackToRink()
        
        let action = SKAction.vectorAction(withPointA: point, andPointB: puck.pointee.position, withMagnitude: 10, andDuration: 0.35)
        
        var seqAction: SKAction!
        if var actions = actions {
            actions.append(action)
            seqAction = SKAction.sequence(actions)
        }
        else {
            seqAction = action
        }
        
        puck.pointee.setPhysicsBody()
        
        puck.pointee.run(seqAction)
        
        let shootingAction = SKAction.animate(with: PlayerTexture.shootingTextures, timePerFrame: 0.1, resize: false, restore: true)
        self.run(shootingAction)
        
        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false, block: {
            timer in
            self.physicsBody?.categoryBitMask = PhysicsCategory.player
            self.physicsBody?.collisionBitMask = PhysicsCategory.all
        })
    }
    
    
    open func applySkatingForce(usingPoint point: CGPoint) {
        self.rotate(toFacePoint: point, withDuration: 0.25)
        
        let action = SKAction.move(to: point, duration: 0.4)
        self.run(action)
    }
    
    open func rotate(toFacePoint point: CGPoint, withDuration duration: TimeInterval) {
        let xDiff = self.position.x - point.x
        let yDiff = self.position.y - point.y
        
        let angle = atan2(yDiff, xDiff) + (90 / 180 * CGFloat.pi)
        
        let rotateAction = SKAction.rotate(toAngle: angle, duration: duration)
        self.run(rotateAction)
    }
    
    open func animateSkatingTextures() {
        self.skatingAction = SKAction.repeatForever(SKAction.animate(with: PlayerTexture.skatingTextures, timePerFrame: 0.05))
        self.run(self.skatingAction!, withKey: "skatingAction")
        
        if let puck = puck {
            let moveAction = SKAction.moveTo(x: -4, duration: 0.15)
            puck.run(moveAction)
        }
    }
    
    open func stopSkatingAction() {
        self.removeAction(forKey: "skatingAction")
        self.skatingAction = nil
        
        if let puck = puck {
            let moveAction = SKAction.moveTo(x: -9, duration: 0.15)
            puck.run(moveAction)
        }
    }
    
}

open class UserPlayerNode: SKNode, PlayerNodeDelegate {
    var playerNode: PlayerNode!
    var selectionNode = SKShapeNode()
    
    var isSelected = false
    
    public var hasPuck: Bool {
        return self.playerNode.hasPuck
    }
    
    //The point at the front tip of the node
    public var frontPoint: CGPoint {
        let startPoint = self.position // center of node
        let angle = self.zRotation
        let halfLength = self.frame.height / 2
        
        let xDiff = halfLength * cos(angle)
        let yDiff = halfLength * cos(angle)
        
        return CGPoint(x: startPoint.x + xDiff, y: startPoint.y + yDiff)
    }
    
    fileprivate var facingNorth: Bool {
        let rotation = self.zRotation + (CGFloat.pi / 2)
        
        if rotation < 0 || rotation > CGFloat.pi {
            return false
        }
        return true
    }
    
    fileprivate var shootingPoint: CGPoint {
        let startPoint = self.position // center of node
        let angle = self.zRotation
        let length = self.frame.height * 2
        
        let xDiff = length * cos(angle)
        let yDiff = length * cos(angle)
        
        return CGPoint(x: startPoint.x + xDiff, y: startPoint.y + yDiff)
    }
    
    fileprivate var rinkReference: UnsafeMutablePointer<Rink>? {
        return self.playerNode.rinkReference
    }
    
    public init(withColor color: SKColor = .white, rinkReference: Rink, andPosition playerPosition: PlayerPosition) {
        super.init()
        self.playerNode = PlayerNode(withColor: color, rinkReference: rinkReference, andPosition: playerPosition)
        self.playerNode.zPosition = 1
        self.playerNode.delegate = self
        self.addChild(playerNode)
        self.playerNode.physicsBody = nil
        self.setPhysicsBody()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func move(withJoystickData data: JoystickData) {
        self.removeAction(forKey: "skatingImpulse")
        
        self.run(self.rotateAction(toAngle: data.angle))
        
        let length = sqrt(pow(data.x, 2) + pow(data.y, 2))
        let normalizedPoint = CGPoint(x: data.x / length, y: data.y / length)
        
        let playerSpeed = playerNode.pSpeed
        
        self.position.x += normalizedPoint.x * playerSpeed
        self.position.y += normalizedPoint.y * playerSpeed
    }
    
    open func applySkatingImpulse() {
        //Remove previous physics
        self.physicsBody = nil
        self.setPhysicsBody()
        
        let vector = CGVector(withMagnitude: self.playerNode.speed * 35, andDirectionAngle: self.zRotation)
        let impulseAction = SKAction.applyImpulse(vector, duration: 0.35)
        self.run(impulseAction, withKey: "skatingImpulse")
    }
    
    //Select player
    open func select() {
        self.isSelected = true
        self.selectionNode = SKShapeNode(circleOfRadius: nodeSize.width / 2)
        self.selectionNode.fillColor = SKColor.blue.withAlphaComponent(0.3)
        self.selectionNode.strokeColor = SKColor.blue
        self.selectionNode.position = CGPoint(x: 0, y: -10)
        self.selectionNode.zPosition = 0
        
        self.addChild(self.selectionNode)
    }
    
    //Deselect player
    open func deselect() {
        self.isSelected = false
        self.selectionNode.removeFromParent()
        self.playerNode.stopSkatingAction()
    }
    
    open func rotate(toFacePoint point: CGPoint, withDuration duration: TimeInterval) {
        self.run(self.rotateAction(toFacePoint: point, withDuration: duration))
    }
    
    open func passPuck(toPlayer player: UserPlayerNode) {
        self.playerNode.movePuck(withForceMagnitude: 2, toPoint: player.frontPoint)
    }
    
    open func shootPuck(atPoint point: CGPoint) {
        print(facingNorth)
        if !facingNorth {
            let rotateAction = self.rotateAction(toFacePoint: point, withDuration: 0.22)
            self.run(rotateAction, completion: {
                self.removeAllActions()
                self.playerNode.movePuck(withForceMagnitude: 10, toPoint: point)
            })
        }
        else {
            self.playerNode.movePuck(withForceMagnitude: 10, toPoint: point)
        }
    }
    
    fileprivate func setPhysicsBody() {
        let path = self.playerNode.generatePath()
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody = physicsBody
        self.physicsBody?.isDynamic = true
        self.physicsBody?.mass = 1
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.rink | PhysicsCategory.puck
        self.physicsBody?.friction = 0.7
        self.physicsBody?.affectedByGravity = false
    }
    
    fileprivate func rotateAction(toFacePoint point: CGPoint, withDuration duration: TimeInterval) -> SKAction {
        let xDiff = self.position.x - point.x
        let yDiff = self.position.y - point.y
        
        let angle = atan2(yDiff, xDiff) + (90 / 180 * CGFloat.pi)
        
        return SKAction.rotate(toAngle: angle, duration: duration, shortestUnitArc: true)
    }
    
    fileprivate func rotateAction(toAngle angle: CGFloat) -> SKAction {
        let angle = angle - (CGFloat.pi / 2)
        return SKAction.rotate(toAngle: angle, duration: 0.1, shortestUnitArc: true)
    }
    
    //Calculates distance from another node
    open func distance(fromNode node: SKNode) -> CGFloat {
        let xDiff = self.position.x - node.position.x
        let yDiff = self.position.y - node.position.y
        
        return sqrt(pow(xDiff, 2) + pow(yDiff, 2))
    }
    
    //MARK: - PlayerNodeDelegate
    
    func playerNodeDidPickUpPuck(_ node: PlayerNode) {
        self.physicsBody?.categoryBitMask = PhysicsCategory.puckCarrier
        self.physicsBody?.collisionBitMask = PhysicsCategory.rink
        
        //Selecting player
        if self.isSelected == false {
            //Player is not selected, deselect currently selected player, and select this player
            self.rinkReference?.pointee.selectedPlayer?.pointee.deselect()
            self.select()
        }
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
    class func vectorAction(withPointA a: CGPoint, andPointB b: CGPoint, withMagnitude magnitude: CGFloat, andDuration duration: TimeInterval) -> SKAction {
        let origin = CGPoint(x: b.x - a.x, y: b.y - a.y)
        let angle = -atan2(origin.y, origin.x)
        
        let dx = magnitude * cos(angle)
        let dy = magnitude * sin(angle)
        
        let vector = CGVector(dx: -dx, dy: dy)
        
        return SKAction.applyImpulse(vector, duration: 0.35)
    }
}

