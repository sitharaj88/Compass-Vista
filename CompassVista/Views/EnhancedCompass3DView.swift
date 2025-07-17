//
//  EnhancedCompass3DView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct EnhancedCompass3DView: View {
    @ObservedObject var viewModel: CompassViewModel
    let size: CGFloat
    @State private var isSpinning = false
    @State private var wobble: Double = 0
    
    var body: some View {
        ZStack {
            // Realistic compass base with premium materials
            RealisticCompassBase(theme: viewModel.currentTheme, size: size)
            
            // Detailed compass rose with intricate markings
            DetailedCompassRose(size: size, theme: viewModel.currentTheme)
            
            // Premium 3D compass needle with physics
            PremiumCompassNeedle(
                rotation: viewModel.needleRotation,
                theme: viewModel.currentTheme,
                size: size,
                wobble: wobble
            )
            
            // Center pivot with metallic effect
            CenterPivot(size: size, theme: viewModel.currentTheme)
            
            // Glass dome overlay effect
            GlassDome(size: size)
                .blendMode(.normal)
        }
        .frame(width: size, height: size)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                isSpinning = true
                // Add physics effect on tap
                wobble = Double.random(in: -5...5)
            }
            
            // Reset wobble after animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.4).delay(0.6)) {
                wobble = 0
                isSpinning = false
            }
            
            viewModel.toggleLocationInfo()
        }
        .onChange(of: viewModel.needleRotation) { oldValue, newValue in
            // Add physics-based wobble effect when heading changes significantly
            if abs(oldValue - newValue) > 5 && abs(wobble) < 1 {
                let wobbleAmount = min(4, abs(oldValue - newValue) * 0.05)
                withAnimation(.spring(response: 0.8, dampingFraction: 0.2)) {
                    wobble = wobbleAmount * (Bool.random() ? 1 : -1)
                }
                
                // Reset wobble after animation
                withAnimation(.spring(response: 1.2, dampingFraction: 0.4).delay(0.8)) {
                    wobble = 0
                }
            }
        }
    }
}

// Realistic wooden/metal compass base
struct RealisticCompassBase: View {
    let theme: CompassTheme
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main compass body
            Circle()
                .fill(baseGradient)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)
            
            // Outer metallic ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "D4AF37"),
                            Color(hex: "FFD700"),
                            Color(hex: "FFC125"),
                            Color(hex: "D4AF37"),
                            Color(hex: "996515"),
                            Color(hex: "D4AF37")
                        ]),
                        center: .center
                    ),
                    lineWidth: 12
                )
                .frame(width: size - 2, height: size - 2)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Secondary ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color.black.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size - 24, height: size - 24)
            
            // Inner background with texture
            Circle()
                .fill(innerBackgroundGradient)
                .frame(width: size - 28, height: size - 28)
                .overlay(
                    // Subtle texture pattern for realistic paper/parchment look
                    Circle()
                        .fill(
                            ImagePaint(
                                image: Image(systemName: "circle.grid.2x2"),
                                sourceRect: CGRect(x: 0, y: 0, width: 0.5, height: 0.5),
                                scale: 0.1
                            )
                        )
                        .opacity(0.05)
                )
            
            // Inner bevel effect
            Circle()
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.clear,
                            Color.black.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size - 32, height: size - 32)
        }
    }
    
    private var baseGradient: AnyShapeStyle {
        switch theme {
        case .classic:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "8B4513").opacity(0.8),
                        Color(hex: "654321")
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 1.5
                )
            )
        case .modern:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "2C3E50"),
                        Color(hex: "1A2530")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .minimal:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E0E0E0"),
                        Color(hex: "BDBDBD")
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 1.5
                )
            )
        case .military:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "4B5320"),
                        Color(hex: "333D15")
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 1.5
                )
            )
        }
    }
    
    private var innerBackgroundGradient: some ShapeStyle {
        switch theme {
        case .classic:
            // Warm tan color that matches the screenshot
            return RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E8D0AA").opacity(0.95),
                    Color(hex: "D2B48C").opacity(0.85)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size / 2
            )
        case .modern:
            return RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "34495E").opacity(0.9),
                    Color(hex: "2C3E50").opacity(0.8)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size / 2
            )
        case .minimal:
            return RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F5F5F5").opacity(0.8),
                    Color(hex: "E0E0E0").opacity(0.7)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size / 2
            )
        case .military:
            return RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "5F7A61").opacity(0.8),
                    Color(hex: "3E5641").opacity(0.7)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: size / 2
            )
        }
    }
}

// Detailed compass rose with intricate markings
struct DetailedCompassRose: View {
    let size: CGFloat
    let theme: CompassTheme
    
