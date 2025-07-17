//
//  EnhancedLocationService.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import CoreLocation
import Combine
import UIKit

// Enhanced protocol with permission handling
protocol EnhancedLocationServiceProtocol: LocationServiceProtocol {
    var permissionDenied: AnyPublisher<Void, Never> { get }
    func openAppSettings()
}

class EnhancedLocationService: NSObject, EnhancedLocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    // Publishers
    private let compassDataSubject = PassthroughSubject<CompassData, Never>()
    private let locationDataSubject = PassthroughSubject<LocationData, Never>()
    private let authorizationStatusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    private let calibrationStateSubject = CurrentValueSubject<CalibrationState, Never>(.notStarted)
    private let permissionDeniedSubject = PassthroughSubject<Void, Never>()
    
    var compassData: AnyPublisher<CompassData, Never> {
        compassDataSubject.eraseToAnyPublisher()
    }
    
    var locationData: AnyPublisher<LocationData, Never> {
        locationDataSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    
    var calibrationState: AnyPublisher<CalibrationState, Never> {
        calibrationStateSubject.eraseToAnyPublisher()
    }
    
    var permissionDenied: AnyPublisher<Void, Never> {
        permissionDeniedSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1.0
        authorizationStatusSubject.send(locationManager.authorizationStatus)
        
        // Check if we need to request permission on app start
        if locationManager.authorizationStatus == .notDetermined {
            // Will trigger permission request on app launch
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Notify that we need to show the user how to enable permissions
            permissionDeniedSubject.send()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func startCalibration() {
        calibrationStateSubject.send(.inProgress)
        locationManager.dismissHeadingCalibrationDisplay()
    }
    
    func stopCalibration() {
        calibrationStateSubject.send(.completed)
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension EnhancedLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let compassData = CompassData(
            heading: newHeading.magneticHeading,
            trueHeading: newHeading.trueHeading,
            magneticHeading: newHeading.magneticHeading,
            accuracy: newHeading.headingAccuracy,
            timestamp: newHeading.timestamp
        )
        
        compassDataSubject.send(compassData)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let locationData = LocationData(
            coordinate: location.coordinate,
            altitude: location.altitude,
            accuracy: location.horizontalAccuracy,
            timestamp: location.timestamp
        )
        
        locationDataSubject.send(locationData)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusSubject.send(status)
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
            permissionDeniedSubject.send()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                permissionDeniedSubject.send()
            case .headingFailure:
                calibrationStateSubject.send(.failed)
            default:
                calibrationStateSubject.send(.failed)
            }
        } else {
            calibrationStateSubject.send(.failed)
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}