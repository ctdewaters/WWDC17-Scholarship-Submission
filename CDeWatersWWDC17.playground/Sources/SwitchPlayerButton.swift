import UIKit

public let buttonSize: CGFloat = 75

public class SwitchPlayerButton: UIButton {
    
    open var delegate: SwitchPlayerButtonDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
        
        //Adding targets for dragging in and out of the button, and after tapping the button
        self.addTarget(self, action: #selector(self.highlight), for: .touchDown)
        self.addTarget(self, action: #selector(self.removeHighlight), for: .touchDragExit)
        self.addTarget(self, action: #selector(self.highlight), for: .touchDragEnter)
        self.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func highlight() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0.7
        })
    }
    
    @objc fileprivate func removeHighlight() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        })
    }
    
    @objc fileprivate func buttonPressed() {
        self.removeHighlight()
        self.delegate?.buttonDidRecieveUserInput(switchPlayerButton: self)
    }
}

public protocol SwitchPlayerButtonDelegate {
    func buttonDidRecieveUserInput(switchPlayerButton button: SwitchPlayerButton)
}