    var body: some View {
        ZStack {
            // Decorative rose background pattern
            CompassRosePattern(size: size, theme: theme)
            
            // Main directional lines
            ForEach(0..<4) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.7),
                                Color.primary.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1.5, height: size - 60)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Secondary directional lines
            ForEach(0..<4) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primary.opacity(0.5),
                                Color.primary.opacity(0.2)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: size - 80)
                    .rotationEffect(.degrees(Double(index) * 45 + 22.5))
            }
            
            // Cardinal and ordinal direction labels - Fixed alignment and sizing
            ForEach(0..<8) { index in
                let angle = Double(index) * 45
                let isMainDirection = index % 2 == 0
                let direction = getDirectionText(index)
                let fontSize: CGFloat = isMainDirection ? 24 : 16 // Slightly smaller for two-character labels
                let fontWeight: Font.Weight = isMainDirection ? .bold : .semibold
                let color = getDirectionColor(index, isMain: isMainDirection)
                let frameWidth: CGFloat = isMainDirection ? 40 : 50 // Wider frame for NE, NW, SE, SW
                
                ZStack {
                    Text(direction)
                        .font(.system(size: fontSize, weight: fontWeight, design: .serif))
                        .foregroundColor(color)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
                        .rotationEffect(.degrees(-angle)) // Only counter-rotate the text
                        .minimumScaleFactor(0.8) // Allow text to scale down if needed
                        .lineLimit(1) // Ensure single line, no wrapping
                }
                .frame(width: frameWidth, height: 30) // Dynamic width based on text length
                .offset(y: -(size / 2 - 40))
                .rotationEffect(.degrees(angle)) // Position around the circle
            }
            
            // Degree markings with refined appearance
            ForEach(0..<360, id: \.self) { degree in
                if degree % 5 == 0 {
                    let isMajor = degree % 15 == 0
                    let height: CGFloat = degree % 45 == 0 ? 20 : (isMajor ? 15 : 8)
                    let width: CGFloat = degree % 45 == 0 ? 3 : (isMajor ? 2 : 1)
                    
                    Rectangle()
                        .fill(getDegreeColor(degree))
                        .frame(width: width, height: height)
                        .offset(y: -(size / 2 - 15))
                        .rotationEffect(.degrees(Double(degree)))
                        .shadow(color: .black.opacity(0.2), radius: 0.5, x: 0, y: 0.5)
                }
            }
            
            // Degree numbers (every 30 degrees)
//            ForEach(0..<12) { index in
//                let degree = index * 30
//                if degree != 0 && degree != 90 && degree != 180 && degree != 270 {
//                    Text("\(degree)°")
//                        .font(.system(size: 12, weight: .medium, design: .rounded))
//                        .foregroundColor(Color.primary.opacity(0.8))
//                        .offset(y: -(size / 2 - 60))
//                        .rotationEffect(.degrees(Double(degree)))
//                        .rotationEffect(.degrees(-Double(degree))) // Counter-rotate text
//                }
//            }
        }
    }
    
    private func getDirectionText(_ index: Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return directions[index]
    }
    
    private func getDirectionColor(_ index: Int, isMain: Bool) -> Color {
        if index == 0 { // North
            return .red
        } else if isMain {
            switch theme {
            case .classic: return Color(hex: "191970") // Dark navy blue
            case .modern: return Color.primary
            case .minimal: return Color.primary
            case .military: return Color(hex: "385723") // Dark green
            }
        } else {
            return Color.primary.opacity(0.8)
        }
    }
    
    private func getDegreeColor(_ degree: Int) -> Color {
        if degree == 0 || degree == 90 || degree == 180 || degree == 270 {
            switch theme {
            case .classic: return .red
            case .modern: return Color.blue
            case .minimal: return Color.primary
            case .military: return Color.green
            }
        } else if degree % 45 == 0 {
            return Color.primary.opacity(0.9)
        } else if degree % 15 == 0 {
            return Color.primary.opacity(0.7)
        } else {
            return Color.primary.opacity(0.5)
        }
    }
}

// Decorative compass rose pattern
struct CompassRosePattern: View {
    let size: CGFloat
    let theme: CompassTheme
    
    var body: some View {
        ZStack {
            // Classic compass rose decoration
            Image(systemName: "rosette")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size / 3)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: roseColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.4)
        }
    }
    
    private var roseColors: [Color] {
        switch theme {
        case .classic:
            return [Color(hex: "8B4513"), Color(hex: "A0522D")]
        case .modern:
            return [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]
        case .minimal:
            return [Color.gray.opacity(0.6), Color.gray.opacity(0.3)]
        case .military:
            return [Color.green.opacity(0.6), Color.green.opacity(0.3)]
        }
    }
}

