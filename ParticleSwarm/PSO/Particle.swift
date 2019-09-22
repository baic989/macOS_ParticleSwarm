//
//  Particle.swift
//  ParticleSwarm
//
//  Created by Hrvoje Baic on 22/09/2019.
//  Copyright © 2019 Hrvoje Baic. All rights reserved.
//

import Cocoa

class Particle {

    var current: NSPoint
    var velocity: NSPoint
    var personalBest: NSPoint
    var groupBest: NSPoint
    var representationView: NSView?

    init(current: NSPoint, velocity: NSPoint, groupBest: NSPoint) {
        self.current = current
        self.velocity = velocity
        self.personalBest = self.current
        self.groupBest = groupBest
    }
}
