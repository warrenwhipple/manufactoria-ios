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
  let backButton = Button(iconOffNamed: "skipIconOff", iconOnNamed: "skipIconOn")
  let slowerButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let fasterButton = Button(iconOffNamed: "speedIconOff", iconOnNamed: "speedIconOn")
  let skipButton = Button(iconOffNamed: "skipIconOff", iconOnNamed: "skipIconOn")
  let speedLabel = SKLabelNode()
  
  override init() {
    super.init()
    
    for child in backButton.children {(child as SKNode).xScale = -1}
    for child in slowerButton.children {(child as SKNode).xScale = -1}

    speedLabel.fontMedium()
    speedLabel.fontColor = Globals.strokeColor
    speedLabel.horizontalAlignmentMode = .Center
    speedLabel.verticalAlignmentMode = .Center
    speedLabel.text = "1X"
    
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
      let positions = distributionForChildren(count: 5, childSize: Globals.iconRoughSize.width, parentSize: size.width)
      backButton.position.x = positions[0]
      slowerButton.position.x = positions[1]
      speedLabel.position.x = positions[2]
      fasterButton.position.x = positions[3]
      skipButton.position.x = positions[4]
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
