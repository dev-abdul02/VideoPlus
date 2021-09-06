//
//  BaseNavigation.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import Foundation
import UIKit

protocol NavigationControllerChild {
    func prefersNavigationBarHidden() -> Bool
}

class BaseNavigationController: UINavigationController {

    override var viewControllers: [UIViewController] {
        didSet {
            if let viewController = topViewController {
                self.checkNavigationBarPreferenceForViewController(viewController, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    private func checkNavigationBarPreferenceForViewController(_ viewController: UIViewController?, animated: Bool) {
        let hideNavigationBar: Bool
        if let child = viewController as? NavigationControllerChild {
            hideNavigationBar = child.prefersNavigationBarHidden()
        } else {
            hideNavigationBar = false
        }

        if isNavigationBarHidden != hideNavigationBar {
            setNavigationBarHidden(hideNavigationBar, animated: animated)
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        checkNavigationBarPreferenceForViewController(viewController, animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        checkNavigationBarPreferenceForViewController(topViewController, animated: animated)
        return poppedViewController
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToViewController(viewController, animated: animated)
        checkNavigationBarPreferenceForViewController(topViewController, animated: animated)
        return poppedViewControllers
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToRootViewController(animated: animated)
        checkNavigationBarPreferenceForViewController(topViewController, animated: animated)
        return poppedViewControllers
    }

    
}

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
