//
//  ThemeService.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import Combine

class ThemeService: ThemeServiceProtocol {
    private let currentThemeSubject = CurrentValueSubject<CompassTheme, Never>(.classic)
    private let isDarkModeSubject = CurrentValueSubject<Bool, Never>(false)
    
    var currentTheme: AnyPublisher<CompassTheme, Never> {
        currentThemeSubject.eraseToAnyPublisher()
    }
    
    var isDarkMode: AnyPublisher<Bool, Never> {
        isDarkModeSubject.eraseToAnyPublisher()
    }
    
    func setTheme(_ theme: CompassTheme) {
        currentThemeSubject.send(theme)
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    func toggleDarkMode() {
        let newValue = !isDarkModeSubject.value
        isDarkModeSubject.send(newValue)
        UserDefaults.standard.set(newValue, forKey: "isDarkMode")
    }
    
    init() {
        loadSavedSettings()
    }
    
    private func loadSavedSettings() {
        // Load saved theme
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = CompassTheme(rawValue: savedTheme) {
            currentThemeSubject.send(theme)
        }
        
        // Load saved dark mode setting
        let savedDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        isDarkModeSubject.send(savedDarkMode)
    }
}

class SettingsService: SettingsServiceProtocol {
    private let isHapticEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let selectedThemeSubject = CurrentValueSubject<CompassTheme, Never>(.classic)
    private let isDarkModeEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isHapticEnabled: AnyPublisher<Bool, Never> {
        isHapticEnabledSubject.eraseToAnyPublisher()
    }
    
    var selectedTheme: AnyPublisher<CompassTheme, Never> {
        selectedThemeSubject.eraseToAnyPublisher()
    }
    
    var isDarkModeEnabled: AnyPublisher<Bool, Never> {
        isDarkModeEnabledSubject.eraseToAnyPublisher()
    }
    
    func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabledSubject.send(enabled)
        UserDefaults.standard.set(enabled, forKey: "isHapticEnabled")
    }
    
    func setTheme(_ theme: CompassTheme) {
        selectedThemeSubject.send(theme)
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
    
    func setDarkMode(_ enabled: Bool) {
        isDarkModeEnabledSubject.send(enabled)
        UserDefaults.standard.set(enabled, forKey: "isDarkMode")
    }
    
    init() {
        loadSavedSettings()
    }
    
    private func loadSavedSettings() {
        // Load haptic setting
        let hapticEnabled = UserDefaults.standard.object(forKey: "isHapticEnabled") as? Bool ?? true
        isHapticEnabledSubject.send(hapticEnabled)
        
        // Load theme setting
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = CompassTheme(rawValue: savedTheme) {
            selectedThemeSubject.send(theme)
        }
        
        // Load dark mode setting
        let darkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        isDarkModeEnabledSubject.send(darkMode)
    }
}