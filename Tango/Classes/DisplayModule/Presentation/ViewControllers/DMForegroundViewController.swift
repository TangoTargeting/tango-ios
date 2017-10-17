//
//  DMForegroundModalViewController.swift
//  Tango
//
//  Created by Raul Hahn on 12/19/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

class DMForegroundViewController: UIViewController, ForegroundViewButtonActionDelegate {
    var eventsHandler: EventsHandler
    var content:DMDisplayContent
    var displayView: DMForegroundViewRenderer
    
    init(content: DMDisplayContent, eventsHandler: EventsHandler) {
        self.content = content
        self.eventsHandler = eventsHandler
        self.displayView = DMForegroundViewRenderer(content: content)
        super.init(nibName: nil, bundle: nil)
        self.displayView.buttonActionDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.eventsHandler.addEvent(event: Event(type: .display))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func presentModalViewController() {
        if let superView = self.view {
            superView.addSubviewAligned(displayView.viewToDisplay())
            self.modalPresentationStyle = .overCurrentContext
            self.modalTransitionStyle = .crossDissolve
            if (UIApplication.topViewController() as? DMForegroundViewController) == nil {
                UIApplication.topViewController()?.present(self, animated: true, completion: nil)
            } else {
                return
            }
        }
    }
    
    func dismissModalViewController() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func performButtonAction(actionString: String?) {
        eventsHandler.addEvent(event: Event(type: .click))
        if let actionString = actionString {
            if let actionUrl = URL(string:(actionString)) {
                if UIApplication.shared.canOpenURL(actionUrl) {
                    openUrl(url: actionUrl)
                } else {
                    dLogInfo(message: "UIApplication cannot open url: \(actionUrl)")
                }
            } else {
                dLogInfo(message: "URL for action is invalid: \(actionString)")
            }
        } else {
            dLogInfo(message: "URL for action is nil")
        }
        dismissModalViewController()
    }
    
    // MARK: ForegroundViewButtonActionDelegate
    
    func closeButtonAction(sender: UIButton) {
        eventsHandler.addEvent(event: Event(type: .close))
        dismissModalViewController()
    }
    
    func firstButtonAction(sender: UIButton) {
        performButtonAction(actionString: content.primaryButtonAction.buttonAction)
    }
    
    func secondButtonAction(sender: UIButton) {
        performButtonAction(actionString: content.secondaryButtonAction?.buttonAction)
    }
}
