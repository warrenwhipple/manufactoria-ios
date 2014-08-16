//
//  StatusNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 8/2/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class StatusNode: SwipeNode {
  required init(coder: NSCoder) {fatalError("NSCoding not supported")}
  enum State {case Editing, Thinking, Testing, Congratulating}
  
  weak var delegate: GameScene?
  let page: SKNode
  let label: BreakingLabel
  let testButton: TestButton
  let testIcon: SKSpriteNode
  let tapeNode: TapeNode
  let instructions: String
  let menuButton: Button
  let menuIcon: SKSpriteNode
  let menuLabel: SKLabelNode
  let nextButton: Button
  let nextIcon: SKSpriteNode
  let nextLabel: SKLabelNode
  
  
  var thinkingAnimationDone = false
  
  init(instructions: String, nextLevelNumber: Int) {
    self.instructions = instructions

    label = BreakingLabel()
    label.fontSmall()
    label.text = instructions

    tapeNode = TapeNode()
    tapeNode.alpha = 0
    tapeNode.setScale(0.5)
    
    let playTexture = SKTexture("playIcon")
    testIcon = SKSpriteNode(texture: playTexture)
    let ringTexture = SKTexture("ring")
    testButton = TestButton(texture: ringTexture)
    testButton.zPosition = 10
    testButton.addChild(testIcon)
    
    menuIcon = SKSpriteNode("menuIcon")
    nextIcon = SKSpriteNode(texture: playTexture)
    menuIcon.alpha = 0
    nextIcon.alpha = 0
    menuButton = Button.growButton(texture: ringTexture)
    nextButton = Button.growButton(texture: ringTexture)
    menuButton.setScale(0.5)
    nextButton.setScale(0.5)
    menuButton.addChild(menuIcon)
    nextButton.addChild(nextIcon)
    menuLabel = SKLabelNode()
    nextLabel = SKLabelNode()
    menuLabel.alpha = 0
    nextLabel.alpha = 0
    menuLabel.fontSmall()
    nextLabel.fontSmall()
    menuLabel.text = "menu"
    nextLabel.text = "next"
    
    page = SKNode()
    page.addChild(label)
    page.addChild(tapeNode)
    page.addChild(testButton)
    
    super.init(pages: [page])
    userInteractionEnabled = false
    
    tapeNode.delegate = self
    tapeNode.printer.delegate = testButton
    testButton.delegate = self
    
    menuButton.touchUpInsideClosure = {[weak self] in self!.scene.view.presentScene(MenuScene(size: self!.scene.size), transition: SKTransition.crossFadeWithDuration(0.5))}
    nextButton.touchUpInsideClosure = {[weak self] in self!.scene.view.presentScene(GameScene(size: self!.scene.size, levelNumber: nextLevelNumber), transition: SKTransition.crossFadeWithDuration(0.5))}
  }
  
  override var size: CGSize {
    didSet{
      label.position = CGPoint(x: 0, y: size.height * (1.0/6.0))
      tapeNode.position = CGPoint(x: 0, y: -size.height * (1.0/6.0))
      testButton.position = convertPoint(tapeNode.dotPositionForIndex(tapeNode.dots.count), fromNode: tapeNode)
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        changeText(instructions)
        testButton.removeAllActions()
        testButton.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5).ease())
        testButton.runAction(SKAction.scaleTo(1, duration: 0.5).ease())
        testIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        userInteractionEnabled = true
        testButton.userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        testButton.userInteractionEnabled = false
        thinkingAnimationDone = false
        runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
        changeText("")
        testButton.runAction(SKAction.scaleTo(0.5, duration: 0.5).ease())
        testIcon.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
      case .Testing:
        tapeNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      case .Congratulating:
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        menuButton.position = testButton.position
        nextButton.position = testButton.position
        testButton.removeFromParent()
        page.addChild(menuButton)
        page.addChild(nextButton)
        let menuPoint = tapeNode.position + CGPoint(x: -size.width * (1.0/6.0), y: 0)
        let nextPoint = tapeNode.position + CGPoint(x: size.width * (1.0/6.0), y: 0)
        menuButton.runAction(SKAction.moveTo(menuPoint, duration: 0.5).ease())
        nextButton.runAction(SKAction.moveTo(nextPoint, duration: 0.5).ease())
        menuButton.runAction(SKAction.scaleTo(1, duration: 0.5))
        nextButton.runAction(SKAction.scaleTo(1, duration: 0.5))
        menuIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        nextIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        menuLabel.position = menuPoint + CGPoint(x: 0, y: -40)
        nextLabel.position = nextPoint + CGPoint(x: 0, y: -40)
        page.addChild(menuLabel)
        page.addChild(nextLabel)
        let textFadeIn = SKAction.sequence([SKAction.waitForDuration(1), SKAction.fadeAlphaTo(1, duration: 0.5)])
        menuLabel.runAction(textFadeIn)
        nextLabel.runAction(textFadeIn)
      }
    }
  }
  
  func changeText(text: String?) {
    var sequence: [SKAction] = []
    if label.alpha != 0 {
      sequence.append(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
    sequence.append(SKAction.runBlock({[weak self] in self!.label.text = text}))
    if text != nil && text! != "" {
      sequence.append(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    label.runAction(SKAction.sequence(sequence), withKey: "changeText")
  }
  
  func testButtonPressed() {
    delegate?.testButtonPressed()
  }
  
  class TestButton: Button {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    
    weak var delegate: StatusNode?
    
    init(texture: SKTexture) {
      super.init(texture: texture, color: nil, size: texture.size())
      let tempButton = Button.growButton(texture: texture)
      pressAction = tempButton.pressAction
      releaseAction = tempButton.releaseAction
      touchUpInsideClosure = {[weak self] in if self!.delegate != nil {self!.delegate!.testButtonPressed()}}
    }
    
    func printerMoved(printer: SKNode) {
      position = parent.convertPoint(printer.position, fromNode: printer.parent)
    }
    
  }
}