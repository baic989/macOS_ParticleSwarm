//
//  NSPointExtensions.swift
//  ParticleSwarm
//
//  Created by Hrvoje Baic on 22/09/2019.
//  Copyright © 2019 Hrvoje Baic. All rights reserved.
//

import Foundation

extension NSPoint {

    func distance(to point: NSPoint) -> Double {
        let x = self.x - point.x
        let y = self.y - point.y

        return sqrt(Double(pow(x, 2)) + Double(pow(y, 2)))
    }
}
