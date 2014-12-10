//
//  MenuLevelButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/18/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol MenuLevelButtonDelegate: class {
  func transitionToGameSceneWithLevelKey(levelKey: String)
}

class MenuLevelButton: BetterButton {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: MenuLevelButtonDelegate!
  let labelOff = SKLabelNode()
  let spriteOn: SKSpriteNode?
  let labelOn: SKLabelNode?
  let shimmerNode = ShimmerNode()
  var arrowN, arrowE, arrowS, arrowW: SKSpriteNode?
  
  init(levelKey: String) {
    if GameProgressData.sharedInstance.level(levelKey)?.isUnlocked ?? false {
      spriteOn = SKSpriteNode()
      labelOn = SKLabelNode()
      spriteOn?.addChild(labelOn!)
    }
    super.init(nodeOff: SKNode(), nodeOn: spriteOn ?? SKNode(), touchSize: CGSizeZero)
    nodeOff?.addChild(labelOff)
    spriteOn?.color = Globals.highlightColor
    if let levelProgressData = GameProgressData.sharedInstance.level(levelKey) {
      labelOff.fontSmall()
      labelOn?.fontSmall()
      labelOn?.fontColor = Globals.backgroundColor
      if levelProgressData.isUnlocked {
        if levelProgressData.isComplete {
          labelOff.fontColor = Globals.strokeColor
        } else {
          labelOff.fontColor = Globals.highlightColor
        }
      } else {
        labelOff.fontColor = Globals.backgroundColor
        userInteractionEnabled = false
      }
    }
    labelOff.position.y = -Globals.smallEm / 2
    labelOn?.position.y = -Globals.smallEm / 2
    if let levelSetup = LevelLibrary[levelKey] {
      touchUpInsideClosure = {[unowned self] in self.delegate.transitionToGameSceneWithLevelKey(levelKey)}
      labelOff.text = levelSetup.tag
      labelOn?.text = levelSetup.tag
    }
    shimmerNode.zPosition = -1
    shimmerNode.startMidShimmer()
    addChild(shimmerNode)
  }
  
  override var size: CGSize {
    didSet {
      shimmerNode.size = size
      spriteOn?.size = size
      arrowN?.position.y = size.height/2
      arrowE?.position.x = size.width/2
      arrowS?.position.y = -size.height/2
      arrowW?.position.x = -size.width/2
    }
  }
  
  func addArrowForDirection(direction: Direction) {
    let arrow = SKSpriteNode(IPAD ? "enterExitArrow46" : "enterExitArrow29")
    arrow.zPosition = 3
    switch direction {
    case .North:
      arrowN = arrow
    case .East:
      arrow.zRotation = -PI/2
      arrowE = arrow
    case .South:
      arrow.zRotation = PI
      arrowS = arrow
    case .West:
      arrow.zRotation = PI/2
      arrowW = arrow
    }
    addChild(arrow)
  }
}