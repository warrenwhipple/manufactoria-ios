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
    let backIcon = SKSpriteNode("skipIconOff")
    let slowerIcon = SKSpriteNode("speedIconOff")
    let fasterIcon = SKSpriteNode("speedIconOff")
    let skipIcon = SKSpriteNode("skipIconOff")
    backIcon.xScale = -1
    slowerIcon.xScale = -1
    backButton = Button(texture: nil, color: nil, size: CGSize(48))
    slowerButton = Button(texture: nil, color: nil, size: CGSize(48))
    fasterButton = Button(texture: nil, color: nil, size: CGSize(48))
    skipButton = Button(texture: nil, color: nil, size: CGSize(48))
    backButton.addChild(backIcon)
    slowerButton.addChild(slowerIcon)
    fasterButton.addChild(fasterIcon)
    skipButton.addChild(skipIcon)
    speedLabel = SKLabelNode()
    speedLabel.fontMedium()
    speedLabel.fontColor = Globals.strokeColor
    speedLabel.horizontalAlignmentMode = .Center
    speedLabel.verticalAlignmentMode = .Center
    speedLabel.text = ""
    
    super.init()
    
    slowerButton.touchDownClosure = {
      [unowned self] in
      if self.delegate != nil && self.delegate!.gameSpeed > 0.25 {
        self.delegate!.gameSpeed *= 0.5
      }
    }
    fasterButton.touchDownClosure = {
      [unowned self] in
      if self.delegate != nil && self.delegate!.gameSpeed < 32 {
        self.delegate!.gameSpeed *= 2
      }
    }
    backButton.touchDownClosure = {
      [unowned self] in
      if self.delegate != nil {
        self.delegate!.loadLastTape()
      }
    }
    skipButton.touchDownClosure = {
      [unowned self] in
      if self.delegate != nil {
        self.delegate!.skipTape()
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
