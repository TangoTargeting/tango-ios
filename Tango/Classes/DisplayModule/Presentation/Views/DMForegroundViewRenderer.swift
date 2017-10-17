//
//  DMForegroundViewRenderer.swift
//  Tango
//
//  Created by Raul Hahn on 12/7/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

let kAlertViewSeparatorColor: UIColor = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 229.0/255.0, alpha: 1)

@objc
protocol ForegroundViewButtonActionDelegate {
    func closeButtonAction(sender: UIButton)
    func firstButtonAction(sender: UIButton)
    func secondButtonAction(sender: UIButton)
}

class DMForegroundViewRenderer {
    private var content: DMDisplayContent
    private let alertWidth: CGFloat = 300
    weak var buttonActionDelegate: ForegroundViewButtonActionDelegate?
    
    init(content: DMDisplayContent, delegate: ForegroundViewButtonActionDelegate) {
        self.content = content
        self.buttonActionDelegate = delegate
    }
    
    init(content: DMDisplayContent) {
        self.content = content
    }
    
    func viewToDisplay() -> UIView {
        let backgroundView = self.backgroundView()
        let alertView = self.alertView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(alertView)
        alertView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        alertView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        
        return backgroundView
    }
    
    private func backgroundView() -> UIView {
        let backgroundSize = UIApplication.shared.keyWindow?.bounds ??
            CGRect(x: 0, y: 0, width: UIScreen.main.nativeBounds.size.width / 2, height: UIScreen.main.nativeBounds.size.height / 2)
        let backgroungView = UIView(frame: backgroundSize)
        backgroungView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        return backgroungView
    }
    
    private func alertView() -> UIView {
        let roundedCornerView = UIView()
        roundedCornerView.backgroundColor = UIColor.clear
        roundedCornerView.layer.cornerRadius = 10.0
        roundedCornerView.clipsToBounds = true
        
        //Stack View
        let stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.distribution = UIStackViewDistribution.equalSpacing
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = 0
        if let imageUrl = content.imageUrl {
            
            // Image view
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.white
            imageView.widthAnchor.constraint(equalToConstant: alertWidth).isActive = true
            if let imageHeight = content.imageSize?.height {
                imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
            }
            if let contentImage = content.image {
                imageView.image = contentImage
                imageView.contentMode = .scaleAspectFill
            } else {
                imageView.downloadedFrom(url: URL(string: imageUrl)!)
            }
            stackView.addArrangedSubview(imageView)
        }
        
        // Text Container
        stackView.addArrangedSubview(self.textContainer())
        
        // Action Button
        stackView.addArrangedSubview(self.buttonsContainer())
        
        roundedCornerView.addSubviewAligned(stackView)
        
        let containerView = ShadowView()
        containerView.addSubviewAligned(roundedCornerView)
        addCloseButtonToView(view: containerView)
        
        return containerView

    }
    
    private func textContainer() -> UIView {
        var stackViewLabels: [UILabel] = [alertLabelWith(labelContent: content.titleLabel,
                                                       fontSize: kTitleLabelFontSize)]
        if let textLabel = content.textLabel {
            stackViewLabels.append(alertLabelWith(labelContent: textLabel,
                                                  fontSize: kSubtitleLabelFontSize))
        }
        let stackViewDetail = StackViewDetail(verticalStackView: stackViewLabels,
                                              padding: UIEdgeInsetsMake(16, 0, 16, 0),
                                              backgroundColor: UIColor.white,
                                              itemSpacing: 16)
        
        return createVerticalStackView(stackViewDetail: stackViewDetail)
    }
    
    private func buttonsContainer() -> UIView {
        let padding = UIEdgeInsetsMake(1, 0, 0, 0)
        let stackViewDetails = StackViewDetail(verticalStackView:buttonsFromButtonsContent(),
                                               padding: padding,
                                               backgroundColor: kAlertViewSeparatorColor,
                                               itemSpacing: 1.0)
        let buttonsContainer = createVerticalStackView(stackViewDetail: stackViewDetails)
        
        return buttonsContainer
    }
    
