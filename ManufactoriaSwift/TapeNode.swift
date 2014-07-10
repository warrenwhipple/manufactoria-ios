//
//  TapeNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 7/9/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

class TapeNode: SKNode, TapeDelegate {
    var rect: CGRect = CGRectZero {didSet{fitToRect()}}
    var dots: [SKSpriteNode] = []
    var maxLength: Int = 0
    let dotTexture = SKTexture(imageNamed: "dot.png")
    let dotSpacing: CGFloat
    let printer = SKSpriteNode(imageNamed: "printer.png")
    
    init() {
        dotSpacing = dotTexture.size().width * 1.5
        super.init()
        printer.zPosition = 1
        addChild(printer)
    }
    
    func fitToRect() {
        if rect == CGRectZero {return}
        position = CGPoint(x: dotSpacing * 2.0, y: rect.origin.y + rect.size.height * 0.5)
    }
    
    func loadTape(tape: Tape, maxLength: Int) {
        self.maxLength = maxLength
        
        // remove old dots
        for dot in dots {dot.removeFromParent()}
        dots = []
        
        // add new dots
        var i = 0
        for character in tape.string {
            let dot = SKSpriteNode(texture: dotTexture)
            switch character {
            case "b": dot.color = ColorBlue
            case "r": dot.color = ColorRed
            case "g": dot.color = ColorGreen
            case "y": dot.color = ColorYellow
            default: break
            }
            dot.colorBlendFactor = 1
            dot.position = dotPositionForIndex(i++)
            addChild(dot)
            dots += dot
        }
        
        // reset printer
        printer.position = dotPositionForIndex(i)
        
        fitToRect()
    }
    
    func writeColor(color: Color) {
        
        // add dot
        let dot = SKSpriteNode(texture: dotTexture)
        dots += dot
        switch color {
        case .Blue: dot.color = ColorBlue
        case .Red: dot.color = ColorRed
        case .Green: dot.color = ColorGreen
        case .Yellow: dot.color = ColorYellow
        }
        dot.alpha = 0
        let dotIndex = dots.count - 1
        dot.position = dotPositionForIndex(dotIndex)
        dot.runAction(SKAction.sequence([
            SKAction.fadeInWithDuration(0.25),
            SKAction.colorizeWithColorBlendFactor(1, duration: 0.25)]))
        addChild(dot)
        
        // animate printer
        printer.removeAllActions()
        printer.position = dotPositionForIndex(dotIndex)
        let movePrinter = SKAction.moveTo(dotPositionForIndex(dotIndex + 1), duration: 0.5)
        movePrinter.timingMode = .EaseInEaseOut
        printer.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), movePrinter]))
    }
    
    func deleteColor() {
        if dots.count == 0 {return}
        
        // animate deleting dot
        let deleteDot = SKAction.moveByX(-dotSpacing, y: 0, duration: 1)
        deleteDot.timingMode = .EaseInEaseOut
        dots[0].runAction(SKAction.sequence([
            SKAction.group([deleteDot, SKAction.fadeOutWithDuration(1)]),
            SKAction.removeFromParent()]))
        dots.removeAtIndex(0)
        
        // move remaining dots
        var i = 0
        for dot in dots {
            let moveDot = SKAction.moveTo(dotPositionForIndex(i++), duration: 1)
            moveDot.timingMode = .EaseInEaseOut
            dot.runAction(moveDot)
        }
        
        // move printer
        let movePrinter = SKAction.moveTo(dotPositionForIndex(i), duration: 1)
        movePrinter.timingMode = .EaseInEaseOut
        printer.runAction(movePrinter)
    }
    
    func dotPositionForIndex(index: Int) -> CGPoint {
        return CGPoint(x: CGFloat(index) * dotSpacing, y: 0)
    }
}