//
//  HapticService.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import UIKit

class HapticService: HapticServiceProtocol {
    private let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    init() {
        // Prepare generators for better performance
        lightFeedbackGenerator.prepare()
        mediumFeedbackGenerator.prepare()
        heavyFeedbackGenerator.prepare()
        selectionFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
    
    func lightFeedback() {
        lightFeedbackGenerator.impactOccurred()
    }
    
    func mediumFeedback() {
        mediumFeedbackGenerator.impactOccurred()
    }
    
    func heavyFeedback() {
        heavyFeedbackGenerator.impactOccurred()
    }
    
    func selectionFeedback() {
        selectionFeedbackGenerator.selectionChanged()
    }
    
    func errorFeedback() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
}