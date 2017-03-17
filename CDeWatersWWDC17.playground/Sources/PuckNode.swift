import SpriteKit

open class PuckNode: SKShapeNode {
    
    fileprivate let diameter: CGFloat = 4
    
    public override init(){
        super.init()
    
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
        self.fillColor = .black
        
        self.strokeColor = .clear
        self.zPosition = 0
        
        setPhysicsBody()
    }
    
    func setPhysicsBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: diameter / 2, center: CGPoint(x: diameter / 2, y: diameter / 2))
        self.physicsBody?.mass = 0.01
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.puck
        self.physicsBody?.collisionBitMask = PhysicsCategory.all
        self.physicsBody?.contactTestBitMask = PhysicsCategory.rink | PhysicsCategory.player
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

