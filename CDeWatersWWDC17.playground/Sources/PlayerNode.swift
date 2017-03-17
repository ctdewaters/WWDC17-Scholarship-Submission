import SpriteKit

public typealias Team = [PlayerNode]
public typealias UserTeam = [UserPlayerNode]

public let faceoffTexture = SKTexture(image: UIImage(named: "faceoffPosition.png")!)
fileprivate let nodeSize = CGSize(width: 25, height: 50)

open class PlayerNode: SKSpriteNode {

    fileprivate var skatingAction: SKAction?
    
    fileprivate var selectionNode = SKShapeNode()
    
    open var pSpeed: CGFloat = 10
    
    open var skatingTextures: [SKTexture]?
    open var playerPosition: PlayerPosition!
    open var isOnOpposingTeam: Bool!
    
    open var hasPuck = false
    
    fileprivate var puck: PuckNode? {
        for child in children {
            if let puck = child as? PuckNode {
                return puck
            }
        }
        return nil
    }
    
    public init(withColor color: SKColor = .white, andPosition playerPosition: PlayerPosition) {
        //Load textures
        super.init(texture: nil, color: color, size: nodeSize)
        self.playerPosition = playerPosition
        self.loadTextures()
        self.texture = faceoffTexture
        self.colorBlendFactor = 0.5
        
        self.zPosition = 0
        
        //Setting physics body
        self.setPhysicsBody()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func pickUp(puck: inout PuckNode) {
        puck.removeFromParent()
        puck.physicsBody = nil
        puck.position = CGPoint(x: -4, y: 17)
        self.addChild(puck)
        self.hasPuck = true
    }
    
    //Loading textures from resources
    fileprivate func loadTextures() {
        let f1 = SKTexture(imageNamed: "player1.png")
        let f2 = SKTexture(imageNamed: "player2.png")
        let f3 = SKTexture(imageNamed: "player3.png")
        let f4 = SKTexture(imageNamed: "player4.png")
        let f5 = SKTexture(imageNamed: "player5.png")
        let f6 = SKTexture(imageNamed: "player6.png")
        let f7 = SKTexture(imageNamed: "player7.png")
        let f8 = SKTexture(imageNamed: "player8.png")
        
        self.skatingTextures = [f1, f2, f3, f4, f5, f6, f7, f8, f7, f6, f5, f4, f3, f2, f1]
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
    }
    
    fileprivate func generatePath() -> CGPath {
        
        let rect = CGRect(x: self.frame.origin.x + 5, y: self.frame.origin.y + 5, width: self.frame.width - 10, height: self.frame.height - 25)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: self.frame.width / 2)
        
        return path.cgPath
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
        print("RUNNING SKATING TEXTURES")
        self.skatingAction = SKAction.repeatForever(SKAction.animate(with: self.skatingTextures!, timePerFrame: 0.05))
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

open class UserPlayerNode: SKNode {
    var playerNode: PlayerNode!
    var selectionNode = SKShapeNode()
    
    var isSelected = false
    
    public init(withColor color: SKColor = .white, andPosition playerPosition: PlayerPosition) {
        super.init()
        self.playerNode = PlayerNode(withColor: color, andPosition: playerPosition)
        self.playerNode.zPosition = 1
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
        let vector = CGVector(withMagnitude: self.playerNode.speed * 31, andDirectionAngle: self.zRotation)
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
    }
    
    open func rotate(toFacePoint point: CGPoint, withDuration duration: TimeInterval) {
        self.run(self.rotateAction(toFacePoint: point, withDuration: duration))
    }
    
    fileprivate func setPhysicsBody() {
        let path = self.playerNode.generatePath()
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        self.physicsBody = physicsBody
        self.physicsBody?.isDynamic = true
        self.physicsBody?.mass = 1
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.none
        self.physicsBody?.contactTestBitMask = PhysicsCategory.rink | PhysicsCategory.puck
        self.physicsBody?.friction = 0.7
    }
    
    fileprivate func rotateAction(toFacePoint point: CGPoint, withDuration duration: TimeInterval) -> SKAction {
        let xDiff = self.position.x - point.x
        let yDiff = self.position.y - point.y
        
        let angle = atan2(yDiff, xDiff) + (90 / 180 * CGFloat.pi)
        
        return SKAction.rotate(toAngle: angle, duration: duration)
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
