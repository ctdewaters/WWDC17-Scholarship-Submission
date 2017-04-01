import SpriteKit

public class PlayerTexture {
    
    //MARK: - Textures
    
    //The Faceoff texture
    static let faceoff = SKTexture(imageNamed: "Textures/faceoffPosition.png")
    
    //Skating textures
    static let f1 = SKTexture(imageNamed: "Textures/player1.png")
    static let f2 = SKTexture(imageNamed: "Textures/player2.png")
    static let f3 = SKTexture(imageNamed: "Textures/player3.png")
    static let f4 = SKTexture(imageNamed: "Textures/player4.png")
    static let f5 = SKTexture(imageNamed: "Textures/player5.png")
    static let f6 = SKTexture(imageNamed: "Textures/player6.png")
    static let f7 = SKTexture(imageNamed: "Textures/player7.png")
    static let f8 = SKTexture(imageNamed: "Textures/player8.png")
    static let skatingTextures: [SKTexture] = [f1, f2, f3, f4, f5, f6, f7, f8, f7, f6, f5, f4, f3, f2, f1]
    
    //Shooting textures
    static let shoot1 = SKTexture(imageNamed: "Textures/shoot1.png")
    static let shoot2 = SKTexture(imageNamed: "Textures/shoot2.png")
    static let shoot3 = SKTexture(imageNamed: "Textures/shoot3.png")
    static let shootingTextures: [SKTexture] = [shoot1, shoot2, shoot3]
    
    //Deking textures
    static let dekeNeg2 = SKTexture(imageNamed: "Textures/playerPosition-2.png")
    static let dekeNeg1 = SKTexture(imageNamed: "Textures/playerPosition-1.png")
    static let deke0 = SKTexture(imageNamed: "Textures/playerPosition0.png")
    static let deke1 = SKTexture(imageNamed: "Textures/playerPosition1.png")
    static let deke2 = SKTexture(imageNamed: "Textures/playerPosition2.png")
    
    static let dekeLeftTextures = [deke0, dekeNeg1, dekeNeg2]
    static let dekeRightTextures = [deke0, deke1, deke2]
    
    static let boundSize: CGFloat = 100
    
    
    //MARK: - Functions
    
    //Finds correct texture for deking (UIPanGestureRecognizer translation)
    public class func texture(forTranslation translation: CGPoint) -> SKTexture {
        let translation = self.bound(translationPoint: translation)
        
        let totalRange = boundSize * 2
        let sectorSize = totalRange / 5
        
        let stickHandleUpperBound = (boundSize / 5)
        let stickHandleLowerBound = -(boundSize / 5)
        
        
        if translation.y > stickHandleLowerBound && translation.y < stickHandleUpperBound {
            //Stick handling
            var lowerBound: CGFloat = -boundSize
            for i in -2..<3 {
                let upperBound = lowerBound + sectorSize
                
                if translation.x >= lowerBound && translation.x <= upperBound {
                    return SKTexture(imageNamed: "playerPosition\(i)")
                }
                
                lowerBound += sectorSize
            }
        }
        
        return faceoff
    }
    
    fileprivate class func bound(translationPoint point: CGPoint) -> CGPoint {
        var point = point
        if point.x > boundSize {
            point.x = boundSize
        }
        else if point.x < -boundSize {
            point.x = -boundSize
        }
        if point.y > boundSize {
            point.y = boundSize
        }
        else if point.y < -boundSize {
            point.y = -boundSize
        }
        point.y = -point.y
        return point
    }

}

public extension Notification.Name {
    public static let userShouldShootNotification = Notification.Name("userShouldShootNotification")
}
