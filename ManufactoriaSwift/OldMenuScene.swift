//
//  OldMenuScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 11/11/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

/*
class OldMenuScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  var buttons: [Button] = []
  var shimmerNodes: [ShimmerNode] = []
  var glowNodes: [SKSpriteNode] = []
  
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    let gameData = GameData.sharedInstance
    var totalButtons = 28
    if IPAD {totalButtons = 35}
    
    for i in 0 ..< totalButtons {
      let button = Button(nodeOff: SKNode(), nodeOn: SKNode(), touchSize: CGSizeZero)
      let shimmerNode = ShimmerNode()
      shimmerNode.startMidShimmer()
      button.addChild(shimmerNode)
      shimmerNodes.append(shimmerNode)
      if i == totalButtons - 2 {
        button.addChild(buttonLabel("unlock"))
        button.touchUpInsideClosure = {[unowned self] in self.transitionToUnlockScene()}
      } else if i == totalButtons - 1 {
        button.addChild(buttonLabel("reset"))
        button.touchUpInsideClosure = {[unowned self] in self.transitionToResetScene()}
//      } else if i < LevelLibrary.count && i <= gameData.levelsComplete {
      } else if i < LevelLibrary.count {
        button.addChild(buttonLabel(LevelLibrary[i].tag))
        button.touchUpInsideClosure = {[unowned self] in self.transitionToGameSceneWithLevelNumber(i)}
      } else {
        button.userInteractionEnabled = false
      }
      if button.userInteractionEnabled {
        let glowNode = SKSpriteNode()
        glowNode.color = Globals.highlightColor
        glowNode.alpha = 0
        glowNodes.append(glowNode)
        button.addChild(glowNode)
        button.shouldStickyGlow = true
        //button.pressClosure = {glowNode.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.2), withKey: "fade")}
        //button.releaseClosure = {glowNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.2), withKey: "fade")}
      }
      buttons.append(button)
      addChild(button)
    }
    fitToSize()
  }
  
  func buttonLabel(text: String) -> BreakingLabel {
    let label = BreakingLabel()
    label.fontSmall()
    label.verticalAlignmentMode = .Center
    label.fontColor = Globals.strokeColor
    label.text = text
    return label
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
    for button in buttons {
      button.position = CGPoint(
        x: (CGFloat(i % columns) + 0.5) * buttonWidth,
        y: size.height - (CGFloat(i / columns) + 0.5) * buttonHeight
      )
      button.size = buttonSize
      i++
    }
    for shimmerNode in shimmerNodes {shimmerNode.size = buttonSize}
    for glowNode in glowNodes {glowNode.size = buttonSize}
  }
}
*/