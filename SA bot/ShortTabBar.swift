//
//  ShortTabBar.swift
//  Spontivity
//
//  Created by Kyle Bashour on 3/31/15.
//  Copyright (c) 2015 Spontivity. All rights reserved.
//

import UIKit

class ShortTabBar: UITabBar {

    override func sizeThatFits(size: CGSize) -> CGSize {
        super.sizeThatFits(size)

        var sizeThatFits = super.sizeThatFits(size)
        //sizeThatFits.height = 45

        return sizeThatFits
    }
}