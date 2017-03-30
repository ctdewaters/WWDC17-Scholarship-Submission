//
//  Net.swift
//  Hockey Game
//
//  Created by Collin DeWaters on 3/26/17.
//  Copyright © 2017 Collin DeWaters. All rights reserved.
//

import GameplayKit
import SpriteKit

public class Net: GKEntity {
    
    public static let topNet = Net(atRinkEnd: .top)
    public static let bottomNet = Net(atRinkEnd: .bottom)

    public init(atRinkEnd rinkEnd: RinkEnd) {
        super.init()
        
        //Adding the net component
        let netComponent = NetComponent(atRinkEnd: rinkEnd)
        self.addComponent(netComponent)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open var netComponent: NetComponent {
        return self.component(ofType: NetComponent.self)!
    }
    
    open var node: SKSpriteNode {
        return self.netComponent.node
    }
    
    open var zPosition: CGFloat {
        set {
            self.node.zPosition = newValue
        }
        get {
            return self.node.zPosition
        }
    }
    
    open var frame: CGRect {
        return self.node.frame
    }
    
}
