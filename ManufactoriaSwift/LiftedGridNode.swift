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
  let wrapper = SKSpriteNode()
  //let wrapperWrapper = SKSpriteNode()
  var direction = Direction.North
  
  init(grid: Grid) {
    self.grid = grid
    let beltSize = CGSize(SKTexture(imageNamed: "belt").size().width, Globals.cellSize.height)
    var tempNodes: [SKNode] = []
    var tempBeltSprites: [SKSpriteNode] = []
    for j in 0 ..< grid.space.rows {
      for i in 0 ..< grid.space.columns {
        let cell = grid[GridCoord(i,j)]
        if cell.kind != .Blank {
          let node = SKNode()
          node.setScale(1 / Globals.cellSize.width)
          node.position = CGPoint(CGFloat(i) + 0.5, CGFloat(j) + 0.5)
          tempNodes.append(node)
          let back = SKSpriteNode(texture: nil, color: Globals.backgroundColor, size: Globals.cellSize)
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
            case .PullerRB: pullerLeft.color = Globals.redColor;    pullerRight.color = Globals.blueColor
            case .PullerGY: pullerLeft.color = Globals.greenColor;  pullerRight.color = Globals.yellowColor
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
          let select = SKSpriteNode(texture: nil, color: Globals.highlightColor, size: Globals.cellSize)
          select.alpha = 0.5
          select.zPosition = 3
          node.addChild(select)
          switch cell.direction {
          case .North: break
          case .East: node.zRotation = CGFloat(-M_PI_2)
          case .West: node.zRotation = CGFloat(M_PI_2)
          case .South: node.zRotation = CGFloat(M_PI)
          }
          wrapper.addChild(node)
        }
      }
    }
    nodes = tempNodes
    beltSprites = tempBeltSprites
    super.init()
    self.zPosition = 5
    //wrapperWrapper.addChild(wrapper)
    //addChild(wrapperWrapper)
    addChild(wrapper)
  }
  
  func updateWithClippedBeltTexture(clippedBeltTexture: SKTexture) {
    for beltSprite in beltSprites {beltSprite.texture = clippedBeltTexture}
  }
  
  func snapToNearestCoord() {
    runAction(SKAction.moveTo(CGPoint(
      round(position.x + wrapper.position.x) - wrapper.position.x,
      round(position.y + wrapper.position.y) - wrapper.position.y
      ), duration: 0.2).easeOut(), withKey: "move")
  }
  
  func rotateCWAroundTouch(touch: UITouch) {
    let wrapperPositionInParent = convertPoint(wrapper.position, toNode: parent!)
    let touchLocationInWrapper = touch.locationInNode(wrapper)
    let centeredTouchLocationInWrapper = CGPoint(round(touchLocationInWrapper.x+0.5)-0.5, round(touchLocationInWrapper.y+0.5)-0.5)
    position = parent!.convertPoint(centeredTouchLocationInWrapper, fromNode: wrapper)
    wrapper.position = convertPoint(wrapperPositionInParent, fromNode: parent!)
    var newAngle: CGFloat = 0
    switch direction {
    case .North:
      newAngle = CGFloat(-M_PI_2)
      direction = .East
    case .East:
      newAngle = CGFloat(-M_PI)
      direction = .South
    case .South:
      newAngle = CGFloat(-1.5 * M_PI)
      direction = .West
    case .West:
      zRotation += CGFloat(2 * M_PI)
      direction = .North
    }
    runAction(SKAction.rotateToAngle(newAngle, duration: 0.2).easeOut(), withKey: "rotate")
    snapToNearestCoord()
  }
  
  func zeroWrapperPosition() {
    position = convertPoint(wrapper.position, toNode: parent!)
    wrapper.position = CGPointZero
  }
}