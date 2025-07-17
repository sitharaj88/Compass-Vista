//
//  SettingsViewModel.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isHapticEnabled: Bool = true
    @Published var selectedTheme: CompassTheme = .classic
    @Published var isDarkModeEnabled: Bool = false
    
    private let settingsService: SettingsServiceProtocol
    private let themeService: ThemeServiceProtocol
    private let hapticService: HapticServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        settingsService: SettingsServiceProtocol,
        themeService: ThemeServiceProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.settingsService = settingsService
        self.themeService = themeService
        self.hapticService = hapticService
        
        setupBindings()
    }
    
    private func setupBindings() {
        settingsService.isHapticEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.isHapticEnabled = enabled
            }
            .store(in: &cancellables)
        
        settingsService.selectedTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                self?.selectedTheme = theme
            }
            .store(in: &cancellables)
        
        settingsService.isDarkModeEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.isDarkModeEnabled = enabled
            }
            .store(in: &cancellables)
    }
    
    func setHapticEnabled(_ enabled: Bool) {
        settingsService.setHapticEnabled(enabled)
        if enabled {
            hapticService.selectionFeedback()
        }
    }
    
    func setTheme(_ theme: CompassTheme) {
        settingsService.setTheme(theme)
        themeService.setTheme(theme)
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
    
    func setDarkMode(_ enabled: Bool) {
        settingsService.setDarkMode(enabled)
        themeService.toggleDarkMode()
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
}

class CalibrationViewModel: ObservableObject {
    @Published var calibrationState: CalibrationState = .notStarted
    @Published var calibrationInstructions: String = ""
    @Published var showingCalibration: Bool = false
    
    private let locationService: LocationServiceProtocol
    private let hapticService: HapticServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        locationService: LocationServiceProtocol,
        hapticService: HapticServiceProtocol
    ) {
        self.locationService = locationService
        self.hapticService = hapticService
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationService.calibrationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.calibrationState = state
                self?.updateInstructions(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateInstructions(for state: CalibrationState) {
        switch state {
        case .notStarted:
            calibrationInstructions = "Tap 'Start Calibration' to begin"
        case .inProgress:
            calibrationInstructions = "Move your device in a figure-8 pattern until calibration is complete"
        case .completed:
            calibrationInstructions = "Calibration complete! Your compass is now accurate"
        case .failed:
            calibrationInstructions = "Calibration failed. Please try again in an area with less magnetic interference"
        }
    }
    
    func startCalibration() {
        showingCalibration = true
        locationService.startCalibration()
        hapticService.mediumFeedback()
    }
    
    func stopCalibration() {
        showingCalibration = false
        locationService.stopCalibration()
        hapticService.selectionFeedback()
    }
}