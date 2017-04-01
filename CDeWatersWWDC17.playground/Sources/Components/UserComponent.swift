//
//  UserComponent.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/25/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import GameplayKit
import SpriteKit
import Cocoa

///The UserComponent class. When added to a user controlled player, the player is selected.

public class UserComponent: GKAgent2D, GKAgentDelegate, ControlKeyDelegate {
    
    public static let shared = UserComponent()
    
    fileprivate var activeMovementKeys = [ControlKey]()
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        self.delegate = self
        self.playerComponent?.select()
    }
    
    deinit {
        self.playerComponent?.deselect()
    }
    
    //MARK: - ControlKeyDelegate
    
    ///Received input from the keyboard.
    public func didRecieveKeyInput(withControlKey controlKey: ControlKey) {
        
        if GoalPresentation.shared.isPresented {
            GoalPresentation.shared.dismissPresentationView()
        }
        
        if !activeMovementKeys.contains(controlKey) && controlKey.isMovementKey {
            //Key not currently activated, and is a movement key
            
            //Move the player
            if activeMovementKeys.count == 0 || playerComponent?.animatingSkating == false {
                //User just began player movement, or the player is not animating skating.
                
                //Animate the player's skating.
                playerComponent?.animateSkatingTextures()
            }
            else {
                //Remove the key opposite from the one just activated.
                self.removeOppositeKey(fromKey: controlKey)
            }
            //Add the key just activated to the movement keys.
            activeMovementKeys.append(controlKey)
        }
            
        else if controlKey.isDekeKey {
            //Activated key is a deke key.
            
            //Stop skating animation, and deke using the activated key.
            playerComponent?.stopSkatingAction()
            playerComponent?.deke(withControlKey: controlKey)
        }
            
        else if controlKey == .upArrow {
            //Activated key is the shoot key
            
            //Shoot the puck.
            playerComponent?.shootPuck(atPoint: Net.topNet.node.position)
        }
            
        else if controlKey == .space {
            //Activated key is the pass key.
            
            //Pass the puck to closest player.
            Rink.shared.selectPlayerClosestToPuck()
        }
    }
    
    //Ended input from the keyboard.
    public func didEndKeyInput(withControlKey controlKey: ControlKey) {
        if controlKey.isDekeKey {
            //The key is a deke key, remove deke from player.
            playerComponent?.deke()
        }
        else if controlKey.isMovementKey {
            //The key is a movement key, remove it from the active movement keys.
            for i in 0..<activeMovementKeys.count {
                if activeMovementKeys[i] == controlKey {
                    activeMovementKeys.remove(at: i)
                    break
                }
            }
            if activeMovementKeys.count == 0 {
                //This is the last active movement key, return the player to an idle state.
                player?.playerComponent?.returnToIdle()
            }
        }
    }
    
    ///Removes the opposite key from a specified ControlKey.
    fileprivate func removeOppositeKey(fromKey key: ControlKey) {
        for i in 0..<self.activeMovementKeys.count {
            if self.activeMovementKeys[i] == key.oppositeKey {
                self.activeMovementKeys.remove(at: i)
                return
            }
        }
    }
    
    public override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if let player = self.player {
            player.playerComponent?.move(withControlKeys: self.activeMovementKeys)
        }
    }
    
    //MARK: - GKAgentDelegate
    public func agentWillUpdate(_ agent: GKAgent) {
        self.position = float2(withCGPoint: self.player!.node!.position)
    }
    
    public func agentDidUpdate(_ agent: GKAgent) {
    }
    
    //MARK: - Calculated variables
    
    ///The player entity.
    fileprivate var player: Player? {
        return self.entity as? Player
    }
    
    ///The player component.
    fileprivate var playerComponent: PlayerComponent? {
        return self.player?.playerComponent
    }

}
