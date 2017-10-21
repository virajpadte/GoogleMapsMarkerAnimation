//
//  ViewController.swift
//  GoogleMapsMarkerAnimation
//
//  Created by Viraj on 10/2/17.
//  Copyright © 2017 Viraj. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {

    var gdriverMarkers = [GMSMarker]()
    var mapView: GMSMapView!
    var coordinateArr = NSArray()
    var oldCoordinate: CLLocationCoordinate2D!
    var timer: Timer! = nil
    var counter: NSInteger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //read data from the csv file
        coordinateArr = csvToArrayOfCoordinates() as NSArray
        
        initializeMap()
        addMarker()
        print("Global markers: ", gdriverMarkers)
        
        
        //set counter value 0
        //
        counter = 0
        
        //start the timer, change the interval based on your requirement
        //
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.timerTriggered), userInfo: nil, repeats: true)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func csvToArrayOfCoordinates() -> [Dictionary<String, Any>] {
        var arrayOfDictCoordinateData = [Dictionary<String,AnyObject>]()
        var DictCoordinateData = Dictionary<String,AnyObject>()
        
        if let filePath = Bundle.main.path(forResource: "dataHeading", ofType: ".csv"){
            do {
                let contents = try String(contentsOfFile: filePath)
                //print("contents", contents)
                var locationDatarows  = contents.components(separatedBy: "\n").suffix(from: 2)
                locationDatarows.removeLast()
                for locationData in locationDatarows{
                    let locationDataComponents = locationData.components(separatedBy: ",")
                    DictCoordinateData["lat"] = Float(locationDataComponents[1]) as AnyObject
                    DictCoordinateData["long"] = Float(locationDataComponents[2]) as AnyObject
                    DictCoordinateData["heading"] = Float(locationDataComponents[3]) as AnyObject
                    arrayOfDictCoordinateData.append(DictCoordinateData)
                    
                }
            } catch {
                print("File Read Error for file")
            }
        }
        else{
            print("Couldn't find file path")
        }
        print(arrayOfDictCoordinateData)
        return arrayOfDictCoordinateData
    }
    
    
    func updateMarker(marker: GMSMarker, oldCoor: CLLocationCoordinate2D, newCoor: CLLocationCoordinate2D, map: GMSMapView){
        //this function is used to update the marker
        //we will be doing the animation inside a explicitly mentioned animation transaction
        let bearing = calcBearing(oldCoordinates: oldCoor, newCoordinates: newCoor)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
        marker.position = oldCoor; //this can be old position to make car movement to new position
        CATransaction.begin()
        CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            //is executed on completion of all the transcations
            marker.rotation = bearing; //found bearing value by calculation old and new Coordinates
        }
        //move marker to the new position
        marker.position = newCoor
        CATransaction.commit()
        let updatedCamera = GMSCameraUpdate.setTarget(marker.position)
        mapView.animate(with: updatedCamera)
        
    }
    
    func calcBearing(oldCoordinates: CLLocationCoordinate2D, newCoordinates: CLLocationCoordinate2D) -> Double{
        var radians = degreeToRadians(degrees: [oldCoordinates.latitude,oldCoordinates.longitude, newCoordinates.latitude, newCoordinates.longitude]);
        let degree = radiansToDegree(radians: atan2(sin(radians[3]-radians[1])*cos(radians[2]), cos(radians[0])*sin(radians[2])-sin(radians[0])*cos(radians[2])*cos(radians[3]-radians[1])));
        if (degree >= 0) {
            print("Calculated bearing degree >= 0: %0.6f",degree);
            return degree;
        }
        else {
            print("Calculated bearing degree >= 0: %0.6f",360+degree);
            return 360+degree;
        }
    }
 
    func degreeToRadians(degrees : [CLLocationDegrees]) -> [Double]{
        var radians = [Double]()
        for degree in degrees{
            radians.append(Double.pi * degree / 180.0);
        }
        return radians;
    }
    
    func radiansToDegree(radians: Double) -> CLLocationDegrees{
        return radians * 180.0 / Double.pi;
    }

    
    func initializeMap(){
        //put map on the view
        let camera = GMSCameraPosition.camera(withLatitude: 40.518390000, longitude: -105.080220000, zoom: 14)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //adding style to the map
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }else {
                NSLog("Unable to find style.json")
            }
        }catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        view = mapView
    }
    
    func addMarker(){
        // Creates a marker in the center of the map.
        //
        oldCoordinate = CLLocationCoordinate2DMake(40.518390000, -105.080220000)
        let driverMarker = GMSMarker()
        driverMarker.position = oldCoordinate
        //need to resize the image:
        //driverMarker.icon = resizeImage(image: UIImage(named: "car")!, newWidth:350)
        driverMarker.icon = UIImage(named: "car")
        driverMarker.map = mapView
        driverMarker.userData = "car1"
        gdriverMarkers.append(driverMarker)
    }
    
    @objc func timerTriggered() {
        if counter < coordinateArr.count {
            if let dict = coordinateArr[counter] as? Dictionary<String,AnyObject>{
                print("dict", dict)
                let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(dict["lat"] as! Float), CLLocationDegrees(dict["long"] as! Float))
                //let newBearing = dict["heading"] as! Float
                //moveMent.arCarMovement(driverMarker, withOldCoordinate: oldCoordinate, andNewCoordinate: newCoordinate, inMapview: mapView, withBearing: newBearing)
                print("updatedCoordinate", newCoordinate)
                updateMarker(marker: gdriverMarkers[0], oldCoor: oldCoordinate, newCoor: newCoordinate, map: mapView)
                oldCoordinate = newCoordinate
                //increase the value to get all index position from array
                counter = counter + 1
            }
        }
        else {
            timer.invalidate()
            timer = nil
        }
    }
}

