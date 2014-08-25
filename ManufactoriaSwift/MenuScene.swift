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
      tempLevelButtons.append(LevelButton(levelNumber: i, text: LevelLibrary[i].tag, isEnabled: i <= gameData.levelsComplete))
    }
    if tempLevelButtons.count < 26 {
      for i in tempLevelButtons.count ..< 26 {
        tempLevelButtons.append(LevelButton(levelNumber: i, text: "", isEnabled: false))
      }
    }
    tempLevelButtons.append(UnlockButton(levelNumber: LevelLibrary.count))
    tempLevelButtons.append(ResetButton(levelNumber: LevelLibrary.count + 1))
    levelButtons = tempLevelButtons
    
    super.init(size: size)
    
    backgroundColor = Globals.backgroundColor
    wrapper.position.y = size.height
    wrapper.addChildren(levelButtons)
    addChild(wrapper)
    fitToSize()
  }
  
  func fitToSize() {
    let buttonSize = CGSize(size.width / 4, size.height / 7)
    var i = 0
    for levelButton in levelButtons {
      levelButton.shimmerNode.size = buttonSize
      levelButton.position = CGPoint(
        x: (CGFloat(i % 4) + 0.5) * buttonSize.width,
        y: -(CGFloat(i / 4) + 0.5) * buttonSize.height
      )
      i++
    }
  }
  
  class LevelButton: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let levelNumber: Int
    let label: SKLabelNode
    let shimmerNode: ShimmerNode
    var touch: UITouch?
    
    init(levelNumber: Int, text: String, isEnabled: Bool) {
      self.levelNumber = levelNumber
      
      label = SKLabelNode()
      if isEnabled {
        label.fontMedium()
        label.verticalAlignmentMode = .Center
        label.fontColor = Globals.strokeColor
        label.text = text
      }
      
      shimmerNode = ShimmerNode()
      shimmerNode.zPosition = 1
      shimmerNode.startMidShimmer()

      super.init()
      userInteractionEnabled = isEnabled
      addChild(label)
      addChild(shimmerNode)
      
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
      scene.view.presentScene(GameScene(size: scene.view.bounds.size, levelNumber: levelNumber), transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
    }
  }
  
  class UnlockButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "unlock", isEnabled: true)
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
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
          }
        },
        noClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
          }
        },
        size: scene.size), transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay()
      )
    }
  }
  
  class ResetButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "reset", isEnabled: true)
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
            view!.presentScene(TitleScene(size: view!.bounds.size), transition: SKTransition.fadeWithColor(Globals.strokeColor, duration: 3).outInPlay())
          }
        },
        noClosure: {
          [weak view = self.scene.view] in
          if view != nil {
            view!.presentScene(MenuScene(size: view!.bounds.size), transition: SKTransition.pushWithDirection(.Right, duration: 0.5).outInPlay())
          }
        },
        size: scene.size), transition: SKTransition.pushWithDirection(.Left, duration: 0.5).outInPlay()
      )
    }
  }
}