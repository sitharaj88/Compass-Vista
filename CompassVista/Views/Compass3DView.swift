//
//  Compass3DView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct Compass3DView: View {
    @ObservedObject var viewModel: CompassViewModel
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Compass background circle
//            CompassBackgroundView(theme: viewModel.currentTheme, size: size)
            
//            // Compass markings and labels
//            CompassMarkingsView(size: size, theme: viewModel.currentTheme)
//            
//            // 3D Animated Needle
//            Compass3DNeedleView(
//                rotation: viewModel.needleRotation,
//                theme: viewModel.currentTheme,
//                size: size
//            )
//            
//            // Center dot
//            Circle()
//                .fill(Color.primary)
//                .frame(width: 8, height: 8)
//                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .frame(width: size, height: size)
        .onTapGesture {
            viewModel.toggleLocationInfo()
        }
    }
}

struct CompassBackgroundView: View {
    let theme: CompassTheme
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor, backgroundColor.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Inner background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [backgroundColor.opacity(0.1), backgroundColor.opacity(0.3)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size - 16, height: size - 16)
        }
    }
    
    private var backgroundColor: Color {
        switch theme {
        case .classic: return .brown
        case .modern: return .blue
        case .minimal: return .gray
        case .military: return .green
        case .ocean: return .teal
        case .sunset: return .orange
        }
    }
}

struct CompassMarkingsView: View {
    let size: CGFloat
    let theme: CompassTheme
    
    var body: some View {
        ZStack {
            // Cardinal and intercardinal direction labels
            ForEach(0..<8) { index in
                let angle = Double(index) * 45
                let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
                let direction = directions[index]
                let isCardinal = index % 2 == 0
                let color = direction == "N" ? Color.red : (isCardinal ? Color.primary : Color.primary.opacity(0.7))
                let fontSize: CGFloat = isCardinal ? 24 : 18
                let fontWeight: Font.Weight = isCardinal ? .bold : .semibold
                let distance: CGFloat = isCardinal ? 30 : 35
                
                Text(direction)
                    .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    .offset(y: -(size / 2 - distance))
                    .rotationEffect(.degrees(angle))
                    .rotationEffect(.degrees(-angle)) // Counter-rotate text
            }
            
            // Degree markings
            ForEach(0..<360, id: \.self) { degree in
                if degree % 5 == 0 {
                    let isMajor = degree % 30 == 0
                    let isMedium = degree % 15 == 0 && !isMajor
                    
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(isMajor ? Color.primary : (isMedium ? Color.primary.opacity(0.8) : Color.secondary.opacity(0.6)))
                            .frame(width: isMajor ? 3 : (isMedium ? 2 : 1),
                                  height: isMajor ? 20 : (isMedium ? 15 : 10))
                        
                        // Add degree numbers for major ticks
                        if isMajor && degree != 0 && degree != 90 && degree != 180 && degree != 270 {
                            Text("\(degree)°")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.primary.opacity(0.8))
                                .padding(.top, 2)
                                .rotationEffect(.degrees(-Double(degree)))
                        }
                    }
                    .offset(y: -(size / 2 - 15))
                    .rotationEffect(.degrees(Double(degree)))
                }
            }
        }
    }
}

struct Compass3DNeedleView: View {
    let rotation: Double
    let theme: CompassTheme
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Enhanced shadow for depth
            RealisticNeedleShape()
                .fill(Color.black.opacity(0.4))
                .frame(width: size * 0.06, height: size * 0.7)
                .offset(x: 3, y: 3)
                .blur(radius: 4)
                .rotationEffect(.degrees(rotation))
            
            // Main realistic needle
            ZStack {
                // North pointer (colored) - Realistic design
                RealisticNeedleShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                needleColor,
                                needleColor.opacity(0.8),
                                needleColor.opacity(0.9),
                                needleColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RealisticNeedleShape()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        needleColor.opacity(0.6),
                                        needleColor.opacity(0.9)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        // Metallic highlight effect
                        RealisticNeedleShape()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .clear,
                                        .white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(0.8)
                            .offset(x: -1, y: -1)
                    )
                    .frame(width: size * 0.05, height: size * 0.4)
                    .offset(y: -size * 0.2)
                
