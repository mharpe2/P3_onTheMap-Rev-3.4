//
//  BorderedButton.swift
//  P3_onTheMap
//
//  Created by Michael Harper on 7/21/15.
//  Copyright (c) 2015 hxx. All rights reserved.
//
import UIKit

let borderedButtonHeight : CGFloat = 44.0
let borderedButtonCornerRadius : CGFloat = 4.0
let padBorderedButtonExtraPadding : CGFloat = 20.0
let phoneBorderedButtonExtraPadding : CGFloat = 14.0

class BorderedButton: UIButton {
    
    // MARK: - Properties
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    // MARK: - Setters
    
    fileprivate func setBackingColor(_ backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    fileprivate func setHighlightedBackingColor(_ highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: - Tracking
    
    override func beginTracking(_ touch: UITouch, with withEvent: UIEvent?) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with withEvent: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    override func cancelTracking(with event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        let extraButtonPadding : CGFloat = 14.0
        var sizeThatFits = CGSize.zero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = 44.0
        return sizeThatFits
        
    }
}
