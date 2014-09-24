//
//  QuestionScene
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class QuestionScene: ManufactoriaScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let questionLabel = BreakingLabel()
  let yesLabel = BreakingLabel()
  let noLabel = BreakingLabel()
  let yesButton = Button()
  let noButton = Button()

  override init(size: CGSize) {
    
    questionLabel.fontMedium()
    questionLabel.fontColor = Globals.strokeColor
    questionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
    
    yesLabel.fontMedium()
    yesLabel.fontColor = Globals.strokeColor
    
    noLabel.fontMedium()
    noLabel.fontColor = Globals.strokeColor
    
    yesButton.size = CGSize(100)
    yesButton.addChild(yesLabel)
    
    noButton.size = CGSize(100)
    noButton.addChild(noLabel)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
        
    addChild(questionLabel)
    addChild(yesButton)
    addChild(noButton)
    
    fitToSize()
  }
  
  override var size: CGSize {didSet{if size != oldValue {fitToSize()}}}
  
  func fitToSize() {
    let midX = size.width * 0.5
    let midY = size.height * 0.5
    questionLabel.position = CGPoint(midX, midY + questionLabel.lineHeight * questionLabel.fontSize)
    yesButton.position = CGPoint(midX - 70, midY - 40)
    noButton.position = CGPoint(midX + 70, midY - 40)
  }
}

class ResetScene: QuestionScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  override init(size: CGSize) {
    super.init(size: size)
    questionLabel.text = "Are you sure you want to\nerase all progress?"
    yesLabel.text = "reset"
    noLabel.text = "cancel"
    yesButton.touchUpInsideClosure = {
      [unowned self] in
      GameData.sharedInstance.resetAllGameData()
      LevelData.resetDataForAllLevels()
      self.transitionToTitleScene()
    }
    noButton.touchUpInsideClosure = {
      self.transitionToMenuScene()
    }
  }
}

class UnlockScene: QuestionScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  override init(size: CGSize) {
    super.init(size: size)
    questionLabel.text = "Are you sure you want to\nunlock all levels?"
    yesLabel.text = "unlock"
    noLabel.text = "cancel"
    yesButton.touchUpInsideClosure = {
      [unowned self] in
      GameData.sharedInstance.levelsComplete = LevelLibrary.count
      GameData.sharedInstance.save()
      self.transitionToMenuScene()
    }
    noButton.touchUpInsideClosure = {
      self.transitionToMenuScene()
    }
  }
}