                // South pointer (white/silver) - Realistic metallic design
                RealisticNeedleShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white,
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.7),
                                .white
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RealisticNeedleShape()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.gray.opacity(0.5),
                                        Color.gray.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        // Metallic shine effect
                        RealisticNeedleShape()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.9),
                                        .clear,
                                        .white.opacity(0.5)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(0.8)
                            .offset(x: -1, y: -1)
                    )
                    .frame(width: size * 0.05, height: size * 0.4)
                    .offset(y: size * 0.2)
                    .rotationEffect(.degrees(180))
            }
            .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
            .rotationEffect(.degrees(rotation))
            .animation(.easeInOut(duration: 0.3), value: rotation)
            
            // Center pivot point - realistic metal bearing
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.gray.opacity(0.8),
                            Color.gray
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
    
    private var needleColor: Color {
        switch theme {
        case .classic: return .red
        case .modern: return .blue
        case .minimal: return .primary
        case .military: return .green
        case .ocean: return .teal
        case .sunset: return .orange
        }
    }
}

struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create arrow-like needle shape
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.6, y: height))
        path.addLine(to: CGPoint(x: width * 0.4, y: height))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.3))
        path.closeSubpath()
        
        return path
    }
}

struct RealisticNeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a more realistic needle shape with a wider base and tapered top
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.7, y: height))
        path.addLine(to: CGPoint(x: width * 0.3, y: height))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.5))
        path.closeSubpath()
        
        return path
    }
}

struct DynamicBackgroundView: View {
    let theme: CompassTheme
    let isDarkMode: Bool
    let heading: Double
    
    var body: some View {
        ZStack {
            // Base background
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Dynamic overlay based on heading
            RadialGradient(
                gradient: Gradient(colors: [overlayColor.opacity(0.3), Color.clear]),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .rotationEffect(.degrees(heading))
            .animation(.easeInOut(duration: 1.0), value: heading)
        }
    }
    
    private var backgroundColors: [Color] {
        if isDarkMode {
            switch theme {
            case .classic: return [.black, .gray]
            case .modern: return [.black, .blue.opacity(0.3)]
            case .minimal: return [.black, .gray.opacity(0.5)]
            case .military: return [.black, .green.opacity(0.3)]
            case .ocean: return [.black, .teal.opacity(0.3)]
            case .sunset: return [.black, .orange.opacity(0.3)]
            }
        } else {
            switch theme {
            case .classic: return [.white, .brown.opacity(0.2)]
            case .modern: return [.white, .blue.opacity(0.1)]
            case .minimal: return [.white, .gray.opacity(0.1)]
            case .military: return [.white, .green.opacity(0.1)]
            case .ocean: return [.white, .teal.opacity(0.1)]
            case .sunset: return [.white, .orange.opacity(0.2)]
            }
        }
    }
    
    private var overlayColor: Color {
        switch theme {
        case .classic: return .orange
        case .modern: return .cyan
        case .minimal: return .gray
        case .military: return .yellow
        case .ocean: return .teal
        case .sunset: return .orange
        }
    }
}

struct BottomControlsView: View {
    @ObservedObject var viewModel: CompassViewModel
    @Binding var showingSettings: Bool
    @Binding var showingCalibration: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            // Calibration button
            Button(action: {
                showingCalibration = true
            }) {
                VStack {
                    Image(systemName: "gyroscope")
                        .font(.title2)
                    Text("Calibrate")
                        .font(.caption)
                }
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            // Location info toggle
            Button(action: {
                viewModel.toggleLocationInfo()
            }) {
                VStack {
                    Image(systemName: viewModel.showingLocationInfo ? "location.fill" : "location")
                        .font(.title2)
                    Text("Location")
                        .font(.caption)
                }
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            // Settings button
            Button(action: {
                showingSettings = true
            }) {
                VStack {
                    Image(systemName: "gear")
                        .font(.title2)
                    Text("Settings")
                        .font(.caption)
                }
            }
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CompassView()
}
