//
//  TutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/21/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var swipeHint = SKSpriteNode("swipeArrow")
  var swipePulseAction: SKAction!
  
  override init(size: CGSize, var levelKey: String) {
    super.init(size: size, levelKey: levelKey)
    statusNode.leftArrowWrapper.removeFromParent()
    swipeHint.color = Globals.highlightColor
    //swipeHint.anchorPoint.x = 0
    swipeHint.zPosition = -1
    swipePulseAction = SKAction.repeatActionForever(SKAction.sequence([
      SKAction.waitForDuration(2),
      SKAction.group([
        SKAction.fadeAlphaTo(1, duration: 0),
        SKAction.moveToX(0, duration: 0),
        ]),
      SKAction.group([
        SKAction.fadeAlphaTo(0, duration: 0.5),
        SKAction.moveToX(Globals.iconSpan * 0.5, duration: 0.5).easeIn(),
        ])
      ]))
  }
  
  func startSwipePulse() {
    swipeHint.alpha = 0
    swipeHint.position.x = 0
    swipeHint.runAction(swipePulseAction, withKey: "pulse")
    if swipeHint.parent == nil {statusNode.rightArrow.addChild(swipeHint)}
  }
  
  func stopSwipePulse() {
    swipeHint.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0, duration: 0.2), SKAction.removeFromParent()]))
  }
  
  override func swipeNodeDidSnapToIndex(index: Int) {
    // show left swipe arrow on first swipe
    if index != 1 && statusNode.leftArrowWrapper.parent == nil {
      statusNode.leftArrowWrapper.alpha = 0
      statusNode.leftArrowWrapper.runAction(SKAction.fadeAlphaTo(1, duration: 0.2), withKey: "fade")
      statusNode.wrapper.addChild(statusNode.leftArrowWrapper)
    }
  }

}