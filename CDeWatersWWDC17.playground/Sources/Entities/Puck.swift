//
//  Puck.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/27/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import GameplayKit
import SpriteKit

public class Puck: GKEntity {
    
    public static let shared = Puck()
    
    override public init() {
        super.init()
        
        let puckComponent = PuckComponent()
        self.addComponent(puckComponent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Calculated variables
    
    public var puckComponent: PuckComponent {
        return self.component(ofType: PuckComponent.self)!
    }

    public var node: SKShapeNode {
        return self.puckComponent.node
    }
    
    public var position: CGPoint {
        set {
            self.node.position = newValue
        }
        get {
            return self.node.position
        }
    }
}
