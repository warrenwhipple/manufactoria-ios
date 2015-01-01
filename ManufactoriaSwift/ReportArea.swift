//
//  ReportArea.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 12/8/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

/*
var PassCommentCounter = 0
var FailCommentCounter = 0
var LoopCommentCounter = 0
let PassComments = ["sees no flaw!", "approves!", "is pleased!", "finds this acceptable!", "is pleasantly surprised!"]
let FailComments = ["sees all flaws!", "is not happy!", "finds this disturbing!", "is displeased by failure!", "expects better than this!", "is not amused!", "is unimpressed!"]
let LoopComments = ["is out of patience!", "does not like waiting!", "is DIV BY ZERO OVERFLOW", "is getting bored!", "has fallen asleep!"]
*/

protocol ReportAreaDelegate: class {
  func reportAreaWasTapped()
}

class ReportArea: Area {
  weak var delegate: ReportAreaDelegate?
  let backgroundSprite = SKSpriteNode(color: Globals.highlightColor, size: CGSizeZero)
  let label = SmartLabel()

  override init() {
    super.init()
    userInteractionEnabled = true
    label.fontMedium()
    label.fontColor = Globals.backgroundColor
    backgroundSprite.addChild(label)
    addChild(backgroundSprite)
  }
  
  override func fitToSize() {
    backgroundSprite.size = size
  }
  
  func preparePassMessage() {
    label.text = "The Malevolence Engine\n\nAPPROVES"
  }
  
  func prepareFailMessage() {
    label.text = "The Malevolence Engine\n\nSEES ALL FLAWS"
  }
  
  func prepareLoopMessage() {
    label.text = "The Malevolence Engine\n\nIS OUT OF PATIENCE"
  }
  
  // MARK: - Touch Functions
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    delegate?.reportAreaWasTapped()
  }
}

