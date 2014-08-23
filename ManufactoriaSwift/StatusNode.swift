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
  let ring: Ring
  let tapeNode: TapeNode
  let instructions: String
  let menuButton: Button
  let menuIcon: MenuIcon
  let menuLabel: SKLabelNode
  let nextButton: Button
  let nextIcon: SKSpriteNode
  let nextLabel: SKLabelNode
  
  let failPage: SKNode?
  
  var thinkingAnimationDone = false
  
  init(instructions: String, nextLevelNumber: Int) {
    self.instructions = instructions

    label = BreakingLabel()
    label.fontMedium()
    label.fontColor = Globals.strokeColor
    label.text = instructions

    tapeNode = TapeNode()
    tapeNode.alpha = 0
    
    ring = Ring()
    ring.zPosition = 10
    
    menuIcon = MenuIcon(size: CGSize(14))
    nextIcon = SKSpriteNode("playIcon")
    menuIcon.alpha = 0
    nextIcon.alpha = 0
    menuButton = Button.growButton(imageNamed: "ring")
    nextButton = Button.growButton(imageNamed: "ring")
    menuButton.setScale(0.5)
    nextButton.setScale(0.5)
    menuButton.addChild(menuIcon)
    nextButton.addChild(nextIcon)
    menuLabel = SKLabelNode()
    nextLabel = SKLabelNode()
    menuLabel.alpha = 0
    nextLabel.alpha = 0
    menuLabel.fontMedium()
    nextLabel.fontMedium()
    menuLabel.fontColor = Globals.strokeColor
    nextLabel.fontColor = Globals.strokeColor
    menuLabel.text = "menu"
    nextLabel.text = "next"
    
    page = SKNode()
    page.addChild(label)
    page.addChild(tapeNode)
    page.addChild(ring)
    
    super.init(pages: [page])
    userInteractionEnabled = false
    
    tapeNode.delegate = self
    tapeNode.printer.delegate = ring
    ring.delegate = self
    
    menuButton.touchUpInsideClosure = {[weak self] in self!.scene.view.presentScene(MenuScene(size: self!.scene.size), transition: SKTransition.crossFadeWithDuration(0.5))}
    nextButton.touchUpInsideClosure = {[weak self] in self!.scene.view.presentScene(GameScene(size: self!.scene.size, levelNumber: nextLevelNumber), transition: SKTransition.crossFadeWithDuration(0.5))}
  }
  
  override var size: CGSize {
    didSet{
      label.position = CGPoint(0, round(size.height * (1.0/6.0)))
      tapeNode.position = CGPoint(0, -round(size.height * (1.0/6.0)))
      ring.position = convertPoint(tapeNode.dotPositionForIndex(tapeNode.dots.count), fromNode: tapeNode)
    }
  }
  
  var state: State = .Editing {
    didSet {
      if state == oldValue {return}
      switch state {
      case .Editing:
        changeText(instructions)
        ring.state = .TestButton
        ring.runAction(SKAction.moveTo(tapeNode.position, duration: 0.5).ease())
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        userInteractionEnabled = true
      case .Thinking:
        userInteractionEnabled = false
        ring.state = .Printer
        thinkingAnimationDone = false
        runAction(SKAction.waitForDuration(0.75), completion: {[weak self] in self!.thinkingAnimationDone = true})
        changeText("")
      case .Testing:
        tapeNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
      case .Congratulating:
        tapeNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        menuButton.position = ring.position
        nextButton.position = ring.position
        ring.removeFromParent()
        page.addChild(menuButton)
        page.addChild(nextButton)
        let menuPoint = tapeNode.position + CGPoint(-size.width * (1.0/6.0), 0)
        let nextPoint = tapeNode.position + CGPoint(size.width * (1.0/6.0), 0)
        menuButton.runAction(SKAction.moveTo(menuPoint, duration: 0.5).ease())
        nextButton.runAction(SKAction.moveTo(nextPoint, duration: 0.5).ease())
        menuButton.runAction(SKAction.scaleTo(1, duration: 0.5))
        nextButton.runAction(SKAction.scaleTo(1, duration: 0.5))
        menuIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        nextIcon.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        menuLabel.position = menuPoint + CGPoint(0, -40)
        nextLabel.position = nextPoint + CGPoint(0, -40)
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
  
  func changeText(text: String?, textPosition: CGPoint) {
    var sequence: [SKAction] = []
    if label.alpha != 0 {
      sequence.append(SKAction.fadeAlphaTo(0, duration: 0.5))
    }
    sequence.append(SKAction.runBlock({[weak self] in self!.label.text = text}))
    sequence.append(SKAction.runBlock({[weak self] in self!.label.position = textPosition}))
    if text != nil && text! != "" {
      sequence.append(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    label.runAction(SKAction.sequence(sequence), withKey: "changeText")
  }
  
  func generateFailPageForTestResult(result: TapeTestResult) {
    // TODO: finish this function
    
  }
  
  func testButtonPressed() {
    delegate?.testButtonPressed()
  }
  
  class Ring: Button {
    required init(coder: NSCoder) {fatalError("NSCoding not supported")}
    enum State {case TestButton, Printer}
    
    weak var delegate: StatusNode?
    let ringSprite = SKSpriteNode("ring")
    let printerSprite = SKSpriteNode("printer")
    let playSprite = SKSpriteNode("playIcon")
    let printerSizeRatio: CGFloat
    
    init() {
      printerSizeRatio = printerSprite.size.width / ringSprite.size.width
      printerSprite.setScale(1 / printerSizeRatio)
      printerSprite.alpha = 0
      super.init(texture: nil, color: nil, size: CGSizeZero)
      addChild(ringSprite)
      addChild(printerSprite)
      addChild(playSprite)
      touchUpInsideClosure = {[weak self] in if self!.delegate != nil {self!.delegate!.testButtonPressed()}}
    }
    
    var state: State = .TestButton {
      didSet {
        if state == oldValue {return}
        switch state {
        case .TestButton:
          userInteractionEnabled = true
          runAction(SKAction.scaleTo(1, duration: 0.5).ease())
          ringSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.125))
          printerSprite.runAction(SKAction.fadeAlphaTo(0, duration: 0.125))
          playSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        case .Printer:
          userInteractionEnabled = false
          runAction(SKAction.scaleTo(printerSizeRatio, duration: 0.5).ease())
          ringSprite.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.375),
            SKAction.fadeAlphaTo(0, duration: 0.125)]))
          printerSprite.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.375),
            SKAction.fadeAlphaTo(1, duration: 0.125)]))
          playSprite.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
        }
      }
    }
    
    func printerMoved(printer: SKNode) {
      position = parent.convertPoint(printer.position, fromNode: printer.parent)
    }
    
  }
}