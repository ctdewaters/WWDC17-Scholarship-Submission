import SpriteKit

fileprivate let netWidth: CGFloat = 55
fileprivate let netDepth: CGFloat = 21.9


public class NetNode: SKSpriteNode {
    public init(atRinkEnd rinkEnd: RinkEnd) {
        //Load textures
        super.init(texture: SKTexture(imageNamed: "netTexture.png"), color: SKColor.clear, size: CGSize(width: netWidth, height: netDepth))
        self.position = rinkEnd.point
        self.anchorPoint = CGPoint(x: 0.5, y: 1)
        if rinkEnd == .top {
            self.zRotation = CGFloat.pi
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum RinkEnd {
    case top, bottom
    
    var point: CGPoint {
        if self == .top {
            return CGPoint(x: 2, y: 440)
        }
        return CGPoint(x: 2, y: -440)
    }
}
