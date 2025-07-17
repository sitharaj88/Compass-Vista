//
//  CompassViewModel.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI

class CompassViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var compassData: CompassData?
    @Published var locationData: LocationData?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var calibrationState: CalibrationState = .notStarted
    @Published var currentTheme: CompassTheme = .classic
    @Published var isDarkMode: Bool = false
    @Published var isHapticEnabled: Bool = true
    @Published var showingLocationInfo: Bool = false
    @Published var needleRotation: Double = 0
    @Published var showPermissionAlert: Bool = false
    
    // MARK: - Dependencies
    private let locationService: LocationServiceProtocol
    private let hapticService: HapticServiceProtocol
    private let themeService: ThemeServiceProtocol
    private let settingsService: SettingsServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        locationService: LocationServiceProtocol,
        hapticService: HapticServiceProtocol,
        themeService: ThemeServiceProtocol,
        settingsService: SettingsServiceProtocol
    ) {
        self.locationService = locationService
        self.hapticService = hapticService
        self.themeService = themeService
        self.settingsService = settingsService
        
        setupBindings()
        requestLocationPermission()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Location and compass data
        locationService.compassData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] compassData in
                self?.compassData = compassData
                self?.updateNeedleRotation(compassData.heading)
                self?.triggerHapticFeedbackIfNeeded()
            }
            .store(in: &cancellables)
        
        locationService.locationData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locationData in
                self?.locationData = locationData
            }
            .store(in: &cancellables)
        
        locationService.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.authorizationStatus = status
            }
            .store(in: &cancellables)
        
        locationService.calibrationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.calibrationState = state
            }
            .store(in: &cancellables)
        
        // Theme and settings
        themeService.currentTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                self?.currentTheme = theme
            }
            .store(in: &cancellables)
        
        themeService.isDarkMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDark in
                self?.isDarkMode = isDark
            }
            .store(in: &cancellables)
        
        settingsService.isHapticEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.isHapticEnabled = enabled
            }
            .store(in: &cancellables)
    }
    
    private func updateNeedleRotation(_ heading: Double) {
        withAnimation(.easeInOut(duration: 0.3)) {
            needleRotation = -heading
        }
    }
    
    private func triggerHapticFeedbackIfNeeded() {
        guard isHapticEnabled,
              let compassData = compassData else { return }
        
        // Trigger haptic feedback when crossing cardinal directions
        let cardinalHeadings: [Double] = [0, 90, 180, 270]
        let tolerance: Double = 2.0
        
        for cardinalHeading in cardinalHeadings {
            if abs(compassData.heading - cardinalHeading) < tolerance {
                hapticService.lightFeedback()
                break
            }
        }
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    func startCompass() {
        locationService.startUpdatingLocation()
    }
    
    func stopCompass() {
        locationService.stopUpdatingLocation()
    }
    
    func startCalibration() {
        locationService.startCalibration()
        if isHapticEnabled {
            hapticService.mediumFeedback()
        }
    }
    
    func stopCalibration() {
        locationService.stopCalibration()
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
    
    func toggleLocationInfo() {
        showingLocationInfo.toggle()
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
    
    func setTheme(_ theme: CompassTheme) {
        themeService.setTheme(theme)
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
    
    func toggleDarkMode() {
        themeService.toggleDarkMode()
        if isHapticEnabled {
            hapticService.selectionFeedback()
        }
    }
    
    // MARK: - Computed Properties
    var isLocationAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var formattedHeading: String {
        compassData?.formattedHeading ?? "---°"
    }
    
    var cardinalDirection: String {
        compassData?.cardinalDirection.rawValue ?? "---"
    }
    
    var formattedCoordinates: String {
        locationData?.formattedCoordinate ?? "Unknown Location"
    }
    
    var formattedAltitude: String {
        locationData?.formattedAltitude ?? "Unknown Altitude"
    }
    
    var compassAccuracy: String {
        guard let accuracy = compassData?.accuracy else { return "Unknown" }
        if accuracy < 0 {
            return "Invalid"
        } else if accuracy < 5 {
            return "High"
        } else if accuracy < 15 {
            return "Medium"
        } else {
            return "Low"
        }
    }
}
