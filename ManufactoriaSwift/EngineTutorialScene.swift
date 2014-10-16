//
//  EngineTutorialScene.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 10/15/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class EngineTutorialScene: GameScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  
  init(size: CGSize) {
    super.init(size: size, levelNumber: 0)
    statusNode.instructionsLabel.text = "The malevolence engine\nsees all flaws."
    statusNode.leftArrowWrapper.removeFromParent()
    statusNode.rightArrowWrapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    toolbarNode.userInteractionEnabled = false
    toolbarNode.undoCancelSwapper.removeFromParent()
    toolbarNode.redoConfirmSwapper.removeFromParent()
    toolbarNode.leftArrowWrapper.removeFromParent()
    toolbarNode.rightArrowWrapper.removeFromParent()
    for button in toolbarNode.drawToolButtons {button.removeFromParent()}
  }
  
  override func fitToSize() {
    super.fitToSize()
    toolbarNode.robotButton.position.y = 0
  }
  
  override var state: State {
    didSet {
      switch state {
      case .Editing: break
      case .Thinking: break
      case .Testing: break
      case .Congratulating: break
      }
    }
  }
}
