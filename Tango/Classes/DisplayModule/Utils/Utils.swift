//
//  Utils.swift
//  Tango
//
//  Created by Raul Hahn on 12/6/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

class ContentUtils {
    class func canOpenUrl(urlString: String?) -> Bool {
        if urlString != nil {
            if let url = URL(string: urlString!) {
                if UIApplication.shared.canOpenURL(url) {
                    return true
                }
            }
        }
        dLogError(message: "\(String(describing: urlString)) is not valid !")
        
        return false
    }
}

extension UIView {
    func addSubviewAligned(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage.gif(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

func data(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}

func isAppInBackground() -> Bool {
    return UIApplication.shared.applicationState == .background
}

func isAppInForeground() -> Bool {
    return UIApplication.shared.applicationState == .active
}

func getAppIcon() -> UIImage? {
    if let infoDictionary = Bundle.main.infoDictionary {
        if let iconsDictionary = infoDictionary["CFBundleIcons"] as? NSDictionary {
            if let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? NSDictionary {
                if let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? NSArray {
                    if let lastIcon = iconFiles.lastObject as? String {
                        return UIImage(named: lastIcon)
                    }
                }
            }
        }
    }
    
    return nil
}
