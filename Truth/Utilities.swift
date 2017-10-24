//
//  Utilities.swift
//  Truth
//
//  Created by David Celentano on 10/9/17.
//  Copyright © 2017 David Celentano. All rights reserved.
//

import Foundation
import UIKit

extension RangeReplaceableCollection where IndexDistance == Int {
    // removes the front of a collection until only n elements remain
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}

extension UILabel {
    
    static func whiteLabel() -> UILabel {
        let l = UILabel()
        l.textColor = UIColor.white
        l.font = UIFont.boldSystemFont(ofSize: 16)
        l.numberOfLines = 0
        return l
    }
}
