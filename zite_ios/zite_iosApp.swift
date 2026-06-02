//
//  zite_iosApp.swift
//  zite_ios
//
//  Created by Amias on 01/06/2026.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant
import CoreLocation
import Combine

@main
struct zite_iosApp: App {
    @StateObject private var flutterHost = FlutterHostController()

    var body: some Scene {
        WindowGroup {
            Group {
                if flutterHost.isReady {
                    FlutterViewHost(engine: flutterHost.flutterEngine)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                        .task {
                            flutterHost.start()
                        }
                }
            }
        }
    }
}

@MainActor
final class FlutterHostController: ObservableObject {
    let flutterEngine = FlutterEngine(name: "my_flutter_engine")

    @Published private(set) var isReady = false
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        LocationAuthorizationPreflight.shared.prepare { [weak self] in
            guard let self else { return }

            self.flutterEngine.run(withEntrypoint: nil)
            GeneratedPluginRegistrant.register(with: self.flutterEngine)
            self.isReady = true
        }
    }
}

final class LocationAuthorizationPreflight: NSObject, CLLocationManagerDelegate {
    static let shared = LocationAuthorizationPreflight()

    private let locationManager = CLLocationManager()
    private var completion: (() -> Void)?
    private var didComplete = false

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func prepare(completion: @escaping () -> Void) {
        self.completion = completion

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
            finish()
        @unknown default:
            finish()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        finish()
    }

    private func finish() {
        guard !didComplete else { return }
        didComplete = true

        DispatchQueue.main.async { [completion] in
            completion?()
        }
        completion = nil
    }
}

struct FlutterViewHost: UIViewControllerRepresentable {
    let engine: FlutterEngine

    func makeUIViewController(context: Context) -> FlutterViewController {
        FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {}
}
