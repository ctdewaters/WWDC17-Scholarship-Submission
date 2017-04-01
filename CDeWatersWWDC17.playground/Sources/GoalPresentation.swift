//
//  GoalView.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/19/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import Cocoa

class GoalPresentation: NSObject {
    
    static let shared = GoalPresentation()
    
    fileprivate var presentationView: NSView!
    fileprivate var goalLabel: NSTextField!
    fileprivate var scoreLabel: NSTextField!
    fileprivate var promptLabel: NSTextField!
    
    fileprivate var dismissTimer: Timer!
    
    override init() {
        super.init()
    }
    
    open func present(toView view: NSView, withCompletion completion: (()->Void)? = nil) {
        if self.presentationView == nil {
            self.presentationView = NSView(frame: NSRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            self.presentationView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
            self.presentationView.alphaValue = 0
            
            goalLabel = NSTextField(labelWithString: "GOAL!!!")
            goalLabel.frame = NSRect(x: 0, y: (view.frame.height / 2) + 50, width: presentationView.frame.width, height: 100)
            goalLabel.textColor = .red
            goalLabel.font = NSFont.systemFont(ofSize: 90, weight: NSFontWeightBlack)
            goalLabel.alignment = .center
            self.presentationView.addSubview(goalLabel)
            
            promptLabel = NSTextField(labelWithString: "Press space to skip.")
            promptLabel.frame = NSRect(x: 0, y: presentationView.frame.minY + 30, width: presentationView.frame.width, height: 30)
            promptLabel.font = NSFont.systemFont(ofSize: 15, weight: NSFontWeightBold)
            promptLabel.alignment = .center
            promptLabel.textColor = NSColor.black.withAlphaComponent(0.7)
            self.presentationView.addSubview(promptLabel)
            
            view.addSubview(self.presentationView)
            
            self.animateGoalLabel()
            
            //SoundEffectPlayer.player.play(soundEffect: .puckHitBoards, indefinitely: true)
            
            self.presentationView.fadeIn(withDuration: 0.5, andCompletionBlock: completion)
            
            self.dismissTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(dismissPresentationView), userInfo: nil, repeats: false)
        }
    }
    
    fileprivate func animateGoalLabel() {
//        let pulseAnim = CABasicAnimation(keyPath: "transform.scale")
//        pulseAnim.duration = 0.4
//        pulseAnim.toValue = NSNumber(value: 0.5)
//        pulseAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        pulseAnim.autoreverses = true
//        pulseAnim.repeatCount = .greatestFiniteMagnitude
//        self.goalLabel.layer.add(pulseAnim, forKey: "pulsingAnimation")
//        
//        let rotateAnim = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotateAnim.duration = 0.8
//        rotateAnim.fromValue = NSNumber(value: (7 * Float.pi / 6) + (Float.pi / 2))
//        rotateAnim.toValue = NSNumber(value: (11 * Float.pi / 6) + (Float.pi / 2))
//        rotateAnim.autoreverses = true
//        rotateAnim.repeatCount = .greatestFiniteMagnitude
//        rotateAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        self.goalLabel.layer.add(rotateAnim, forKey: "rotatingAnimation")
    }
    
    @objc fileprivate func dismissPresentationView() {
        if dismissTimer != nil {
           self.dismissTimer.invalidate()
        }
        
        self.presentationView.fadeOut(withDuration: 0.3, andCompletionBlock: {
            //SoundEffectPlayer.player.stop()
            self.dismissTimer = nil
            self.presentationView.removeFromSuperview()
            for view in self.presentationView.subviews {
                view.removeFromSuperview()
            }
            self.presentationView = nil
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public extension NSView {
    func fadeIn(withDuration duration: TimeInterval, andCompletionBlock completion: (()->Void)? = nil) {
        self.wantsLayer = true
        NSAnimationContext.runAnimationGroup({
            context in
            self.isHidden = false
            context.duration = duration
            self.animator().alphaValue = 1
        }, completionHandler: completion)
    }
    
    func fadeOut(withDuration duration: TimeInterval, andCompletionBlock completion: (()->Void)? = nil) {
        self.wantsLayer = true
        NSAnimationContext.runAnimationGroup({
            context in
            self.isHidden = false
            context.duration = duration
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}
