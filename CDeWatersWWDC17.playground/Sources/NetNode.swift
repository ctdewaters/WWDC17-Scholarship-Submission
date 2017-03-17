import SpriteKit
import UIKit

fileprivate let netWidth: CGFloat = 55
fileprivate let netDepth: CGFloat = 21.9


public class NetNode: SKSpriteNode {
    public init(atRinkEnd rinkEnd: RinkEnd) {
        //Load textures
        super.init(texture: SKTexture(imageNamed: "netTexture.png"), color: SKColor.clear, size: CGSize(width: netWidth, height: netDepth))
        self.position = rinkEnd.point
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.setPhysicsBody()
        if rinkEnd == .top {
            self.zRotation = CGFloat.pi
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setPhysicsBody() {
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
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
