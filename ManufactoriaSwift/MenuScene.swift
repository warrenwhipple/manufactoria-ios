//
//  MenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/10/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class MenuScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let wrapper = SKNode()
  let levelButtons: [LevelButton]
  
  override init(size: CGSize) {
    var tempLevelButtons: [LevelButton] = []
    let gameData = GameData.sharedInstance
    for i in 0 ..< LevelLibrary.count {
      tempLevelButtons.append(LevelButton(levelNumber: i, text: LevelLibrary[i].tag, isEnabled: i <= gameData.levelsComplete))
    }
    var totalButtons = 26
    if IPAD {totalButtons = 33}
    if tempLevelButtons.count < totalButtons {
      for i in tempLevelButtons.count ..< totalButtons {
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
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}  
  
  func fitToSize() {
    var columns = 4
    if IPAD {columns = 5}
    let buttonWidth = size.width / CGFloat(columns)
    let rows = Int(round(size.height / buttonWidth))
    let buttonHeight = size.height / CGFloat(rows)
    
    let buttonSize = CGSize(buttonWidth, buttonHeight)
    var i = 0
    for levelButton in levelButtons {
      levelButton.shimmerNode.size = buttonSize
      levelButton.position = CGPoint(
        x: (CGFloat(i % columns) + 0.5) * buttonWidth,
        y: -(CGFloat(i / columns) + 0.5) * buttonHeight
      )
      i++
    }
  }
  
  class LevelButton: SKNode {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    let levelNumber: Int
    let label: BreakingLabel
    let shimmerNode: ShimmerNode
    var touch: UITouch?
    
    init(levelNumber: Int, text: String, isEnabled: Bool) {
      self.levelNumber = levelNumber
      
      label = BreakingLabel()
      if isEnabled {
        label.fontSmall()
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
      println("level \(levelNumber) scene")
    }
  }
  
  class UnlockButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "unlock", isEnabled: true)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
      println("unlock scene")
    }
  }
  
  class ResetButton: LevelButton {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    init(levelNumber: Int) {
      super.init(levelNumber: levelNumber, text: "reset", isEnabled: true)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
      println("reset scene")
    }
  }
}