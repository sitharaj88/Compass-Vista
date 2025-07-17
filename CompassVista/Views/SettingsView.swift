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
                    .onChange(of: viewModel.selectedTheme) { theme in
                        viewModel.setTheme(theme)
                    }
                    
                    // Dark mode toggle
                    Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                        .onChange(of: viewModel.isDarkModeEnabled) { enabled in
                            viewModel.setDarkMode(enabled)
                        }
                }
                
                // Feedback Settings
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $viewModel.isHapticEnabled)
                        .onChange(of: viewModel.isHapticEnabled) { enabled in
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
        }
    }
}

#Preview {
    SettingsView()
}
