import SpriteKit

public protocol ControlKeyDelegate {
    func didRecieveKeyInput(withControlKey controlKey: ControlKey)
    func didEndKeyInput(withControlKey controlKey: ControlKey)
}

public class GameView: SKView {

    public var controlKeyDelegate: ControlKeyDelegate?
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        if let controlKey = ControlKey(rawValue: event.keyCode) {
            controlKeyDelegate?.didRecieveKeyInput(withControlKey: controlKey)
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        if let controlKey = ControlKey(rawValue: event.keyCode) {
            controlKeyDelegate?.didEndKeyInput(withControlKey: controlKey)
        }
    }
    
}

//Enum for control keys

public enum ControlKey: UInt16 {
    //Move player keys
    case upKey = 13 // W
    case leftKey = 0 // A
    case downKey = 1 // S
    case rightKey = 2 // D
    
    //Move stick keys
    case leftArrow = 123 // Left arrow
    case rightArrow = 124 // Right arrow
    case upArrow = 126 // Up arrow
    case downArrow = 125 //Down arrow
    
    //Space key
    case space = 49
    
    public static func from(event: NSEvent) -> ControlKey? {
        return ControlKey(rawValue: event.keyCode)
    }
    
    public var oppositeKey: ControlKey {
        switch self {
        case .upKey :
            return .downKey
        case .downKey :
            return .upKey
        case .leftKey :
            return .rightKey
        case .rightKey :
            return .leftKey
        case .leftArrow :
            return .rightArrow
        case .rightArrow :
            return .leftArrow
        case .upArrow :
            return .downArrow
        case .downArrow :
             return .upArrow
        case .space :
            return .space
        }
    }
    
    public var isMovementKey: Bool {
        switch self {
        case .upKey, .leftKey, .rightKey, .downKey :
            return true
        default :
            return false
        }
    }
    
    public var isDekeKey: Bool {
        switch self {
        case .leftArrow, .rightArrow :
            return true
        default :
            return false
        }
    }
}
