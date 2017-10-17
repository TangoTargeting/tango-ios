//
//  DMViewRenderer.swift
//  Tango
//
//  Created by Raul Hahn on 12/7/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

let kTitleLabelFontSize: CGFloat = 19.0
let kSubtitleLabelFontSize: CGFloat = 15.0
let kButtonTileLabelFontSize: CGFloat = 14.0

class AlertLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsetsMake(0, 16, 0, 16)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

class ShadowView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 5.0)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
        layer.shadowPath = shadowPath.cgPath
    }
}
