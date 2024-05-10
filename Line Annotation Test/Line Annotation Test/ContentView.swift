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
    @State var annotations: [[CLLocationCoordinate2D]] = []

    var body: some View {
        ZStack {
            MLNMapViewWrapper(annotations: $annotations).edgesIgnoringSafeArea(.all)
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
        // Create 2 random coordinates
        var coordinates: [CLLocationCoordinate2D] = []
        for _ in 0...Int.random(in: 2...10) {
            let coordinate = CLLocationCoordinate2D(latitude:Double.random(in: 20 ... 25) , longitude: Double.random(in: -112 ... -107))
            coordinates.append(coordinate)
        }
        annotations.append(coordinates)
        print("Adding annotation")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(annotations: [])
    }
}

struct MLNMapViewWrapper: UIViewRepresentable {
    @Binding var annotations: [[CLLocationCoordinate2D]]

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
        print("updateUIView \(annotations.count) annotations")
        for coordinates in annotations {
            if context.coordinator.existingAnnotations.contains(where: { $0 == coordinates }) {
                continue
            }
            context.coordinator.existingAnnotations.append(coordinates)
            let lineAnnotation = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
            print("Adding annotations to map")
            mapView.addAnnotation(lineAnnotation)
        }
    }
    
    func makeCoordinator() -> MLNMapViewCoordinator {
        MLNMapViewCoordinator(self)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class MLNMapViewCoordinator: NSObject, MLNMapViewDelegate {
    var control: MLNMapViewWrapper
    var mapView: MLNMapView?
    var existingAnnotations: [[CLLocationCoordinate2D]] = [[]]

    init(_ control: MLNMapViewWrapper) {
        self.control = control
        super.init()
    }
    
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
