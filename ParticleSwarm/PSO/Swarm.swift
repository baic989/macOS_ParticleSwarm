//
//  Swarm.swift
//  ParticleSwarm
//
//  Created by Hrvoje Baic on 22/09/2019.
//  Copyright © 2019 Hrvoje Baic. All rights reserved.
//

import Foundation

class Swarm {

    let c: CGFloat
    let vMax: CGFloat
    let unitSize: NSSize
    let maxError: Int
    var population: [Particle] = []

    init(c: CGFloat, vMax: CGFloat, unitSize: NSSize, swarmSize: Int, swarmBounds: NSRect, maxError: Int) {
        self.c = c
        self.vMax = vMax
        self.unitSize = unitSize
        self.maxError = maxError
        self.population = self.generateParticles(count: swarmSize, bounds: swarmBounds)
    }

    /// Calculates particle position based on current values
    func newPosition(particle: Particle) -> NSPoint {
        let x = particle.current.x + particle.velocity.x
        let y = particle.current.y + particle.velocity.y

        return NSPoint(x: x, y: y)
    }

    /// Returns a new velocity based on current particles and group values
    func newVelocity(particle: Particle) -> NSPoint {

        // Velocity calculated by:
        // v[] = v[] + c1 * rand() * (pbest[] - present[]) + c2 * rand() * (gbest[] - present[])
        // from: http://www.swarmintelligence.org/tutorials.php
        var x = particle.velocity.x + c
            * CGFloat.random(in: 0...1)
            * (particle.personalBest.x - particle.current.x) + c
            * CGFloat.random(in: 0...1)
            * (particle.groupBest.x - particle.current.x)

        var y = particle.velocity.y + c
            * CGFloat.random(in: 0...1)
            * (particle.personalBest.y - particle.current.y) + c
            * CGFloat.random(in: 0...1)
            * (particle.groupBest.y - particle.current.y)

        // Check if maximum velocity was exceeded
        if x > 0 && x > vMax {
            x = vMax
        } else if x < 0 && abs(x) > vMax {
            x = -vMax
        }

        if y > vMax {
            y = vMax
        } else if y < 0 && abs(y) > vMax {
            y = -vMax
        }

        return NSPoint(x: x, y: y)
    }

    /// Genertes random x, y values for particle location
    private func generateParticleLocation(in bounds: CGRect) -> NSPoint {
        let minX = bounds.minX + unitSize.width / 2
        let maxX = bounds.maxX - unitSize.width / 2
        let minY = bounds.minY + unitSize.height / 2
        let maxY = bounds.maxY - unitSize.height / 2
        let x = CGFloat.random(in: minX...maxX)
        let y = CGFloat.random(in: minY...maxY)

        return NSPoint(x: x, y: y)
    }

    private func generateParticles(count: Int, bounds: NSRect) -> [Particle] {
        var particles: [Particle] = []
        for _ in 0..<count {

            let startingLocation = generateParticleLocation(in: bounds)
            let particle = Particle(current: startingLocation,
                                    velocity: NSPoint.zero,
                                    groupBest: NSPoint.zero)

            particles.append(particle)
        }

        return particles
    }

    private func evaluation(personal: NSPoint, target: NSPoint) -> NSPoint {
        let x = personal.x + 10
        let y = personal.y + 10

        return NSPoint(x: x, y: y)
    }

    func swarmTo(location: NSPoint, progress: @escaping (Double) -> Void) {

        var groupBest: NSPoint = .zero

        var errors: [Double] = []
        var averageError: Double = Double.infinity

        if !population.isEmpty {

            DispatchQueue.global(qos: .default).async { [weak self] in

                guard let self = self else { return }

                while averageError > Double(self.maxError) {

                    errors = []

                    // Get values
                    for particle in self.population {

                        // Calculate new value for the particle
                        let solution = self.evaluation(personal: particle.current, target: location)

                        // If the new value is better than the personal best of the particle, set it as new personal best
                        if solution.distance(to: location) < particle.personalBest.distance(to: location) {
                            particle.personalBest = solution
                        }

                        // If the new value is better than the group best, set it as new group best
                        if solution.distance(to: location) < groupBest.distance(to: location) {
                            groupBest = solution
                        }

                        particle.groupBest = groupBest
                        errors.append(particle.current.distance(to: location))
                    }

                    // Update values
                    for particle in self.population {
                        particle.velocity = self.newVelocity(particle: particle)
                        particle.current = self.newPosition(particle: particle)

                        DispatchQueue.main.async {
                            particle.representationView?.setFrameOrigin(particle.current)
                        }
                    }

                    // Calculate sum
                    var errorSum: Double = 0
                    for error in errors {
                        errorSum += error
                    }

                    // Calculate average error
                    averageError = errorSum / Double(errors.count)

                    // Return progress as percent
                    DispatchQueue.main.async {
                        progress(Double(self.maxError) / averageError * 100)
                    }
                }
            }
        }
    }
}
