//
//  GoalView.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/19/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import Cocoa

//class GoalPresentation: NSObject {
//    
//    static let shared = GoalPresentation()
//    
//    fileprivate var presentationView: UIView!
//    fileprivate var goalLabel: UILabel!
//    fileprivate var scoreLabel: UILabel!
//    fileprivate var promptLabel: UILabel!
//    
//    fileprivate var dismissTimer: Timer!
//    fileprivate var dismissTapGesture: UITapGestureRecognizer!
//    
//    override init() {
//        super.init()
//    }
//    
//    open func present(toView view: UIView, withCompletion completion: (()->Void)? = nil) {
//        if self.presentationView == nil {
//            self.presentationView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
//            self.presentationView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//            self.presentationView.alpha = 0
//            
//            goalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: presentationView.frame.width, height: 100))
//            goalLabel.center = CGPoint(x: presentationView.frame.width / 2, y: presentationView.frame.height / 2)
//            goalLabel.text = "GOAL!!!"
//            goalLabel.textColor = .red
//            goalLabel.font = UIFont.systemFont(ofSize: 90, weight: UIFontWeightBlack)
//            goalLabel.alpha = 0
//            goalLabel.textAlignment = .center
//            self.presentationView.addSubview(goalLabel)
//            
//            promptLabel = UILabel(frame: CGRect(x: 0, y: presentationView.frame.maxY - 30, width: presentationView.frame.width, height: 30))
//            promptLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
//            promptLabel.textAlignment = .center
//            promptLabel.textColor = UIColor.black.withAlphaComponent(0.7)
//            promptLabel.alpha = 0
//            promptLabel.text = "Tap the screen to skip."
//            self.presentationView.addSubview(promptLabel)
//            
//            //Adding the dismiss tap gesture
//            dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentationView))
//            self.presentationView.addGestureRecognizer(dismissTapGesture)
//            
//            view.addSubview(self.presentationView)
//            
//            self.animateGoalLabel()
//            
//            SoundEffectPlayer.player.play(soundEffect: .puckHitBoards, indefinitely: true)
//            
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
//                self.presentationView.alpha = 1
//                self.goalLabel.alpha = 1
//                self.promptLabel.alpha = 1
//            }, completion: {
//                completed in
//                if completed {
//                    if let completion = completion {
//                        DispatchQueue.main.async {
//                            completion()
//                        }
//                    }
//                }
//            })
//            
//            self.dismissTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(dismissPresentationView), userInfo: nil, repeats: false)
//        }
//    }
//    
//    fileprivate func animateGoalLabel() {
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
//    }
//    
//    @objc fileprivate func dismissPresentationView() {
//        if dismissTimer != nil {
//           self.dismissTimer.invalidate()
//        }
//        UIView.animate(withDuration: 0.3, animations: {
//            self.presentationView.alpha = 0
//            self.goalLabel.alpha = 0
//        }, completion: {
//            completed in
//            if completed {
//                SoundEffectPlayer.player.stop()
//                self.goalLabel.layer.removeAllAnimations()
//                self.dismissTimer = nil
//                self.presentationView.removeGestureRecognizer(self.dismissTapGesture)
//                self.dismissTapGesture = nil
//                self.presentationView.removeFromSuperview()
//                self.presentationView = nil
//                self.goalLabel = nil
//                self.scoreLabel = nil
//                self.promptLabel = nil
//            }
//        })
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
