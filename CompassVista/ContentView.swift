//
//  ContentView.swift
//  CompassVista
//
//  Created by Sitharaj Seenivasan on 17/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CompassView()
            .preferredColorScheme(.light) // Will be controlled by theme settings
    }
}

#Preview {
    ContentView()
}
