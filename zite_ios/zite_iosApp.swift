//
//  zite_iosApp.swift
//  zite_ios
//
//  Created by Amias on 01/06/2026.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant

@main
struct zite_iosApp: App {
    
    // This creates the Flutter engine entry point
        let flutterEngine = FlutterEngine(name: "my_flutter_engine")

        init() {
            // Ensure the engine is running
                flutterEngine.run(withEntrypoint: nil)
                
                // Explicitly register plugins (this is vital for things like WebView/Camera)
                GeneratedPluginRegistrant.register(with: flutterEngine)
        }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            FlutterViewHost(engine: flutterEngine).ignoresSafeArea()
        }
    }
}

// This is the code that fixes the "Cannot find FlutterViewHost" error.
// It bridges the Flutter UI to your native SwiftUI layout.
struct FlutterViewHost: UIViewControllerRepresentable {
    let engine: FlutterEngine

    func makeUIViewController(context: Context) -> FlutterViewController {
        return FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {}
}
