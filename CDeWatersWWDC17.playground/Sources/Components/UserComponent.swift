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

public class UserComponent: GKComponent, ControlKeyDelegate {
    
    public static let shared = UserComponent()
    
    fileprivate var activeMovementKeys = [ControlKey]()
    
    public override func didAddToEntity() {
        super.didAddToEntity()
        self.playerComponent?.select()
    }
    
    deinit {
        self.playerComponent?.deselect()
    }
    
    //MARK: - ControlKeyDelegate
    public func didRecieveKeyInput(withControlKey controlKey: ControlKey) {
        if !activeMovementKeys.contains(controlKey) && controlKey.isMovementKey {
            //Move the player
            if activeMovementKeys.count == 0 {
                playerComponent?.animateSkatingTextures()
            }
            else {
                self.removeOppositeKey(fromKey: controlKey)
            }
            activeMovementKeys.append(controlKey)
        }
        else if controlKey.isDekeKey {
          //Deking
            playerComponent?.stopSkatingAction()
            playerComponent?.deke(withControlKey: controlKey)
        }
        else if controlKey == .upArrow {
            //Shoot puck
            playerComponent?.shootPuck(atPoint: Net.topNet.node.position)
        }
        else if controlKey == .space {
            //Pass the puck to closest player
            Rink.shared.selectPlayerClosestToPuck()
        }
    }
    
    public func didEndKeyInput(withControlKey controlKey: ControlKey) {
        if controlKey.isDekeKey {
            playerComponent?.deke()
        }
        else {
            for i in 0..<activeMovementKeys.count {
                if activeMovementKeys[i] == controlKey {
                    activeMovementKeys.remove(at: i)
                    break
                }
            }
            if activeMovementKeys.count == 0 {
                player?.playerComponent?.returnToIdle()
            }
        }
    }
    
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
    
    //MARK: - Calculated variables
    
    //The player entity
    fileprivate var player: Player? {
        return self.entity as? Player
    }
    
    //The player component
    fileprivate var playerComponent: PlayerComponent? {
        return self.player?.playerComponent
    }

}
