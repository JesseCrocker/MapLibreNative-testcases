//
//  ContentView.swift
//  Line Annotation Test
//
//  Created by Jesse Crocker on 5/10/24.
//

import SwiftUI
import MapLibre
import CoreLocation

struct ContentView: View {
    @State var mapView: MLNMapView?

    var body: some View {
        ZStack {
            MLNMapViewWrapper(getMapView: { mapview in
                DispatchQueue.main.async {
                    self.mapView = mapview
                }
            }).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button ("Add Annotation") {
                    addAnnotation()
                }
                Button ("Add Annotation every second") {
                    addAnnotationsWithTimer()
                }
            }
        }
    }

    func addAnnotationsWithTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            addAnnotation()
        }
    }
    
    func addAnnotation() {
        print("addAnnotation")
        guard let mapView else {
            print("mapView not set")
            return
        }
        // Create random coordinates
        var coordinates: [CLLocationCoordinate2D] = []
        for _ in 0...Int.random(in: 2...10) {
            let coordinate = CLLocationCoordinate2D(latitude:Double.random(in: 20 ... 25) , longitude: Double.random(in: -112 ... -107))
            coordinates.append(coordinate)
        }
        
        let lineAnnotation = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        print("Adding annotations to map")
        mapView.addAnnotation(lineAnnotation)
    }
}

#Preview {
    ContentView()
}

struct MLNMapViewWrapper: UIViewRepresentable {
    var getMapView: ((MLNMapView) -> Void)
    
    func makeUIView(context: Context) -> MLNMapView {
        print("makeUIView")
        // Build the style URL
        let styleURL = URL(string: "https://demotiles.maplibre.org/style.json")

        // Create the map view
        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.delegate = context.coordinator
        
        mapView.setCenter(
            CLLocationCoordinate2D(
                latitude: 23.16, longitude: -109.50), zoomLevel: 5, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        print("updateUIView")
        getMapView(mapView)
    }
    
    func makeCoordinator() -> MLNMapViewCoordinator {
        print("makeCoordinator")
        return MLNMapViewCoordinator()
    }
}

class MLNMapViewCoordinator: NSObject, MLNMapViewDelegate {
    var mapView: MLNMapView?
    
    func mapView(_: MLNMapView, strokeColorForShapeAnnotation annotation: MLNShape) -> UIColor {
        return .red
    }
    
    func mapView(_: MLNMapView, lineWidthForPolylineAnnotation annotation: MLNPolyline) -> CGFloat {
        return 5.0
    }
    
    func mapView(_: MLNMapView, alphaForShapeAnnotation annotation: MLNShape) -> CGFloat {
        return 1.0
    }
}
