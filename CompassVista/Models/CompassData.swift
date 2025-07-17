//
//  CompassData.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import Foundation
import CoreLocation

// MARK: - Models
struct CompassData {
    let heading: Double
    let trueHeading: Double
    let magneticHeading: Double
    let accuracy: Double
    let timestamp: Date
    
    var cardinalDirection: CardinalDirection {
        CardinalDirection.from(heading: heading)
    }
    
    var formattedHeading: String {
        String(format: "%.0f°", heading)
    }
}

enum CardinalDirection: String, CaseIterable {
    case north = "N"
    case northEast = "NE"
    case east = "E"
    case southEast = "SE"
    case south = "S"
    case southWest = "SW"
    case west = "W"
    case northWest = "NW"
    
    static func from(heading: Double) -> CardinalDirection {
        let normalizedHeading = heading.truncatingRemainder(dividingBy: 360)
        let adjustedHeading = normalizedHeading < 0 ? normalizedHeading + 360 : normalizedHeading
        
        switch adjustedHeading {
        case 0..<22.5, 337.5..<360:
            return .north
        case 22.5..<67.5:
            return .northEast
        case 67.5..<112.5:
            return .east
        case 112.5..<157.5:
            return .southEast
        case 157.5..<202.5:
            return .south
        case 202.5..<247.5:
            return .southWest
        case 247.5..<292.5:
            return .west
        case 292.5..<337.5:
            return .northWest
        default:
            return .north
        }
    }
}

struct LocationData {
    let coordinate: CLLocationCoordinate2D
    let altitude: Double
    let accuracy: Double
    let timestamp: Date
    
    var formattedCoordinate: String {
        String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
    
    var formattedAltitude: String {
        String(format: "%.1f m", altitude)
    }
}

enum CompassTheme: String, CaseIterable {
    case classic = "Classic"
    case modern = "Modern"
    case minimal = "Minimal"
    case military = "Military"
    case ocean = "Ocean"
    case sunset = "Sunset"
    
    var needleColor: String {
        switch self {
        case .classic: return "red"
        case .modern: return "blue"
        case .minimal: return "gray"
        case .military: return "green"
        case .ocean: return "teal"
        case .sunset: return "orange"
        }
    }
    
    var backgroundColor: String {
        switch self {
        case .classic: return "beige"
        case .modern: return "white"
        case .minimal: return "lightGray"
        case .military: return "darkGreen"
        case .ocean: return "lightTeal"
        case .sunset: return "sunsetGradient"
        }
    }
}

enum CalibrationState {
    case notStarted
    case inProgress
    case completed
    case failed
}
