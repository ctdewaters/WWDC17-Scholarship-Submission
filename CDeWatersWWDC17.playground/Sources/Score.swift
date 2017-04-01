//
//  Score.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/19/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import Cocoa

public class Score: NSObject {
    
    static let shared = Score()
    
    fileprivate var userScore: Int = 0
    fileprivate var cpuScore: Int = 0
    
    public func score(forUserTeam userGoal: Bool) {
        if userGoal {
            self.userScore += 1
        }
        else {
            self.cpuScore += 1
        }
    }
    
    override public init() {
        super.init()
    }
    
}
