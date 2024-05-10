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
                Button ("Clear Annotations") {
                    clearAnnotations()
                }
                Button ("Add Point Annotation") {
                    addPointAnnotation()
                }
                Button ("Add Line Annotation") {
                    addLineAnnotation()
                }
                Button ("Add Line and Point Annotation") {
                    addPointAnnotation()
                    addLineAnnotation()
                }
                Button ("Add Annotation every second") {
                    addAnnotationsWithTimer()
                }
            }
        }
    }

    func clearAnnotations() {
        guard let mapView else {
            print("mapView not set")
            return
        }
        mapView.removeAnnotations(mapView.annotations ?? [])
    }
    
    func addAnnotationsWithTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            addLineAnnotation()
            addPointAnnotation()
        }
    }
    
    func addLineAnnotation() {
        print("addLineAnnotation")
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
        
        let lineAnnotation = AnnotationWithColor(coordinates: coordinates, count: UInt(coordinates.count))
        lineAnnotation.width = Double.random(in: 1...10)
        lineAnnotation.color = UIColor(hue: Double.random(in: 0.1...1.0), saturation: Double.random(in: 0.1...1.0), brightness: Double.random(in: 0.1...1.0), alpha: 1)
        lineAnnotation.alpha = Double.random(in: 0.1...1.0)
        print("Adding annotations to map")
        mapView.addAnnotation(lineAnnotation)
    }
    
    func addPointAnnotation() {
        print("addPointAnnotation")
        guard let mapView else {
            print("mapView not set")
            return
        }
        
        let pointAnnotation = MLNPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude:Double.random(in: 20 ... 25) , longitude: Double.random(in: -112 ... -107))
        mapView.addAnnotation(pointAnnotation)
    }
}

class AnnotationWithColor: MLNPolyline {
    var color: UIColor = .blue
    var width = 5.0
    var alpha = 1.0
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
        if let annotation = annotation as? AnnotationWithColor {
            return annotation.color
        } else {
            return .red
        }
    }
    
    func mapView(_: MLNMapView, lineWidthForPolylineAnnotation annotation: MLNPolyline) -> CGFloat {
        if let annotation = annotation as? AnnotationWithColor {
            return CGFloat(annotation.width)
        } else {
            return 3.0
        }
    }
    
    func mapView(_: MLNMapView, alphaForShapeAnnotation annotation: MLNShape) -> CGFloat {
        if let annotation = annotation as? AnnotationWithColor {
            return CGFloat(annotation.alpha)
        } else {
            return 1.0
        }
    }
}
