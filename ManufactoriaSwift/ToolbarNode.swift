//
//  ToolbarNode.swift
//  ManufactoriaSwift
//
//  Created by Warren Whipple on 6/26/14.
//  Copyright (c) 2014 Warren Whipple. All rights reserved.
//

import SpriteKit

protocol ToolbarNodeDelegate {
    func changeEditMode(editMode: EditMode)
}

class ToolbarNode: SKNode, ToolbarButtonDelegate {
    var delegate: ToolbarNodeDelegate? {
    didSet {
        if delegate && buttons.count >= 2 {
            buttons[1].activate()
        }
    }
    }
    let buttons: ToolbarButton[]
    var rect: CGRect {didSet {fitToRect()}}
    
    init(rect: CGRect) {
        self.rect = rect
        var tempButtons: ToolbarButton[] = []
        tempButtons += ToolbarButton(editModes: [EditMode.Blank])
        tempButtons += ToolbarButton(editModes: [EditMode.Belt, EditMode.Bridge])
        tempButtons += ToolbarButton(editModes: [EditMode.PusherB])
        tempButtons += ToolbarButton(editModes: [EditMode.PusherR])
        tempButtons += ToolbarButton(editModes: [EditMode.PusherG])
        tempButtons += ToolbarButton(editModes: [EditMode.PusherY])
        tempButtons += ToolbarButton(editModes: [EditMode.PullerBR, EditMode.PullerRB])
        tempButtons += ToolbarButton(editModes: [EditMode.PullerGY, EditMode.PullerYG])
        buttons = tempButtons
        super.init()
        for button in buttons {
            button.delegate = self
            self.addChild(button)
        }
        fitToRect()
    }
    
    func fitToRect() {
        if buttons.count == 0 {return}
        let buttonSize = min(rect.size.height, rect.size.width / CGFloat(buttons.count))
        var xShift = (rect.size.width - buttonSize * CGFloat(buttons.count - 1)) / 2.0
        let yShift = rect.size.height / 2.0
        for button in buttons {
            button.setScale(buttonSize)
            button.position = CGPoint(x: xShift, y: yShift)
            xShift += buttonSize
        }
    }
    
    func changeEditMode(editMode: EditMode, fromButton: ToolbarButton) {
        for button in buttons {
            if button != fromButton {
                button.isFocused = false
            }
        }
        if delegate {
            delegate!.changeEditMode(editMode)
        }
    }
    
}