//
//  ViewController.swift
//  ParticleSwarm
//
//  Created by Hrvoje Baic on 21/09/2019.
//  Copyright © 2019 Hrvoje Baic. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Properties

    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var previewView: NSView!
    @IBOutlet weak var sizeTextField: NSTextField!
    @IBOutlet weak var cTextField: NSTextField!
    @IBOutlet weak var vMaxTextField: NSTextField!
    @IBOutlet weak var maxAvgErrorTextField: NSTextField!
    @IBOutlet weak var swarmSizeTextField: NSTextField!

    var swarm: Swarm?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Clicking inside a preview view will generate new
        // rally point for the swarm
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(setSwarmRallyPoint(recognizer:)))
        clickRecognizer.numberOfTouchesRequired = 1
        previewView.addGestureRecognizer(clickRecognizer)
    }

    // MARK: - Helpers

    // MARK: - Actions

    /// Sets a new rally poiny for the swarm
    @objc private func setSwarmRallyPoint(recognizer: NSClickGestureRecognizer) {
        let targetLocation = recognizer.location(in: previewView)
        swarm?.swarmTo(location: targetLocation, progress: { [weak self] percent in
            let filteredProgress = percent > 100 ? 100 : percent
            self?.progressLabel.stringValue = "Progress: \(filteredProgress)"
        })
    }

    @IBAction func spawnPopulation(_ sender: NSButton) {

        guard let c = Float(cTextField.stringValue),
            let vMax = Float(vMaxTextField.stringValue),
            let particleSide = Int(sizeTextField.stringValue),
            let swarmSize = Int(swarmSizeTextField.stringValue),
            let maxError = Int(maxAvgErrorTextField.stringValue)
            else { return }

        let size = NSSize(width: particleSide, height: particleSide)
        swarm = Swarm(c: CGFloat(c),
                      vMax: CGFloat(vMax),
                      unitSize: size,
                      swarmSize: swarmSize,
                      swarmBounds: previewView.bounds,
                      maxError: maxError)

        previewView.subviews.removeAll()

        for particle in swarm!.population {

            let particleFrame = NSRect(x: particle.current.x, y: particle.current.y, width: size.width, height: size.height)
            let particleView = NSView(frame: particleFrame)
            previewView.addSubview(particleView)

            particleView.wantsLayer = true
            particleView.layer?.backgroundColor = NSColor.white.cgColor

            particle.representationView = particleView
        }
    }
}