// Premium 3D compass needle with realistic metallic effects
struct PremiumCompassNeedle: View {
    let rotation: Double
    let theme: CompassTheme
    let size: CGFloat
    let wobble: Double
    
    var body: some View {
        ZStack {
            // Realistic needle shadow with depth
            EnhancedNeedleShape()
                .fill(Color.black.opacity(0.25))
                .frame(width: size * 0.08, height: size * 0.7)
                .offset(x: 3, y: 3)
                .blur(radius: 4)
                .rotationEffect(.degrees(rotation))
                .rotationEffect(.degrees(wobble))
            
            // 3D needle with metallic effect
            ZStack {
                // North pointer with premium 3D effect
                EnhancedNeedleShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: getNorthNeedleColors()),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        EnhancedNeedleShape()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.7), .clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: size * 0.07, height: size * 0.35)
                    .offset(y: -size * 0.175)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                
                // South pointer with premium 3D effect
                EnhancedNeedleShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: getSouthNeedleColors()),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        EnhancedNeedleShape()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white.opacity(0.7), .clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: size * 0.07, height: size * 0.35)
                    .offset(y: size * 0.175)
                    .rotationEffect(.degrees(180))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: -1, y: -1)
            }
            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
            .rotationEffect(.degrees(rotation))
            .rotationEffect(.degrees(wobble))
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: rotation)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: wobble)
        }
    }
    
    private func getNorthNeedleColors() -> [Color] {
        switch theme {
        case .classic:
            return [Color(hex: "8B0000"), Color(hex: "FF0000"), Color(hex: "8B0000")]
        case .modern:
            return [Color(hex: "003366"), Color(hex: "0066CC"), Color(hex: "003366")]
        case .minimal:
            return [Color(hex: "2B2B2B"), Color(hex: "555555"), Color(hex: "2B2B2B")]
        case .military:
            return [Color(hex: "2B5329"), Color(hex: "4C9A2A"), Color(hex: "2B5329")]
        }
    }
    
    private func getSouthNeedleColors() -> [Color] {
        switch theme {
        case .classic, .modern, .military:
            return [Color(hex: "CCCCCC"), Color(hex: "FFFFFF"), Color(hex: "CCCCCC")]
        case .minimal:
            return [Color(hex: "555555"), Color(hex: "999999"), Color(hex: "555555")]
        }
    }
}

// Enhanced needle shape with more realistic proportions
struct EnhancedNeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create more elegant, tapered needle shape
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.25),
            control: CGPoint(x: width * 0.75, y: height * 0.1)
        )
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.95))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.95))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.35))
        path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: 0),
            control: CGPoint(x: width * 0.25, y: height * 0.1)
        )
        
        return path
    }
}

// Glass dome overlay effect for realistic reflections
struct GlassDome: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Glass dome reflection
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.2), location: 0),
                            .init(color: .white.opacity(0.1), location: 0.3),
                            .init(color: .white.opacity(0), location: 0.5),
                            .init(color: .white.opacity(0), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size - 20, height: size - 20)
                .offset(x: -size * 0.1, y: -size * 0.1)
            
            // Edge highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.6),
                            .white.opacity(0),
                            .white.opacity(0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: size - 10, height: size - 10)
                
            // Subtle fingerprint smudge for realism
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white.opacity(0.05), .clear]),
                        center: .init(x: 0.7, y: 0.3),
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: size - 40, height: size - 40)
                .blendMode(.overlay)
        }
    }
}

// Center pivot with realistic metallic effect
struct CenterPivot: View {
    let size: CGFloat
    let theme: CompassTheme
    
    var body: some View {
        ZStack {
            // Outer metallic ring
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "C0C0C0"),
                            Color(hex: "808080")
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: size * 0.1, height: size * 0.1)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // Central pivot
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: getPivotColors()),
                        center: .center,
                        startRadius: 0,
                        endRadius: 6
                    )
                )
                .frame(width: size * 0.06, height: size * 0.06)
            
            // Highlight reflection
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.02, height: size * 0.02)
                .offset(x: -size * 0.015, y: -size * 0.015)
        }
    }
    
    private func getPivotColors() -> [Color] {
        switch theme {
        case .classic:
            return [Color(hex: "FFD700"), Color(hex: "B8860B")]
        case .modern:
            return [Color(hex: "B0C4DE"), Color(hex: "4682B4")]
        case .minimal:
            return [Color(hex: "A9A9A9"), Color(hex: "696969")]
        case .military:
            return [Color(hex: "8FBC8F"), Color(hex: "556B2F")]
        }
    }
}

// Helper extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
