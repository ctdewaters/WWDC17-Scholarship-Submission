import AVFoundation

public class SoundEffectPlayer: NSObject {
    public static let boards = SoundEffectPlayer()
    public static let puck = SoundEffectPlayer()
    public static let player = SoundEffectPlayer()
    
    fileprivate var player = AVPlayer()
    
    public func play(soundEffect: SoundEffect) {
        self.player = AVPlayer(url: soundEffect.assetURL)
        self.player.play()
    }
}

public enum SoundEffect {
    case puckHitBoards
    
    public var assetURL: URL {
        var file = String()
        
        switch self {
        case .puckHitBoards :
            file = "puckHitBoards"
        }
        
        return Bundle.main.url(forResource: file, withExtension: "m4a")!
    }
}
