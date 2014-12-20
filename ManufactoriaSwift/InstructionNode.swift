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
    menuButton.shouldStickyOn = true
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
    //let lineHeight = SKTexture(imageNamed: "dot").size().height * 1.5
    switch result.kind {
    case .Demo: break
    case .Pass:
      assertionFailure("StatusNode cannot generate failPage for a test that passes.")
    case .FailLoop:
      if result.input == "" {
        failLabel.text = "The blank sequence\ncaused a loop."
      } else if result.input.length() < 4 {
        failLabel.text = "#" + result.input + " caused a loop."
      } else {
        failLabel.text = "#" + result.input + "\ncaused a loop."
      }
    case .FailShouldAccept:
      if result.input == "" {
        failLabel.text = "The blank sequence\nshould be accepted."
      } else if result.input.length() < 4 {
        failLabel.text = "#" + result.input + " should be accepted."
      } else {
        failLabel.text = "#" + result.input + "\nshould be accepted."
      }
    case .FailShouldReject:
      if result.input == "" {
        failLabel.text = "The blank sequence\nshould be rejected."
      } else if result.input.length() < 4 {
        failLabel.text = "#" + result.input + " should be rejected."
      } else {
        failLabel.text = "#" + result.input + "\nshould be rejected."
      }
    case .FailWrongTransform:
      let tapeIn = result.input == "" ? "blank" : "#" + result.input
      let shouldOut = result.correctOutput == "" ? "blank" : "#" + (result.correctOutput ?? "reject")
      let notOut = result.output == "" ? "blank" : "#" + (result.output ?? "reject")
      failLabel.text = "Input: " + tapeIn + "\nShould: " + shouldOut + "\nNot: " + notOut
    case .FailDroppedTransform:
      if result.input == "" {
        failLabel.text = "The blank sequence\nshould not be dropped."
      } else if result.input.length() < 6 {
        failLabel.text = "#" + result.input + " should not be dropped."
      } else {
        failLabel.text = "#" + result.input + "\nshould not be dropped."
      }
    }
    if failPage.parent == nil {
      addPageToRight(failPage)
    }
    goToIndexWithoutSnap(2)
  }
}