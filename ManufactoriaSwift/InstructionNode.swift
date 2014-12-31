//
//  InstructionNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol InstructionNodeDelegate: class {
  func menuButtonPressed()
}

class InstructionNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}

  weak var delegate: InstructionNodeDelegate?
  
  let optionsPage = SKNode()
  let menuButton = Button(text: "menu", fixedWidth: Globals.mediumEm * 8)

  let instructionsPage = SKNode()
  let instructionsLabel = SmartLabel()

  let failPage = SKNode()
  let failLabel = SmartLabel()
  
  
  init(instructions: String) {
    super.init(pages: [optionsPage, instructionsPage])
    
    optionsPage.addChild(menuButton)
    menuButton.dragThroughDelegate = self
    menuButton.isSticky = true
    menuButton.touchUpInsideClosure = {[unowned self] in if let delegate = self.delegate {delegate.menuButtonPressed()}}
    
    instructionsLabel.text = instructions
    instructionsPage.addChild(instructionsLabel)
    
    failPage.addChild(failLabel)
    
    goToIndexWithoutSnap(1)
  }
  
  override func fitToSize() {
    super.fitToSize()
    let labelOffset = SKTexture(imageNamed: "dot").size().height * 0.75
    let yOffset = roundPix(size.height / 6)
  }
    
  func resetFailPageForTestResult(result: TapeTestResult) {
    func inputDescription() -> String {
      if result.input == "" {
        return "The blank sequence\n"
      } else if result.input.length() < 4 {
        return "#" + result.input + " "
      }
      return "#" + result.input + "\n"
    }
    switch result.kind {
    case .Loop: failLabel.text =  inputDescription() + "caused a loop"
    case .Fail:
      if result.correctOutput == nil {
        failLabel.text = inputDescription() + "should be rejected"
      } else if result.correctOutput == "*" {
        failLabel.text = inputDescription() + "should be accepted"
      } else if result.output == nil {
        failLabel.text = inputDescription() + "should not be dropped"
      }
      let tapeIn = result.input == "" ? "blank" : "#" + result.input
      let shouldOut = result.correctOutput == "" ? "blank" : "#" + (result.correctOutput ?? "reject")
      let notOut = result.output == "" ? "blank" : "#" + (result.output ?? "reject")
      failLabel.text = "Input: " + tapeIn + "\nShould: " + shouldOut + "\nNot: " + notOut
    default: return
    }
    if failPage.parent == nil {
      addPageToRight(failPage)
    }
    goToIndexWithoutSnap(2)
  }
}