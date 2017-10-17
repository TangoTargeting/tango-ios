//
//  DMTANButton.swift
//  Tango
//
//  Created by Raul Hahn on 1/13/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

class TANCloseButton: UIButton {
    init() {
        super.init(frame: .zero)
        
        setBackgroundImage(UIImage(named: "close.png", in:  Bundle(for: Tango.self), compatibleWith: nil), for: .normal)
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let minimumHitArea = CGSize(width: 50, height: 50)
        //if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}