    private func createVerticalStackView(stackViewDetail: StackViewDetail) -> UIView {
        let stackView = UIStackView()
        stackView.axis = stackViewDetail.axisConstraints
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = stackViewDetail.itemSpacing
        stackView.distribution = UIStackViewDistribution.equalSpacing
        
        let containerView = UIView()
        containerView.backgroundColor = stackViewDetail.backgroundColor
        
        for (_,value) in stackViewDetail.views.enumerated() {
            stackView.addArrangedSubview(value)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        containerView.addSubview(stackView)
        
        //Constraints
        let viewsDictionary = ["stackView":stackView]
        let padding = stackViewDetail.stackViewPadding
        let stackViewVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(padding.top)-[stackView]-\(padding.bottom)-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        containerView.widthAnchor.constraint(equalToConstant: alertWidth).isActive = true
        stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.addConstraints(stackViewVerticalConstraints)
        
        return containerView
    }
    
    private func alertLabelWith(labelContent: DMLabelContent, fontSize: CGFloat) -> UILabel {
        let label = AlertLabel()
        label.backgroundColor = UIColor.white.withAlphaComponent(1)
        label.widthAnchor.constraint(equalToConstant: alertWidth).isActive =  true
        label.font = UIFont(name: label.font.fontName, size: fontSize)
        label.textColor = labelContent.textColor
        label.text = labelContent.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }
    
    private func actionButtonWith(buttonContent: DMActionButtonContent) -> UIButton {
        let buttonHeight: CGFloat = 50
        let actionButton = UIButton(type: .custom)
        actionButton.backgroundColor = buttonContent.buttonBackgroundColor
        actionButton.widthAnchor.constraint(equalToConstant: alertWidth).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        if let buttonTitleLablel = actionButton.titleLabel {
            actionButton.titleLabel?.font = UIFont(name: buttonTitleLablel.font.fontName, size: kButtonTileLabelFontSize)
        }
        actionButton.setTitle(buttonContent.buttonTitle.text,for: .normal)
        actionButton.setTitleColor(buttonContent.buttonTitle.textColor,
                                   for: .normal)
        actionButton.setTitleColor(buttonContent.buttonTitle.textColor.withAlphaComponent(0.7),
                                   for: .highlighted)
        
        return actionButton
    }
    
    private func buttonsFromButtonsContent() -> [UIButton] {
        var buttons: [UIButton] = []
        let contentActionButtons: [DMActionButtonContent?] = [content.primaryButtonAction, content.secondaryButtonAction]
        for (index , value) in contentActionButtons.enumerated() {
            if let buttonContent = value {
                let actionButon = actionButtonWith(buttonContent: buttonContent)
                setupButtonTarget(button: actionButon, index: index)
                buttons.append(actionButon)
            }
        }
        
        return buttons
    }
    
    private func setupButtonTarget(button: UIButton, index: Int) {
        switch index {
        case 0:
            button.addTarget(self, action: #selector(firstButtonAction(sender:)), for: .touchUpInside)
            break
        case 1:
            button.addTarget(self, action: #selector(secondButtonAction(sender:)), for: .touchUpInside)
            break
        default: break
        }
    }
    
    private func addCloseButtonToView(view: UIView) {
        let closeButton = TANCloseButton()
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        
        let margins = view.layoutMarginsGuide
        closeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        closeButton.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
    }
    
    @objc private func closeButtonAction(sender: UIButton) {
        self.buttonActionDelegate?.closeButtonAction(sender: sender)
    }
    
    @objc private func firstButtonAction(sender: UIButton) {
        self.buttonActionDelegate?.firstButtonAction(sender: sender)
    }
    
    @objc private func secondButtonAction(sender: UIButton) {
        self.buttonActionDelegate?.secondButtonAction(sender: sender)
    }
}

struct StackViewDetail {
    var stackViewPadding: UIEdgeInsets // horrizontal padding is not supported for now
    var views: [UIView]
    var backgroundColor: UIColor
    var itemSpacing: CGFloat
    var axisConstraints: UILayoutConstraintAxis
    
    init(views: [UIView],
         padding: UIEdgeInsets,
         backgroundColor: UIColor,
         itemSpacing: CGFloat,
         axisConstraints: UILayoutConstraintAxis) {
        self.views = views
        self.stackViewPadding = padding
        self.backgroundColor = backgroundColor
        self.itemSpacing = itemSpacing
        self.axisConstraints = axisConstraints
    }
    
    init(verticalStackView views: [UIView],
         padding: UIEdgeInsets,
         backgroundColor: UIColor,
         itemSpacing: CGFloat) {
        self.views = views
        self.stackViewPadding = padding
        self.backgroundColor = backgroundColor
        self.itemSpacing = itemSpacing
        self.axisConstraints = .vertical
    }
    
    init(verticalStackView views: [UIView], backgroundColor: UIColor, itemSpacing: CGFloat) {
        self.views = views
        self.stackViewPadding = UIEdgeInsets()
        self.backgroundColor = backgroundColor
        self.itemSpacing = itemSpacing
        self.axisConstraints = .vertical
    }
}
