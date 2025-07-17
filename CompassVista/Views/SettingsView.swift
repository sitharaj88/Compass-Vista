/*
 SettingsView.swift
 CompassVista

 Author: Sitharaj Seenivasan
 License: Apache License 2.0
 GitHub: https://github.com/sitharaj88/Compass-Vista

 Created by Sitharaj Seenivasan on 17/07/25.
*/

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = DIContainer.shared.makeSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    @State private var showLegalSheet = false
    
    // Simulated location authorization status text
    private var locationStatusText: String {
        // Placeholder for actual location authorization status
        "Authorized"
    }
    
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
                            .listRowSeparator(.hidden)
                        }
                    }
                    .accessibilityLabel("Theme Picker")
                    .onChange(of: viewModel.selectedTheme) { newTheme in
                        viewModel.setTheme(newTheme)
                    }
                    .listRowSeparator(.hidden)
                    
                    // Dark mode toggle
                    Toggle("Dark Mode", isOn: $viewModel.isDarkModeEnabled)
                        .accessibilityLabel("Dark Mode Toggle")
                        .onChange(of: viewModel.isDarkModeEnabled) { enabled in
                            viewModel.setDarkMode(enabled)
                        }
                        .listRowSeparator(.hidden)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                
                // Feedback Settings
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $viewModel.isHapticEnabled)
                        .accessibilityLabel("Haptic Feedback Toggle")
                        .onChange(of: viewModel.isHapticEnabled) { enabled in
                            viewModel.setHapticEnabled(enabled)
                        }
                        .listRowSeparator(.hidden)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                
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
                    .listRowSeparator(.hidden)
                    
                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.green)
                        Text("Location Services")
                        Spacer()
                        Text("Required")
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)
                    
                    // Placeholder for LocationAuthorizationView - if this view exists in your project, replace the below block with:
                    // LocationAuthorizationView()
                    //     .listRowSeparator(.hidden)
                    // If not available, simulate a row showing status and a button to open system settings:
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Location Authorization")
                        Spacer()
                        Text(locationStatusText)
                            .foregroundColor(.secondary)
                        Button {
                            locationSettingsAction()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Open Location Settings")
                    }
                    .listRowSeparator(.hidden)
                    
                    Button {
                        showLegalSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                            Text("Legal & Licenses")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                
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
                    .listRowSeparator(.hidden)
                }
                .listRowBackground(Color(.systemGroupedBackground))
                
                // Reset Settings Section
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("Reset Settings")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowSeparator(.hidden)
                }
                .listRowBackground(Color(.systemGroupedBackground))
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
            .alert("Reset Settings", isPresented: $showResetAlert, actions: {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    // Call resetSettings() defined on the view model
                    viewModel.resetSettings()
                    dismiss()
                }
            }, message: {
                Text("Are you sure you want to reset all settings to their defaults?")
            })
            .sheet(isPresented: $showLegalSheet) {
                LegalView()
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
    
    private func locationSettingsAction() {
        // Open the app settings so user can change location permission
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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

struct LegalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sitharaj Seenivasan")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Apache License 2.0 Summary")
                        .font(.headline)
                    
                    Text("""
                    Licensed under the Apache License, Version 2.0 (the "License");
                    you may not use this file except in compliance with the License.
                    You may obtain a copy of the License at

                    http://www.apache.org/licenses/LICENSE-2.0

                    Unless required by applicable law or agreed to in writing, software
                    distributed under the License is distributed on an "AS IS" BASIS,
                    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                    See the License for the specific language governing permissions and
                    limitations under the License.
                    """)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/sitharaj88/Compass-Vista")!)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationTitle("Legal & Licenses")
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
}

#Preview {
    SettingsView()
}

#Preview {
    CalibrationView()
}
