//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
  let wrapper = SKNode()
  let levelButtons: [LevelButton]
  
  init(size: CGSize) {
    var tempLevelButtons: [LevelButton] = []
    let gameData = GameData.sharedInstance
    for i in 0 ..< LevelLibrary.count {
      let levelSetup = LevelLibrary[i]
      tempLevelButtons += LevelButton(levelNumber: i, text: levelSetup.tag, isEnabled: i <= gameData.levelsComplete)
    }
    tempLevelButtons += ResetButton(levelNumber: LevelLibrary.count)
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
    let buttonSize = CGSize(width: buttonSpacing * 0.75, height: buttonSpacing * 0.75)
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
}