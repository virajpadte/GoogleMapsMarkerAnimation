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
        
        //read data from the json file
        readDataFromJsonToCoordinateArray()
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

    func readDataFromJsonToCoordinateArray(){
        do {
            if let file = Bundle.main.url(forResource: "coordinates", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [Any] {
                    // json is an array
                    coordinateArr = NSArray(array: object)
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateMarker(marker: GMSMarker, oldCoor: CLLocationCoordinate2D, newCoor: CLLocationCoordinate2D, map: GMSMapView){
        //this function is used to update the marker
        //we will be doing the animation inside a explicitly mentioned animation transaction
        CATransaction.begin()
        CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            //is executed on completion of all the transcations
            print("Finished moving the marker now rotate")
        }
        //move marker to the new position
        marker.position = newCoor
        CATransaction.commit()
        
    }
    func initializeMap(){
        //put map on the view
        let camera = GMSCameraPosition.camera(withLatitude: 40.7416627, longitude: -74.0049708, zoom: 14)
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
        oldCoordinate = CLLocationCoordinate2DMake(40.7416627, -74.0049708)
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

