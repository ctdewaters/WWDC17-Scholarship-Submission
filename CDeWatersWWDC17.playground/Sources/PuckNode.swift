import SpriteKit

open class PuckNode: SKShapeNode {
    
    public override init(){
        super.init()
        
        let diameter: CGFloat = 4
        self.path = CGPath(ellipseIn: CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
        self.fillColor = .black
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: diameter / 2, center: CGPoint(x: diameter / 2, y: diameter / 2))
        self.physicsBody?.mass = 0.01
        self.physicsBody?.allowsRotation = false
        
        self.strokeColor = .clear
        
        self.zPosition = 0
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

