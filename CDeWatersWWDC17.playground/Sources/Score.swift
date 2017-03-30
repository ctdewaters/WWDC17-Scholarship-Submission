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
    
    open var userScore: Int = 0
    open var cpuScore: Int = 0
    
    
    override public init() {
        super.init()
    }
    
}
