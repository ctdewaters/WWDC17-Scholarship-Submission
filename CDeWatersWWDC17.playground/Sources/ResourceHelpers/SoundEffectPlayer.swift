import AVFoundation

public class SoundEffectPlayer: NSObject {
    public static let boards = SoundEffectPlayer()
    public static let puck = SoundEffectPlayer()
    public static let player = SoundEffectPlayer()
    
    fileprivate var audioPlayer = AVAudioPlayer()
    
    public func play(soundEffect: SoundEffect, indefinitely: Bool? = nil) {
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: soundEffect.assetURL)
            if let indefinitely = indefinitely {
                if indefinitely {
                    self.audioPlayer.numberOfLoops = -1
                }
            }
            self.audioPlayer.play()

        }
        catch {
            Swift.print(error)
        }
    }
    
    public func stop() {
        if self.audioPlayer.isPlaying {
            self.audioPlayer.stop()
        }
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
