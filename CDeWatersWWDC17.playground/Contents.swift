//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport
import SpriteKit

let skView = GameView(frame: CGRect(x: 0, y: 0, width: 728, height: 728))
skView.layer?.backgroundColor = sceneBackgroundColor.cgColor

skView.showsPhysics = false

Rink.shared.scaleMode = .aspectFill
skView.presentScene(Rink.shared)

PlaygroundPage.current.liveView = skView
