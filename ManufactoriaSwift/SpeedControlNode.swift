//
//  SpeedControlNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/16/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class SpeedControlNode: SKNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  weak var delegate: GameScene?
  let backButton: Button
  let slowerButton: Button
  let fasterButton: Button
  let skipButton: Button
  let speedLabel: SKLabelNode
  
  override init() {
    let buttonSize = CGSize(64)
    let backIcon = SKSpriteNode("skipIcon")
    let slowerIcon = SKSpriteNode("speedIcon")
    let fasterIcon = SKSpriteNode("speedIcon")
    let skipIcon = SKSpriteNode("skipIcon")
    backIcon.xScale = -1
    slowerIcon.xScale = -1
    backButton = Button.growButton(size: buttonSize)
    slowerButton = Button.growButton(size: buttonSize)
    fasterButton = Button.growButton(size: buttonSize)
    skipButton = Button.growButton(size: buttonSize)
    backButton.addChild(backIcon)
    slowerButton.addChild(slowerIcon)
    fasterButton.addChild(fasterIcon)
    skipButton.addChild(skipIcon)
    speedLabel = SKLabelNode()
    speedLabel.fontMedium()
    speedLabel.fontColor = Globals.strokeColor
    speedLabel.horizontalAlignmentMode = .Center
    speedLabel.verticalAlignmentMode = .Center
    speedLabel.text = "1X"
    
    super.init()
    
    slowerButton.touchDownClosure = {
      [weak self] in
      if self!.delegate != nil && self!.delegate!.speedAnchor.target > 0.25 {
        self!.delegate!.speedAnchor.target *= 0.5
      }
    }
    fasterButton.touchDownClosure = {
      [weak self] in
      if self!.delegate != nil && self!.delegate!.speedAnchor.target < 32 {
        self!.delegate!.speedAnchor.target *= 2
      }
    }
    backButton.touchDownClosure = {
      [weak self] in
      if self!.delegate != nil {
        self!.delegate!.loadLastTape()
      }
    }
    skipButton.touchDownClosure = {
      [weak self] in
      if self!.delegate != nil {
        self!.delegate!.skipTape()
      }
    }
    
    addChild(backButton)
    addChild(slowerButton)
    addChild(fasterButton)
    addChild(skipButton)
    addChild(speedLabel)
  }
  
  var size: CGSize = CGSizeZero {
    didSet {
      let nodes: [SKNode] = [backButton, slowerButton, speedLabel, fasterButton, skipButton]
      let buttonWidth = size.width / 5.0
      var i = 0
      for node in nodes {
        node.position.x = (CGFloat(i++) + 0.5) * buttonWidth - 0.5 * size.width
        if node != speedLabel {
          (node as Button).size = CGSize(buttonWidth)
        }
      }
    }
  }
  
  var isEnabled: Bool = false {
    didSet {
      if isEnabled == oldValue {return}
      let buttons: [Button] = [backButton, slowerButton, fasterButton, skipButton]
      if isEnabled == true {
        for button in buttons {
          button.userInteractionEnabled = true
        }
      } else {
        for button in buttons {
          button.userInteractionEnabled = false
          button.touch = nil
        }
      }
    }
  }
}
