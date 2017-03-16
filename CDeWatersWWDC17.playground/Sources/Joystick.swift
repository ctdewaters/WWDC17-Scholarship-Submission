import UIKit

public let joystickSize: CGFloat = 100

public class Joystick: UIView {
    fileprivate var joystickView: UIView!
    fileprivate var joystickOutlineView: UIView!
    
    fileprivate var panGesture: UIPanGestureRecognizer!
    
    public var delegate: JoystickDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        //Setting the outline view
        joystickOutlineView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        joystickOutlineView.backgroundColor = UIColor.clear
        joystickOutlineView.layer.cornerRadius = self.frame.width / 2
        joystickOutlineView.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        joystickOutlineView.layer.borderWidth = 5
        joystickOutlineView.clipsToBounds = true
        
        //Setting the joystick view
        joystickView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: self.frame.height * 0.8))
        joystickView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        joystickView.layer.cornerRadius = (self.frame.width * 0.8) / 2
        joystickView.clipsToBounds = true
        joystickView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        self.addSubview(joystickOutlineView)
        self.addSubview(joystickView)
        
        //Adding pan gesture
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        self.addGestureRecognizer(self.panGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func pan(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            delegate?.joystickDidExitIdle(self)
            UIView.animate(withDuration: 0.25, animations: {
                self.joystickView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.joystickView.backgroundColor = UIColor.black
            })
        }
        if panGesture.state == .changed {
           let translation = panGesture.translation(in: self)
        
            //Calculating the point to move the joystick to
            var point = CGPoint(x: (self.frame.width / 2) + translation.x, y: (self.frame.height / 2) + translation.y)
            point = process(point: point)
            
            //calculate data and send to the protocol
            let data = self.generateData(fromPoint: point)
            delegate?.joystick(self, didGenerateData: data)
            
            UIView.animate(withDuration: 0.05, animations: {
                self.joystickView.center = point
            })
        }
        else if panGesture.state == .ended {
            self.returnJoystickToCenter()
        }
    }
    
    fileprivate func process(point: CGPoint) -> CGPoint {
        var newPoint = point
        if newPoint.x > 100 {
            newPoint.x = 100
        }
        else if newPoint.x < 0 {
            newPoint.x = 0
        }
        if newPoint.y > 100 {
            newPoint.y = 100
        }
        else if newPoint.y < 0 {
            newPoint.y = 0
        }
        return newPoint
    }
    
    fileprivate func generateData(fromPoint point: CGPoint) -> JoystickData {
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        return JoystickData(withDX: point.x - center.x, andDY: -(point.y - center.y))

    }
    
    fileprivate func returnJoystickToCenter() {
        UIView.animate(withDuration: 0.25, animations: {
            self.joystickView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.joystickView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.joystickView.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        })
        
        delegate?.joystickDidReturnToIdle(self)
    }
}

public class JoystickData: TextOutputStreamable {
    var angle, magnitude, x, y: CGFloat!
    
    init(withAngle angle : CGFloat, andMagnitude magnitude: CGFloat) {
        self.angle = angle
        self.magnitude = magnitude
        
        self.x = magnitude * cos(angle)
        self.y = magnitude * sin(angle)
    }
    
    init(withDX dx: CGFloat, andDY dy: CGFloat) {
        self.x = dx
        self.y = dy
        self.magnitude = sqrt(pow(dx, 2) + pow(dy, 2))
        
        if dy < 0 {
            let addOn = CGFloat.pi - acos(dx / self.magnitude)
            self.angle = CGFloat.pi + addOn
        }
        else {
            self.angle = acos(dx / self.magnitude)
        }
    }

    var cgPoint: CGPoint {
        
        return CGPoint(x: x, y: y)
    }
    
    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        target.write("JoystickData(x: \(x), y: \(y), angle: \(angle), magnitude: \(magnitude))")
    }
}

public protocol JoystickDelegate {
    func joystickDidExitIdle(_ joystick: Joystick)
    func joystick(_ joystick: Joystick, didGenerateData joystickData: JoystickData)
    func joystickDidReturnToIdle(_ joystick: Joystick)
}
