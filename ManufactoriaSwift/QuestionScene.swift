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
  
  init(questionText: String, yesText: String, noText: String, yesClosure: (()->()), noClosure: (()->()), size: CGSize) {
    let midX = size.width * 0.5
    let midY = size.height * 0.5
    
    let questionLabel = BreakingLabel()
    questionLabel.fontMedium()
    questionLabel.fontColor = Globals.strokeColor
    questionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
    questionLabel.text = questionText
    questionLabel.position = CGPoint(midX, midY + questionLabel.lineHeight * questionLabel.fontSize)
    
    let yesLabel = BreakingLabel()
    yesLabel.fontMedium()
    yesLabel.fontColor = Globals.strokeColor
    yesLabel.text = yesText
    
    let noLabel = BreakingLabel()
    noLabel.fontMedium()
    noLabel.fontColor = Globals.strokeColor
    noLabel.text = noText
        
    let yesButton = Button(size: CGSize(80))
    yesButton.touchUpInsideClosure = yesClosure
    yesButton.position = CGPoint(midX - 70, midY - 40)
    yesButton.addChild(yesLabel)
    
    let noButton = Button(size: CGSize(80))
    noButton.touchUpInsideClosure = noClosure
    noButton.position = CGPoint(midX + 70, midY - 40)
    noButton.addChild(noLabel)
    
    super.init(size: size)
    backgroundColor = Globals.backgroundColor
        
    addChild(questionLabel)
    addChild(yesButton)
    addChild(noButton)
  }
}
