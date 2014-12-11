//
//  QuestionScene
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class ResetScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let question = SmartLabel()
  let yesButton = Button(text: "reset", fixedWidth: Globals.touchSpan * 1.5)
  let noButton = Button(text: "cancel", fixedWidth: Globals.touchSpan * 1.5)
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    question.text = "Are you sure you want to\nerase all progress?"
    question.fontMedium()
    question.fontColor = Globals.strokeColor
    yesButton.touchUpInsideClosure = {
      [unowned self] in
      GameProgressData.sharedInstance.resetAllGameProgressData()
      LevelData.resetDataForAllLevels()
      self.transitionToTitleScene()
    }
    noButton.touchUpInsideClosure = {
      self.transitionToMenuScene()
    }
    addChild(question)
    addChild(yesButton)
    addChild(noButton)
    fitToSize()
  }
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  func fitToSize() {
    let midX = size.width * 0.5
    let midY = size.height * 0.5
    question.position = CGPoint(midX, midY + question.lineHeight * question.fontSize)
    yesButton.position = CGPoint(midX - 70, midY - 40)
    noButton.position = CGPoint(midX + 70, midY - 40)
  }
}

class UnlockScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let question = SmartLabel()
  let yesButton = Button(text: "unlock", fixedWidth: Globals.touchSpan * 1.5)
  let noButton = Button(text: "cancel", fixedWidth: Globals.touchSpan * 1.5)
  override init(size: CGSize) {
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
    question.text = "Are you sure you want to\nunlock all levels?"
    question.fontMedium()
    question.fontColor = Globals.strokeColor
    yesButton.touchUpInsideClosure = {
      [unowned self] in
      GameProgressData.sharedInstance.unlockAllLevels()
      self.transitionToMenuScene()
    }
    noButton.touchUpInsideClosure = {
      self.transitionToMenuScene()
    }
    addChild(question)
    addChild(yesButton)
    addChild(noButton)
    fitToSize()
  }
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  func fitToSize() {
    let midX = size.width * 0.5
    let midY = size.height * 0.5
    question.position = CGPoint(midX, midY + question.lineHeight * question.fontSize)
    yesButton.position = CGPoint(midX - 70, midY - 40)
    noButton.position = CGPoint(midX + 70, midY - 40)
  }
}