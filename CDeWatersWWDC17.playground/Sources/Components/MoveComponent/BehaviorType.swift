//
//  MoveBehavior.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/26/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import SpriteKit
import GameplayKit

public enum BehaviorType: String {
    case chasePuck, defendGoal, supportPuckCarrier, attackPuckCarrier, wander
    
    var goals: [GKGoal] {
        switch self {
        case .chasePuck :
            return self.chasePuckGoals
        case .defendGoal :
            return self.defendGoals
        case .supportPuckCarrier :
            return self.supportPuckCarrierGoals
        case .attackPuckCarrier :
            return self.attackPuckCarrierGoals
        case .wander :
            let goal = GKGoal(toWander: 100)
            return [goal]
        }
    }
    
    var weights: [NSNumber] {
        switch self {
        case .chasePuck, .attackPuckCarrier, .wander :
            return [1]
        case .defendGoal :
            return [0.3, 0.3, 0.8]
        case .supportPuckCarrier :
            return [0.4, 0.7, 1]
        }
    }
    
    private var chasePuckGoals: [GKGoal] {
        let chasePuckGoal = GKGoal(toSeekAgent: Puck.shared.puckComponent)
        return [chasePuckGoal]
    }
    
    private var defendGoals: [GKGoal] {
        let defendGoal = GKGoal(toSeekAgent: (userTeam?.hasPuck)! ? Net.topNet.netComponent : Net.bottomNet.netComponent)
        let playerToAlignWith = Rink.shared.puckCarrier!.agent
        let alignWithPuckCarrierGoal = GKGoal(toAlignWith: [playerToAlignWith], maxDistance: 1500, maxAngle: Float.pi / 2)
        let attackGoal = GKGoal(toSeekAgent: playerToAlignWith)
        
        return [defendGoal, attackGoal, alignWithPuckCarrierGoal]
    }
    
    private var supportPuckCarrierGoals: [GKGoal] {
        let puckCarrier = Rink.shared.puckCarrier!.agent
        let aidPuckCarrier = GKGoal(toAlignWith: [puckCarrier], maxDistance: 1000, maxAngle: Float.pi)
        let moveUpWithPuckCarrier = GKGoal(toSeekAgent: puckCarrier)
        let avoidOtherTeam = GKGoal(toAvoid: Rink.shared.puckCarrier!.oppositeTeam.agents, maxPredictionTime: 0.2)
        return [aidPuckCarrier, moveUpWithPuckCarrier, avoidOtherTeam]
    }
    
    private var attackPuckCarrierGoals: [GKGoal] {
        let puckCarrier = (Rink.shared.puckCarrier?.isSelected)! ? Rink.shared.puckCarrier!.userComponent : Rink.shared.puckCarrier!.moveComponent
        let attackGoal = GKGoal(toSeekAgent: puckCarrier!)
        return [attackGoal]
    }
    
}
