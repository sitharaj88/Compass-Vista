#!/bin/bash

# Script to add Info.plist settings to the Xcode project
PROJECT_FILE="/Users/admin/Documents/apps/CompassVista/CompassVista.xcodeproj/project.pbxproj"

# Backup the project file first
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"

# Add location usage description to project settings
sed -i '' 's/INFOPLIST_KEY_UILaunchScreen_Generation = YES;/INFOPLIST_KEY_UILaunchScreen_Generation = YES;\
\t\t\t\tINFOPLIST_KEY_NSLocationWhenInUseUsageDescription = "CompassVista needs access to your location to provide accurate compass readings and determine your coordinates.";/g' "$PROJECT_FILE"

# Add required device capabilities
sed -i '' 's/INFOPLIST_KEY_UILaunchScreen_Generation = YES;/INFOPLIST_KEY_UILaunchScreen_Generation = YES;\
\t\t\t\tINFOPLIST_KEY_UIRequiredDeviceCapabilities = "location-services magnetometer";/g' "$PROJECT_FILE"

# Add background location mode
sed -i '' 's/INFOPLIST_KEY_UILaunchScreen_Generation = YES;/INFOPLIST_KEY_UILaunchScreen_Generation = YES;\
\t\t\t\tINFOPLIST_KEY_UIBackgroundModes = location;/g' "$PROJECT_FILE"

echo "Project file updated with Info.plist settings"