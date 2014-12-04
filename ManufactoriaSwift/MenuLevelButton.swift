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

class MenuLevelButton: Button {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: MenuLevelButtonDelegate!
  let spriteOff = SKSpriteNode()
  let spriteOn = SKSpriteNode()
  let shimmerNode = ShimmerNode()
  var arrowN, arrowE, arrowS, arrowW: SKSpriteNode?
  
  init(levelKey: String) {
    super.init(nodeOff: spriteOff, nodeOn: spriteOn, touchSize: CGSizeZero)
    shimmerNode.zPosition = -1
    shimmerNode.startMidShimmer()
    addChild(shimmerNode)
    spriteOn.color = Globals.highlightColor
    let labelOff = SKLabelNode()
    let labelOn = SKLabelNode()
    labelOff.fontColor = Globals.highlightColor
    labelOn.fontColor = Globals.backgroundColor
    labelOff.fontSmall()
    labelOn.fontSmall()
    labelOff.position.y = -Globals.smallEm / 2
    labelOn.position.y = -Globals.smallEm / 2
    if let levelSetup = LevelLibrary[levelKey] {
      touchUpInsideClosure = {[unowned self] in self.delegate.transitionToGameSceneWithLevelKey(levelKey)}
      labelOff.text = levelSetup.tag
      labelOn.text = levelSetup.tag
    } else {
      println("MenuLevelButton.init: No key for: " + levelKey)
    }
    if let levelProgressData = GameData.sharedInstance.levelProgressDictionary[levelKey] {
      if levelProgressData.isComplete {
        labelOff.color = Globals.strokeColor
      }
    }
    spriteOff.addChild(labelOff)
    spriteOn.addChild(labelOn)
  }
  
  override var size: CGSize {
    didSet {
      shimmerNode.size = size
      spriteOff.size = size
      spriteOn.size = size
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