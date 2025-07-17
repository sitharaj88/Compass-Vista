//
//  SettingsView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = DIContainer.shared.makeSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Theme Selection
                Section("Appearance") {
                    // Theme picker
                    Picker("Theme", selection: $viewModel.selectedTheme) {
                        ForEach(CompassTheme.allCases, id: \.self) { theme in
                            HStack {
                                Circle()
                                    .fill(themeColor(for: theme))
                                    .frame(width: 20, height: 20)
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                    .onChange(of: viewModel.selectedTheme) { oldTheme, newTheme in
                        viewModel.setTheme(newTheme)
                    }
                    
                    // Dark mode toggle
                    Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                        .onChange(of: viewModel.isDarkModeEnabled) { _, enabled in
                            viewModel.setDarkMode(enabled)
                        }
                }
                
                // Feedback Settings
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $viewModel.isHapticEnabled)
                        .onChange(of: viewModel.isHapticEnabled) { _, enabled in
                            viewModel.setHapticEnabled(enabled)
                        }
                }
                
                // App Information
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.green)
                        Text("Location Services")
                        Spacer()
                        Text("Required")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Calibration Info
                Section("Calibration") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For best accuracy, calibrate your compass regularly:")
                            .font(.subheadline)
                        
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("Hold device upright")
                        }
                        .font(.caption)
                        
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Move in figure-8 pattern")
                        }
                        .font(.caption)
                        
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            Text("Continue until complete")
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func themeColor(for theme: CompassTheme) -> Color {
        switch theme {
        case .classic: return .red
        case .modern: return .blue
        case .minimal: return .gray
        case .military: return .green
        case .ocean: return .teal
        case .sunset: return .orange
        }
    }
}

struct CalibrationAnimationView: View {
    let state: CalibrationState
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                .frame(width: 150, height: 150)
            
            // Animated elements based on state
            switch state {
            case .notStarted:
                Image(systemName: "gyroscope")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            scale = 1.2
                        }
                    }
                
            case .inProgress:
                Image(systemName: "gyroscope")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            scale = 1.2
                        }
                    }
                
            case .failed:
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            scale = 1.2
                        }
                    }
            }
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
}

#Preview {
    CalibrationView()
}
