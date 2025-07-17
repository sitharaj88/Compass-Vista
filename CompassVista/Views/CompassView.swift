//
//  CompassView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct CompassView: View {
    @StateObject private var viewModel = DIContainer.shared.makeCompassViewModel()
    @State private var showingSettings = false
    @State private var showingCalibration = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic background
                DynamicBackgroundView(
                    theme: viewModel.currentTheme,
                    isDarkMode: viewModel.isDarkMode,
                    heading:  0
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header with location info
                    HeaderView(viewModel: viewModel)
                    
                    Spacer()
                    
                    // Main compass with enhanced 3D needle
                    EnhancedCompass3DView(
                        viewModel: viewModel,
                        size: min(geometry.size.width, geometry.size.height) * 0.85
                    )
                    
                    Spacer()
                    
                    // Bottom controls
                    BottomControlsView(
                        viewModel: viewModel,
                        showingSettings: $showingSettings,
                        showingCalibration: $showingCalibration
                    )
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startCompass()
            checkCalibrationStatus()
        }
        .onDisappear {
            viewModel.stopCompass()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingCalibration) {
            CalibrationView()
                .environmentObject(viewModel)
        }
        .alert("Compass Needs Calibration", isPresented: .constant(viewModel.calibrationState == .failed)) {
            Button("Calibrate Now") {
                showingCalibration = true
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("Your compass accuracy is low. Calibration will improve reading precision.")
        }
    }
    
    private func checkCalibrationStatus() {
        // Check if compass was calibrated recently (within 30 days)
        if let lastCalibration = UserDefaults.standard.object(forKey: "calibration_date") as? Date {
            let daysSinceCalibration = Calendar.current.dateComponents([.day], from: lastCalibration, to: Date()).day ?? 0
            if daysSinceCalibration > 30 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    viewModel.calibrationState = .failed
                }
            }
        } else {
            // Never calibrated - show prompt after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                viewModel.calibrationState = .failed
            }
        }
    }
}

struct HeaderView: View {
    @ObservedObject var viewModel: CompassViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Location authorization status
            if !viewModel.isLocationAuthorized {
                EnhancedLocationPermissionView(viewModel: viewModel)
            } else {
                // Heading display
                HStack {
                    Text(viewModel.formattedHeading)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(themeColor)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.cardinalDirection)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeColor)
                        
                        Text("Accuracy: \(viewModel.compassAccuracy)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Location info (if enabled)
                if viewModel.showingLocationInfo {
                    LocationInfoView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showingLocationInfo)
    }
    
    private var themeColor: Color {
        switch viewModel.currentTheme {
        case .classic: return .red
        case .modern: return .blue
        case .minimal: return .primary
        case .military: return .green
        case .ocean: return .teal
        case .sunset: return .orange
        }
    }
}

struct EnhancedLocationPermissionView: View {
    @ObservedObject var viewModel: CompassViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Location Access Required")
                .font(.headline)
            
            Text("CompassVista needs location access to provide accurate compass readings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Enable Location") {
                viewModel.requestLocationPermission()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct LocationInfoView: View {
    @ObservedObject var viewModel: CompassViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                Text(viewModel.formattedCoordinates)
                    .font(.system(.body, design: .monospaced))
            }
            
            HStack {
                Image(systemName: "mountain.2")
                    .foregroundColor(.brown)
                Text(viewModel.formattedAltitude)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    CompassView()
}
