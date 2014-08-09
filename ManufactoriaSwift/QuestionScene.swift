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
    questionLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
    questionLabel.text = questionText
    questionLabel.position = CGPoint(x: midX, y: midY + questionLabel.lineHeight * questionLabel.fontSize)
    
    let yesLabel = BreakingLabel()
    yesLabel.text = yesText
    
    let noLabel = BreakingLabel()
    noLabel.text = noText
    
    let yesButton = Button(size: CGSize(width: 80, height: 80))
    yesButton.closureTouchUpInside = yesClosure
    yesButton.position = CGPoint(x: midX - 70, y: midY - 40)
    yesButton.addChild(yesLabel)
    
    let noButton = Button(size: CGSize(width: 80, height: 80))
    noButton.closureTouchUpInside = noClosure
    noButton.position = CGPoint(x: midX + 70, y: midY - 40)
    noButton.addChild(noLabel)
    
    super.init(size: size)
    backgroundColor = UIColor.blackColor()
        
    addChild(questionLabel)
    addChild(yesButton)
    addChild(noButton)
  }
}
