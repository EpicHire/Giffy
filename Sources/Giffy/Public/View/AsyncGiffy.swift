//
//  AsyncGiffy.swift
//  
//
//  Created by Tomas Martins on 27/04/23.
//

import os
import SwiftUI

/// A SwiftUI view that can display an animted GIF image from a remote URL. To present an GIF image that is stored locally, use the ``Giffy`` component instead.
public struct AsyncGiffy<Content: View>: View {
    
    let url: URL
    @ViewBuilder
    private let content: (AsyncGiffyPhase) -> Content
    
    /// Creates a view that presents an animted GIF image from a remote URL to be displayed in phases
    /// - Parameters:
    ///   - url: The remote URL of an animated GIF image to be displayed
    ///   - content: A closure that takes the current phase as an input and returns the view to be displayed in each phase
    public init(
        url: URL,
        @ViewBuilder content: @escaping (AsyncGiffyPhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    private let logger = Logger(
        subsystem: "Giffy",
        category: String(describing: AsyncGiffy.self)
    )
    
    @State private var phase: AsyncGiffyPhase = .loading
    
    public var body: some View {
        content(phase)
            .onAppear {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let view = Giffy(imageData: data)
                        self.phase = .success(view)
                    } catch {
                        logger.warning("Could not get data for GIF file located at \(url.absoluteString)")
                        self.phase = .error
                    }
                }
            }
    }
}

#Preview {
    AsyncGiffy(url: .init(string: "https://epic-hire-qa.s3.amazonaws.com/conversations/2562/media/a38b0747-b271-4ca0-8942-fc3eee398635.gif")!) { phase in
        switch phase {
        case .loading:
            Text("Loading...")
        case .error:
            Text("Error")
        case .success(let gif):
            gif
                .contentMode(.scaleAspectFill)
        }
    }
    .frame(width: 300, height: 300)
}
