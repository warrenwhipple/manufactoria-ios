//
//  ReportNode.swift
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

protocol ReportNodeDelegate: class {
  func reportNodeWasTapped()
}

class ReportNode: SKSpriteNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  weak var delegate: ReportNodeDelegate?
  let label = SmartLabel()

  override init() {
    super.init(texture: nil, color: Globals.highlightColor, size: CGSizeZero)
    userInteractionEnabled = true
    label.fontMedium()
    label.fontColor = Globals.backgroundColor
    addChild(label)
  }
  
  func preparePassMessage() {
    label.text = "The Malevolence Engine\napproves."
  }
  
  func prepareFailMessage() {
    label.text = "The Malevolence Engine\nsees all flaws."
  }
  
  func prepareLoopMessage() {
    label.text = "The Malevolence Engine\nis out of patience."
  }
  
  // MARK: - Touch Functions
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    delegate?.reportNodeWasTapped()
  }
}

