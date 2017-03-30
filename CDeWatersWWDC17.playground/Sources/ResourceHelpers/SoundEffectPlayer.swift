import AVFoundation

public class SoundEffectPlayer: NSObject {
    public static let boards = SoundEffectPlayer()
    public static let puck = SoundEffectPlayer()
    public static let player = SoundEffectPlayer()
    
    fileprivate var player = AVAudioPlayer()
    
    public func play(soundEffect: SoundEffect, indefinitely: Bool? = nil) {
        
        do {
            self.player = try AVAudioPlayer(contentsOf: soundEffect.assetURL)
            if let indefinitely = indefinitely {
                if indefinitely {
                    self.player.numberOfLoops = -1
                }
            }
            self.player.play()

        }
        catch {
            Swift.print(error)
        }
    }
    
    public func stop() {
        self.player.stop()
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
