//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let wrapper = SKNode()
  let levelButtons: [LevelButton]
  
  override init(size: CGSize) {
    var tempLevelButtons: [LevelButton] = []
    let gameData = GameData.sharedInstance
    for i in 0 ..< LevelLibrary.count {
      let levelSetup = LevelLibrary[i]
      tempLevelButtons.append(LevelButton(levelNumber: i, text: levelSetup.tag, isEnabled: i <= gameData.levelsComplete))
    }
    tempLevelButtons.append(UnlockButton(levelNumber: LevelLibrary.count))
    tempLevelButtons.append(ResetButton(levelNumber: LevelLibrary.count + 1))
    levelButtons = tempLevelButtons
    
    super.init(size: size)
    
    backgroundColor = UIColor.blackColor()
    wrapper.position.y = size.height
    wrapper.addChildren(levelButtons)
    addChild(wrapper)
    fitToSize()
  }
  
  func fitToSize() {
    let columnCount = 4
    let buttonSpacing = size.width / CGFloat(columnCount)
    let buttonSize = CGSize(buttonSpacing * 0.75, buttonSpacing * 0.75)
    var i = 0
    for levelButton in levelButtons {
      levelButton.size = buttonSize
      levelButton.position = CGPoint(
        x: (CGFloat(i % columnCount) + 0.5) * buttonSpacing,
        y: -(CGFloat(i / columnCount) + 0.5) * buttonSpacing
      )
      i++
    }
  }
  
  class LevelButton: SKSpriteNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let levelNumber: Int
    let label = SKLabelNode()
    var touch: UITouch? = nil
    
    init(levelNumber: Int, text: String, isEnabled: Bool) {
      self.levelNumber = levelNumber
      super.init(texture: nil, color: UIColor(white: 0.1, alpha: 1), size: CGSizeZero)
      self.userInteractionEnabled = isEnabled
      label.fontXSmall()
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
  
  class UnlockButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "unlock", isEnabled: true)
      removeAllActions()
      runAction(SKAction.sequence([SKAction.waitForDuration(0.1 * NSTimeInterval(levelNumber + 1)), SKAction.colorizeWithColor(UIColor(red: 0.3, green: 0.2, blue: 0.2, alpha: 1), colorBlendFactor: 1, duration: 1)]))
    }
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      scene.view.presentScene(QuestionScene(
        questionText: "Are you sure you want to\nunlock all levels?",
        yesText: "unlock",
        noText: "cancel",
        yesClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            GameData.sharedInstance.levelsComplete = LevelLibrary.count
            GameData.sharedInstance.save()
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.crossFadeWithDuration(0.5))
          }
        },
        noClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.crossFadeWithDuration(0.5))
          }
        },
        size: scene.size), transition: SKTransition.crossFadeWithDuration(0.5)
      )
    }
  }
  
  class ResetButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "reset", isEnabled: true)
      removeAllActions()
      runAction(SKAction.sequence([SKAction.waitForDuration(0.1 * NSTimeInterval(levelNumber + 1)), SKAction.colorizeWithColor(UIColor(red: 0.3, green: 0.2, blue: 0.2, alpha: 1), colorBlendFactor: 1, duration: 1)]))
    }
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      scene.view.presentScene(QuestionScene(
        questionText: "Are you sure you want to\nerase all progress?",
        yesText: "reset",
        noText: "cancel",
        yesClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            GameData.sharedInstance.levelsComplete = 0
            GameData.sharedInstance.save()
            view!.presentScene(TitleScene(size: view!.bounds.size), transition: SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 3))
          }
        },
        noClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.crossFadeWithDuration(0.5))
          }
        },
        size: scene.size), transition: SKTransition.crossFadeWithDuration(0.5)
      )
    }
  }
}