//
//  QuestionScene
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/27/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class QuestionScene: SKScene {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  let questionLabel = BreakingLabel()
  let yesButton = Button(texture: nil, color: nil, size: CGSize(80))
  let noButton = Button(texture: nil, color: nil, size: CGSize(80))

  init(questionText: String, yesText: String, noText: String, yesClosure: (()->()), noClosure: (()->()), size: CGSize) {
    
    questionLabel.fontMedium()
    questionLabel.fontColor = Globals.strokeColor
    questionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
    questionLabel.text = questionText
    
    let yesLabel = BreakingLabel()
    yesLabel.fontMedium()
    yesLabel.fontColor = Globals.strokeColor
    yesLabel.text = yesText
    
    let noLabel = BreakingLabel()
    noLabel.fontMedium()
    noLabel.fontColor = Globals.strokeColor
    noLabel.text = noText
        
    yesButton.touchUpInsideClosure = yesClosure
    yesButton.addChild(yesLabel)
    
    noButton.touchUpInsideClosure = noClosure
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
