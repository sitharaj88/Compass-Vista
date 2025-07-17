//
//  CalibrationView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct CalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var calibrationStep = 0
    @State private var isCalibrating = false
    @State private var calibrationProgress: CGFloat = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "gyroscope")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(calibrationProgress * 360))
                        .animation(.easeInOut(duration: 0.5), value: calibrationProgress)
                    
                    Text("Compass Calibration")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Follow the steps below to calibrate your compass for accurate readings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Calibration steps
                VStack(spacing: 20) {
                    CalibrationStepView(
                        step: 1,
                        title: "Hold your device flat",
                        description: "Keep your iPhone parallel to the ground",
                        isActive: calibrationStep >= 1,
                        isCompleted: calibrationStep > 1
                    )
                    
                    CalibrationStepView(
                        step: 2,
                        title: "Rotate in a figure-8 pattern",
                        description: "Move your device in a figure-8 motion several times",
                        isActive: calibrationStep >= 2,
                        isCompleted: calibrationStep > 2
                    )
                    
                    CalibrationStepView(
                        step: 3,
                        title: "Rotate around all axes",
                        description: "Slowly rotate your device around all three axes",
                        isActive: calibrationStep >= 3,
                        isCompleted: calibrationStep > 3
                    )
                }
                
                Spacer()
                
                // Progress indicator
                if isCalibrating {
                    VStack(spacing: 15) {
                        ProgressView(value: calibrationProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(y: 2)
                        
                        Text("Calibrating... \(Int(calibrationProgress * 100))%")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    // Start calibration button
                    Button(action: startCalibration) {
                        Text("Start Calibration")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(isCalibrating)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if calibrationStep > 3 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private func startCalibration() {
        isCalibrating = true
        calibrationStep = 1
        
        // Fixed Timer initialization to avoid ambiguity
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            calibrationProgress += 0.02
            
            if calibrationProgress >= 0.33 && calibrationStep == 1 {
                calibrationStep = 2
            } else if calibrationProgress >= 0.66 && calibrationStep == 2 {
                calibrationStep = 3
            } else if calibrationProgress >= 1.0 {
                calibrationStep = 4
                isCalibrating = false
                timer.invalidate()
            }
        }
    }
}

struct CalibrationStepView: View {
    let step: Int
    let title: String
    let description: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Step indicator
            ZStack {
                Circle()
                    .fill(stepColor)
                    .frame(width: 30, height: 30)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Step content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isActive ? .primary : .secondary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var stepColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .blue
        } else {
            return .gray
        }
    }
}

#Preview {
    CalibrationView()
}
