//
//  Double+Extension.swift
//  FacetrackingVideoApp
//
//  Created by Abdul Karim on 04/09/21.
//

import Foundation
import UIKit

extension Double {
    
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    func secondsToString() -> String {
        return formatter.string(from: self) ?? ""
    }
    
//    var heightAdjusted: CGFloat {
//      return CGFloat(self) * AppUtils.heightRatio
//    }
//
//    var widthAdjusted: CGFloat {
//      return CGFloat(self) * AppUtils.widthRatio
//    }
    
}
