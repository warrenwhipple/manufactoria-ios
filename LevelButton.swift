//
//  LevelButton.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class LevelButton: SKSpriteNode {
  let levelNumber: Int
  let label = SKLabelNode()
  var touch: UITouch? = nil
  
  init(levelNumber: Int, text: String, isEnabled: Bool) {
    self.levelNumber = levelNumber
    super.init(texture: nil, color: UIColor(white: 0.1, alpha: 1), size: CGSizeZero)
    self.userInteractionEnabled = isEnabled
    label.fontSize = 12
    label.fontName = "HelveticaNeue-Light"
    label.verticalAlignmentMode = .Center
    label.text = text
    label.alpha = 0
    addChild(label)
    let wait = SKAction.waitForDuration(0.1 * NSTimeInterval(levelNumber + 1))
    if isEnabled {
      runAction(SKAction.sequence([wait, SKAction.colorizeWithColor(UIColor(white: 0.3, alpha: 1), colorBlendFactor: 1, duration: 1)]))
      label.runAction(SKAction.sequence([wait, SKAction.fadeAlphaTo(1, duration: 2)]))
    }

  }
  
  func lightUpWithDelay(delay: CGFloat) {
    
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    scene.view.presentScene(GameScene(size: scene.view.bounds.size, levelNumber: levelNumber), transition: SKTransition.crossFadeWithDuration(0.5))
  }
}

class ResetButton: LevelButton {
  init(levelNumber: Int) {
    super.init(levelNumber: levelNumber, text: "reset", isEnabled: true)
    removeAllActions()
    runAction(SKAction.sequence([SKAction.waitForDuration(0.1 * NSTimeInterval(levelNumber + 1)), SKAction.colorizeWithColor(UIColor(red: 0.3, green: 0.2, blue: 0.2, alpha: 1), colorBlendFactor: 1, duration: 1)]))
  }
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    scene.view.presentScene(ResetScene(size: scene.view.bounds.size), transition: SKTransition.crossFadeWithDuration(0.5))
  }
}