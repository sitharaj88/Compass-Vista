//
//  Protocols.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Service Protocols (Abstraction Layer)

protocol LocationServiceProtocol {
    var compassData: AnyPublisher<CompassData, Never> { get }
    var locationData: AnyPublisher<LocationData, Never> { get }
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var calibrationState: AnyPublisher<CalibrationState, Never> { get }
    
    func requestLocationPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startCalibration()
    func stopCalibration()
}

protocol HapticServiceProtocol {
    func lightFeedback()
    func mediumFeedback()
    func heavyFeedback()
    func selectionFeedback()
    func errorFeedback()
}

protocol ThemeServiceProtocol {
    var currentTheme: AnyPublisher<CompassTheme, Never> { get }
    func setTheme(_ theme: CompassTheme)
    func toggleDarkMode()
    var isDarkMode: AnyPublisher<Bool, Never> { get }
}

protocol SettingsServiceProtocol {
    var isHapticEnabled: AnyPublisher<Bool, Never> { get }
    var selectedTheme: AnyPublisher<CompassTheme, Never> { get }
    var isDarkModeEnabled: AnyPublisher<Bool, Never> { get }
    
    func setHapticEnabled(_ enabled: Bool)
    func setTheme(_ theme: CompassTheme)
    func setDarkMode(_ enabled: Bool)
}

// MARK: - Dependency Injection Container

class DIContainer: ObservableObject {
    static let shared = DIContainer()
    
    private init() {}
    
    // Services
    private lazy var _locationService: LocationServiceProtocol = LocationService()
    private lazy var _hapticService: HapticServiceProtocol = HapticService()
    private lazy var _themeService: ThemeServiceProtocol = ThemeService()
    private lazy var _settingsService: SettingsServiceProtocol = SettingsService()
    
    // Factory methods
    func locationService() -> LocationServiceProtocol {
        return _locationService
    }
    
    func hapticService() -> HapticServiceProtocol {
        return _hapticService
    }
    
    func themeService() -> ThemeServiceProtocol {
        return _themeService
    }
    
    func settingsService() -> SettingsServiceProtocol {
        return _settingsService
    }
    
    // ViewModels
    func makeCompassViewModel() -> CompassViewModel {
        return CompassViewModel(
            locationService: locationService(),
            hapticService: hapticService(),
            themeService: themeService(),
            settingsService: settingsService()
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            settingsService: settingsService(),
            themeService: themeService(),
            hapticService: hapticService()
        )
    }
    
    func makeCalibrationViewModel() -> CalibrationViewModel {
        return CalibrationViewModel(
            locationService: locationService(),
            hapticService: hapticService()
        )
    }
}