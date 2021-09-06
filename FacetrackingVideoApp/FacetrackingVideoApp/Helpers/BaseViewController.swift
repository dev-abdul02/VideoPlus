//
//  BaseViewController.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
    }
    
    var hideStatusBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Overriding methods
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, presentationStyle: UIModalPresentationStyle, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = presentationStyle
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
