//
//  CeletialViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CelestialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource {
    let reusableCellIdentifier = "CelestialDetailCell"
    
    var celestialProperties = [[String]]()
    var orbitProperties = [[String]]()
    var atmosphereProperties = [[String]]()
    
    var celestial: Celestial!
    @IBOutlet weak var tableView: UITableView!
    
    func prepare(celestial celestial: Celestial) {
        self.celestial = celestial
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        prepareCelestial()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func prepareCelestial() {
        if (celestial != nil) {
            self.navigationController?.topViewController!.title = celestial.name
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: celestial.color]
            
            celestialProperties.removeAll(keepCapacity: false)
            orbitProperties.removeAll(keepCapacity: false)
            atmosphereProperties.removeAll(keepCapacity: false)
            
            // Celestial properties
            celestialProperties.append([NSLocalizedString("EQUATORIAL_RADIUS", comment: ""), "\(Units.lengthUnit(celestial.radius, allowSubUnits: true))"])
            celestialProperties.append([NSLocalizedString("MASS", comment: ""), "\(celestial.mass) kg"])
            celestialProperties.append([NSLocalizedString("ROTATION_PERIOD", comment: ""), "\(Units.timeUnit(celestial.rotationPeriod))"])
            celestialProperties.append([NSLocalizedString("SURFACE_GRAVITY", comment: ""), "\(celestial.surfaceGravity.format(2)) m/s²"])
            celestialProperties.append([NSLocalizedString("ESCAPE_VELOCITY", comment: ""), "\(celestial.surfaceEscapeVelocity.format(1)) m/s"])
            celestialProperties.append([NSLocalizedString("SOI", comment: ""), "\(Units.lengthUnit(celestial.sphereOfInfluence, allowSubUnits: true))"])
            
            if celestial.canGeoSync {
                celestialProperties.append([NSLocalizedString("GEOSYNC_ORBIT", comment: ""), "\(Units.lengthUnit(celestial.synchronousOrbitAltitude, allowSubUnits: true))"])
            } else {
                celestialProperties.append([NSLocalizedString("GEOSYNC_ORBIT", comment: ""), NSLocalizedString("OUT_OF_SOI", comment: "")])
            }
            
            if celestial.canSemiGeoSync {
                celestialProperties.append([NSLocalizedString("SEMISYNC_ORBIT", comment: ""), "\(Units.lengthUnit(celestial.semiSynchronousOrbitAltitude, allowSubUnits: true))"])
            } else {
                celestialProperties.append([NSLocalizedString("SEMISYNC_ORBIT", comment: ""), NSLocalizedString("OUT_OF_SOI", comment: "")])
            }
            
            
            // Orbits properties
            if celestial.orbit != nil {
                orbitProperties.append([NSLocalizedString("ORBITAL_PERIOD", comment: ""), "\(Units.timeUnit(celestial.orbit!.orbitalPeriod))"])
                
                if celestial.orbit!.isCircular {
                    orbitProperties.append([NSLocalizedString("ORBITAL_RADIUS", comment: ""), "\(Units.lengthUnit(celestial.orbit!.a, allowSubUnits: true))"])
                } else {
                    orbitProperties.append([NSLocalizedString("SEMI_MAJOR_AXIS", comment: ""), "\(Units.lengthUnit(celestial.orbit!.a, allowSubUnits: true))"])
                    orbitProperties.append([NSLocalizedString("APOAPSIS", comment: ""), "\(Units.lengthUnit(celestial.orbit!.apoapsis, allowSubUnits: true))"])
                    orbitProperties.append([NSLocalizedString("PERIAPSIS", comment: ""), "\(Units.lengthUnit(celestial.orbit!.periapsis, allowSubUnits: true))"])
                }
                
                orbitProperties.append([NSLocalizedString("ECCENTRICITY", comment: ""), "\(celestial.orbit!.eccentricity.format(2))"])
                if !celestial.orbit!.isCircular {
                    orbitProperties.append([NSLocalizedString("ARGUMENT_PERIAPSIS", comment: ""), "\(celestial.orbit!.periapsisArgument.format(1))°"])
                }
                
                orbitProperties.append([NSLocalizedString("INCLINATION", comment: ""), "\(celestial.orbit!.inclination)°"])
                if celestial.orbit!.inclination != 0 {
                    orbitProperties.append([NSLocalizedString("LONGITUDE_ASCENDING_NODE", comment: ""), "\(celestial.orbit!.ascendingNodeLongitude.format(1))°"])
                }
                
                orbitProperties.append([NSLocalizedString("MEAN_ANOMALY", comment: ""), "\(celestial.orbit!.meanAnomaly.format(2)) rad"])
            }
            
            // Atmosphere properties
            if celestial.atmosphere != nil {
                atmosphereProperties.append([NSLocalizedString("ATMO_PRESSURE", comment: ""), "\(Units.pressureUnit(celestial.atmosphere!.surfacePressure))"])
                atmosphereProperties.append([NSLocalizedString("ATMO_LIMIT", comment: ""), "\(Units.lengthUnit(celestial.atmosphere!.limitAltitude, allowSubUnits: true))"])
                atmosphereProperties.append([NSLocalizedString("TEMPERATURE_MIN", comment: ""), "\( Units.temperatureUnit(celsius: celestial.atmosphere!.temperatureMin) )"])
                atmosphereProperties.append([NSLocalizedString("TEMPERATURE_MAX", comment: ""), "\( Units.temperatureUnit(celsius: celestial.atmosphere!.temperatureMax) )"])
                atmosphereProperties.append([NSLocalizedString("HAS_OXYGEN", comment: ""), celestial.atmosphere!.hasOxygen ? NSLocalizedString("YES", comment: "") : NSLocalizedString("NO", comment: "")])
            }
        }
    }
    
    
    // MARK: TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if celestial == nil {
            return 0
        }
        
        return (celestial.orbit != nil && celestial.atmosphere != nil) ? 3 : (celestial.orbit != nil) ? 2 : 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("CELESTIAL_PROPERTIES", comment: "")
        case 1:
            return celestial.orbit != nil ? NSLocalizedString("ORBIT_PROPERTIES", comment: "") : NSLocalizedString("ATMO_PROPERTIES", comment: "")
        case 2:
            return NSLocalizedString("ATMO_PROPERTIES", comment: "")
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return celestialProperties.count
        case 1:
            return orbitProperties.count
        case 2:
            return atmosphereProperties.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath) 
        
        let row = indexPath.row
        
        var key = ""
        var value = ""
        
        switch indexPath.section {
        case 0:
            key = celestialProperties[row][0]
            value = celestialProperties[row][1]
        case 1:
            key = orbitProperties[row][0]
            value = orbitProperties[row][1]
        case 2:
            key = atmosphereProperties[row][0]
            value = atmosphereProperties[row][1]
        default:
            key = "?"
            value = "?"
        }
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        
        return cell
    }
    
    // MARK: DZNEmptyDataSetSource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("NO_PLANET", comment: "")
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("CHOOSE_A_PLANET", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
