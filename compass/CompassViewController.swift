//
//  CompassViewController.swift
//  compass
//
//  Created by Federico Zanetello on 05/04/2017.
//  Copyright © 2017 Kimchi Media. All rights reserved.
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {
  @IBOutlet weak var imageView: UIImageView!
  
  let locationDelegate = LocationDelegate()

    
  var yourLocation: CLLocation {
    get { return UserDefaults.standard.currentLocation }
    set { UserDefaults.standard.currentLocation = newValue }
  }

    private func getLocationBearing() -> CGFloat {
//        NSLog("current location: %@", self.yourLocation)
//        return CLLocation(latitude: 37.53654587476918, longitude: -122.28353817673623).bearingToLocationRadian(self.yourLocation)
        return CLLocation(latitude: 3, longitude: 3).bearingToLocationRadian(self.yourLocation)

    }
  
  let locationManager: CLLocationManager = {
    $0.requestWhenInUseAuthorization()
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.startUpdatingLocation()
    $0.startUpdatingHeading()
    return $0
  }(CLLocationManager())
  
  private func orientationAdjustment() -> CGFloat {
    let isFaceDown: Bool = {
      switch UIDevice.current.orientation {
      case .faceDown: return true
      default: return false
      }
    }()
    
    let adjAngle: CGFloat = {
      switch UIApplication.shared.statusBarOrientation {
      case .landscapeLeft:  return 90
      case .landscapeRight: return -90
      case .portrait, .unknown: return 0
      case .portraitUpsideDown: return isFaceDown ? 180 : -180
      }
    }()
    return adjAngle
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = locationDelegate
    
    locationDelegate.headingCallback = { newHeading in
      
      func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
        let heading: CGFloat = {
            let originalHeading = self.getLocationBearing() - newAngle.degreesToRadians
//            NSLog("Hedding changed to %7.3f, target is %7.3f, %10.6f", newAngle, self.getLocationBearing(), originalHeading)
          switch UIDevice.current.orientation {
          case .faceDown: return -originalHeading
          default: return originalHeading
          }
        }()
        
        return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
      }
      
      UIView.animate(withDuration: 0.9) {
        let angle = computeNewAngle(with: CGFloat(newHeading))
        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
      }
    }
  }
}
