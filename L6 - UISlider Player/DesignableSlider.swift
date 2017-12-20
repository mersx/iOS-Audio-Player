//
//  DesignableSlider.swift
//  L6 - UISlider Player
//
//  Created by Alexander Martynov on 12/12/17.
//  Copyright © 2017 Alexander Martynov. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableSlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }

}
