//
//  LiftedGridNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 9/6/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class LiftedGridNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  let grid: Grid
  let nodes: [SKNode]
  let beltSprites: [SKSpriteNode]
  
  init(grid: Grid) {
    self.grid = grid
    let beltSize = CGSize(SKTexture(imageNamed: "belt").size().width, Globals.cellPointSize.height)
    var tempNodes: [SKNode] = []
    var tempBeltSprites: [SKSpriteNode] = []
    for j in 0 ..< grid.space.rows {
      for i in 0 ..< grid.space.columns {
        let cell = grid[GridCoord(i,j)]
        if cell.kind != .Blank {
          let node = SKNode()
          node.setScale(1 / Globals.cellPointSize.width)
          node.position = CGPoint(CGFloat(i) + 0.5, CGFloat(j) + 0.5)
          tempNodes.append(node)
          let back = SKSpriteNode(texture: nil, color: Globals.backgroundColor, size: Globals.cellPointSize)
          back.alpha = 0
          back.runAction(SKAction.fadeAlphaTo(0.8, duration: 0.4))
          node.addChild(back)
          let belt = SKSpriteNode(texture: nil, color: Globals.strokeColor, size: beltSize)
          belt.colorBlendFactor = 1
          tempBeltSprites.append(belt)
          belt.zPosition = 1
          node.addChild(belt)
          switch cell.kind {
          case .Bridge:
            let bridge = SKSpriteNode(texture: nil, color: Globals.strokeColor, size: beltSize)
            bridge.colorBlendFactor = 1
            bridge.zRotation = CGFloat(-M_PI_2)
            tempBeltSprites.append(bridge)
            bridge.zPosition = 1
            node.addChild(bridge)
          case .PusherB, .PusherR, .PusherB, .PusherG:
            let pusher = SKSpriteNode("pusher")
            switch cell.kind {
            case .PusherB: pusher.color = Globals.blueColor
            case .PusherR: pusher.color = Globals.redColor
            case .PusherG: pusher.color = Globals.greenColor
            default:       pusher.color = Globals.yellowColor
            }
            pusher.zPosition = 2
            node.addChild(pusher)
          case .PullerBR, .PullerRB, .PullerGY,  .PullerYG:
            let pullerLeft = SKSpriteNode("pullerHalf")
            let pullerRight = SKSpriteNode("pullerHalf")
            switch cell.kind {
            case .PullerBR: pullerLeft.color = Globals.blueColor;   pullerRight.color = Globals.redColor
            case .PullerBR: pullerLeft.color = Globals.redColor;    pullerRight.color = Globals.blueColor
            case .PullerBR: pullerLeft.color = Globals.greenColor;  pullerRight.color = Globals.yellowColor
            default:        pullerLeft.color = Globals.yellowColor; pullerRight.color = Globals.greenColor
            }
            pullerLeft.anchorPoint.x = 1
            pullerRight.anchorPoint.x = 1
            pullerRight.zRotation = CGFloat(M_PI)
            pullerLeft.zPosition = 2
            pullerRight.zPosition = 2
            node.addChild(pullerLeft)
            node.addChild(pullerRight)
          default: break
          }
          let select = SKSpriteNode(texture: nil, color: Globals.highlightColor, size: Globals.cellPointSize)
          select.alpha = 0.5
          select.zPosition = 3
          node.addChild(select)
          switch cell.direction {
          case .North: break
          case .East: node.zRotation = CGFloat(-M_PI_2)
          case .West: node.zRotation = CGFloat(M_PI_2)
          case .South: node.zRotation = CGFloat(M_PI)
          }
        }
      }
    }
    nodes = tempNodes
    beltSprites = tempBeltSprites
    super.init()
    self.zPosition = 5
    for node in nodes {self.addChild(node)}
  }
  
  func updateWithClippedBeltTexture(clippedBeltTexture: SKTexture) {
    for beltSprite in beltSprites {beltSprite.texture = clippedBeltTexture}
  }
}