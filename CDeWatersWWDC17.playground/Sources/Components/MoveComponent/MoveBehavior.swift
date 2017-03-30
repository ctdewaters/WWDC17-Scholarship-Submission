//
//  MoveBehavior.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/26/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

public class MoveBehavior: GKBehavior {

    public init(forPlayerOnTeam team: Team, withPlayerPosition pPosition: PlayerPosition, withTargetSpeed targetSpeed: Float) {
        super.init()
        self.update(forPlayerOnTeam: team, withPlayerPosition: pPosition, withTargetSpeed: targetSpeed)
    }
    
    public func update(forPlayerOnTeam team: Team, withPlayerPosition pPosition: PlayerPosition, withTargetSpeed targetSpeed: Float) {
        if let thisPlayer = team.player(withPosition: pPosition) {
            if !team.hasPuck {
                if !team.oppositeTeam.hasPuck {
                    //Puck not occupied. Go for it!
                    let puckGoal = GKGoal(toSeekAgent: Puck.shared.puckComponent)
                    self.setWeight(1, for: puckGoal)
                    
                }
                else {
                    
                    //Attack the puck carrier on the opposite team
                    let attackGoal = GKGoal(toSeekAgent: team.oppositeTeam.puckCarrier!.playerComponent!)
                    self.setWeight(1, for: attackGoal)
                }
            }
            else {
                if team.isUserControlled {
                    let attackGoal = GKGoal(toWander: targetSpeed / 4)
                    self.setWeight(1, for: attackGoal)
                }
                else {
                    //On enemy team
                    let attackGoal = GKGoal(toWander: targetSpeed / 4)
                    self.setWeight(1, for: attackGoal)
                }
            }
        }
    }

}

//Extending Array's functionality when it is a Team
extension Array where Element:Player {
    var isUserControlled: Bool {
        if self.count > 0 {
            return !self[0].isOnOpposingTeam
        }
        return false
    }
    
    var oppositeTeam: Team {
        if self.isUserControlled {
            return opposingTeam!
        }
        return userTeam!
    }
    
    var puckCarrier: Player? {
        for player: Player in self {
            if player.hasPuck {
                return player
            }
        }
        return nil
    }
    
    var forwards: Team {
        var array = Team()
        for player: Player in self {
            if player.pPosition.isForward {
                array.append(player)
            }
        }
        return array
    }
    
    var hasPuck: Bool {
        for player: Player in self {
            if player.hasPuck {
                return true
            }
        }
        return false
    }
    
    var defensemen: Team {
        var array = Team()
        for player: Player in self {
            if player.pPosition.isDefenseman {
                array.append(player)
            }
        }
        return array
    }
    
    var goalie: Player? {
        for player: Player in self {
            if player.pPosition == PlayerPosition.goalie {
                return player
            }
        }
        return nil
    }
    
    var moveComponents: [MoveComponent] {
        var components = [MoveComponent]()
        for player: Player in self {
            if let moveComponent = player.moveComponent {
                components.append(moveComponent)
            }
        }
        return components
    }
    
    var moveComponentSystem: GKComponentSystem<MoveComponent> {
        let componentSystem = GKComponentSystem(componentClass: MoveComponent.self)
        for component in self.moveComponents {
            componentSystem.addComponent(component)
        }
        return componentSystem as! GKComponentSystem<MoveComponent>
    }
        
    func player(withPosition pPosition: PlayerPosition) -> Player? {
        for player: Player in self {
            if player.pPosition == pPosition {
                return player
            }
        }
        return nil
    }
}
