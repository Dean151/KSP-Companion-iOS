//
//  CeletialViewController.swift
//  KSPCompanion
//
//  Created by Thomas Durand on 30/05/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CelestialViewController: UITableViewController, DZNEmptyDataSetSource {
    let reusableCellIdentifier = "CelestialDetailCell"
    
    var celestialProperties = [[String]]()
    var orbitProperties = [[String]]()
    var atmosphereProperties = [[String]]()
    
    var celestial: Celestial?
    
    func prepare(celestial: Celestial) {
        self.celestial = celestial
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.allowsSelection = false
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Adding sections
        prepareCelestial()
        self.tableView.reloadData()
    }
    
    func prepareCelestial() {
        guard let celestial = self.celestial else { return }
        
        navigationItem.title = celestial.name
        
        if let navController = self.navigationController {
            // When split view mode
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: celestial.color]
        }
        
        celestialProperties.removeAll(keepingCapacity: false)
        orbitProperties.removeAll(keepingCapacity: false)
        atmosphereProperties.removeAll(keepingCapacity: false)
        
        // Celestial properties
        celestialProperties.append([NSLocalizedString("EQUATORIAL_RADIUS", comment: ""),
            "\(Units.lengthUnit(celestial.radius, allowSubUnits: true))",
            "\(celestial.radius)"])
        celestialProperties.append([NSLocalizedString("MASS", comment: ""),
            "\(celestial.mass) kg",
            "\(celestial.mass)"])
        celestialProperties.append([NSLocalizedString("ROTATION_PERIOD", comment: ""),
            "\(Units.timeUnit(celestial.rotationPeriod))",
            "\(celestial.rotationPeriod)"])
        celestialProperties.append([NSLocalizedString("SURFACE_GRAVITY", comment: ""),
            "\(celestial.surfaceGravity.format(2)) m/s²",
            "\(celestial.surfaceGravity)"])
        celestialProperties.append([NSLocalizedString("ESCAPE_VELOCITY", comment: ""),
            "\(celestial.surfaceEscapeVelocity.format(1)) m/s",
            "\(celestial.surfaceEscapeVelocity)"])
        celestialProperties.append([NSLocalizedString("SOI", comment: ""),
            "\(Units.lengthUnit(celestial.sphereOfInfluence, allowSubUnits: true))",
            "\(celestial.sphereOfInfluence)"])
        
        if celestial.canGeoSync {
            celestialProperties.append([NSLocalizedString("GEOSYNC_ORBIT", comment: ""),
                "\(Units.lengthUnit(celestial.synchronousOrbitAltitude, allowSubUnits: true))",
                "\(celestial.synchronousOrbitAltitude)"])
        } else {
            celestialProperties.append([NSLocalizedString("GEOSYNC_ORBIT", comment: ""),
                NSLocalizedString("OUT_OF_SOI", comment: ""),
                ""])
        }
        
        if celestial.canSemiGeoSync {
            celestialProperties.append([NSLocalizedString("SEMISYNC_ORBIT", comment: ""),
                "\(Units.lengthUnit(celestial.semiSynchronousOrbitAltitude, allowSubUnits: true))",
                "\(celestial.semiSynchronousOrbitAltitude)"])
        } else {
            celestialProperties.append([NSLocalizedString("SEMISYNC_ORBIT", comment: ""),
                NSLocalizedString("OUT_OF_SOI", comment: ""),
                ""])
        }
        
        
        // Orbits properties
        if celestial.orbit != nil {
            orbitProperties.append([NSLocalizedString("ORBITAL_PERIOD", comment: ""),
                "\(Units.timeUnit(celestial.orbit!.orbitalPeriod))",
                "\(celestial.orbit!.orbitalPeriod)"])
            
            if celestial.orbit!.isCircular {
                orbitProperties.append([NSLocalizedString("ORBITAL_RADIUS", comment: ""),
                    "\(Units.lengthUnit(celestial.orbit!.a, allowSubUnits: true))",
                    "\(celestial.orbit!.a)"])
            } else {
                orbitProperties.append([NSLocalizedString("SEMI_MAJOR_AXIS", comment: ""),
                    "\(Units.lengthUnit(celestial.orbit!.a, allowSubUnits: true))",
                    "\(celestial.orbit!.a)"])
                orbitProperties.append([NSLocalizedString("APOAPSIS", comment: ""),
                    "\(Units.lengthUnit(celestial.orbit!.apoapsis, allowSubUnits: true))",
                    "\(celestial.orbit!.apoapsis)"])
                orbitProperties.append([NSLocalizedString("PERIAPSIS", comment: ""),
                    "\(Units.lengthUnit(celestial.orbit!.periapsis, allowSubUnits: true))",
                    "\(celestial.orbit!.periapsis)"])
            }
            
            orbitProperties.append([NSLocalizedString("ECCENTRICITY", comment: ""),
                "\(celestial.orbit!.eccentricity.format(2))",
                "\(celestial.orbit!.eccentricity)"])
            if !celestial.orbit!.isCircular {
                orbitProperties.append([NSLocalizedString("ARGUMENT_PERIAPSIS", comment: ""),
                    "\(celestial.orbit!.periapsisArgument.format(1))°",
                    "\(celestial.orbit!.periapsisArgument)"])
            }
            
            orbitProperties.append([NSLocalizedString("INCLINATION", comment: ""),
                "\(celestial.orbit!.inclination)°",
                "\(celestial.orbit!.inclination)"])
            if celestial.orbit!.inclination != 0 {
                orbitProperties.append([NSLocalizedString("LONGITUDE_ASCENDING_NODE", comment: ""),
                    "\(celestial.orbit!.ascendingNodeLongitude.format(1))°",
                    "\(celestial.orbit!.ascendingNodeLongitude)"])
            }
            
            orbitProperties.append([NSLocalizedString("MEAN_ANOMALY", comment: ""),
                "\(celestial.orbit!.meanAnomaly.format(2)) rad",
                "\(celestial.orbit!.meanAnomaly)"])
        }
        
        // Atmosphere properties
        if celestial.atmosphere != nil {
            atmosphereProperties.append([NSLocalizedString("ATMO_PRESSURE", comment: ""),
                "\(Units.pressureUnit(celestial.atmosphere!.surfacePressure))",
                "\(celestial.atmosphere!.surfacePressure)"])
            atmosphereProperties.append([NSLocalizedString("ATMO_LIMIT", comment: ""),
                "\(Units.lengthUnit(celestial.atmosphere!.limitAltitude, allowSubUnits: true))",
                "\(celestial.atmosphere!.limitAltitude)"])
            atmosphereProperties.append([NSLocalizedString("TEMPERATURE_MIN", comment: ""),
                "\( Units.temperatureUnit(celsius: celestial.atmosphere!.temperatureMin) )",
                "\(celestial.atmosphere!.temperatureMin)"])
            atmosphereProperties.append([NSLocalizedString("TEMPERATURE_MAX", comment: ""),
                "\( Units.temperatureUnit(celsius: celestial.atmosphere!.temperatureMax) )",
                "\(celestial.atmosphere!.temperatureMax)"])
            atmosphereProperties.append([NSLocalizedString("HAS_OXYGEN", comment: ""),
                celestial.atmosphere!.hasOxygen ? NSLocalizedString("YES", comment: "") : NSLocalizedString("NO", comment: ""),
                celestial.atmosphere!.hasOxygen ? NSLocalizedString("YES", comment: "") : NSLocalizedString("NO", comment: "")])
        }
    }
    
    func getValuesAtIndexPath(_ indexPath: IndexPath) -> (title: String, detail: String, value: String) {
        let row = indexPath.row
        
        switch indexPath.section {
        case 0:
            return (celestialProperties[row][0], celestialProperties[row][1], celestialProperties[row][2])
        case 1:
            return (orbitProperties[row][0], orbitProperties[row][1], orbitProperties[row][2])
        case 2:
            return (atmosphereProperties[row][0], atmosphereProperties[row][1], atmosphereProperties[row][2])
        default:
            return ("", "", "")
        }
    }
    
    
    // MARK: TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let celestial = self.celestial else { return 0 }
        return (celestial.orbit != nil && celestial.atmosphere != nil) ? 3 : (celestial.orbit != nil) ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let celestial = self.celestial else { return "" }
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let celestial = self.celestial else { return 0 }
        
        switch section {
        case 0:
            return celestialProperties.count
        case 1:
            return celestial.orbit != nil ? orbitProperties.count : atmosphereProperties.count
        case 2:
            return atmosphereProperties.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier, for: indexPath) 
        
        let values = self.getValuesAtIndexPath(indexPath)
        
        cell.textLabel?.text = values.title
        cell.detailTextLabel?.text = values.detail
        
        return cell
    }
    
    // MARK: Actions feature in tableview
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == #selector(copy(_:)) {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.getValuesAtIndexPath(indexPath).value
        }
    }
    
    // MARK: TableView custom actions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let celestial = self.celestial else { return false }
        
        if indexPath.section != 0 || (indexPath.row != 6 && indexPath.row != 7) {
            return false // No action for every row
        }
        
        if (indexPath.row == 6 && !celestial.canGeoSync) || (indexPath.row == 7 && !celestial.canSemiGeoSync) {
            return false // No action if out of SOI
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Distribute action
        let distributeAction = UITableViewRowAction(style: .default, title: NSLocalizedString("DISTRIBUTE", comment: "") , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.setDistributionAtIndexPath(indexPath)
        })
        
        // Custom colors
        distributeAction.backgroundColor = UIColor(hexString: "#34AADC")
        
        return [distributeAction]
    }
    
    func setDistributionAtIndexPath(_ indexPath: IndexPath) {
        self.perform(#selector(CelestialViewController.closeEditActions), with: nil, afterDelay: 0.1)
        
        guard let celestial = self.celestial else { return }
        
        // Looking for the right controller
        guard let tabBarController = self.tabBarController as? KSPTabBarController else { print("No Tab Bar"); return }
        guard let splitVC = tabBarController.viewControllers?[2] as? KSPSplitViewController else { print("No Split view controller"); return }
        guard let navVC = splitVC.viewControllers.first as? UINavigationController else { print("No nav controller"); return }
        guard let distributionVC = navVC.viewControllers.first as? DistributionFormViewController else { print("No distribution controller"); return }
        
        // We reload celestial in the case the system was changed just before using a shortcut
        distributionVC.loadCelestials()
        
        // Setting the destination
        distributionVC.form.setValues(["celestial": celestial])
        
        if indexPath.row == 6 {
            // Geosync
            distributionVC.form.setValues(["orbittype": distributionVC.orbitOptions[0]])
        }
        if indexPath.row == 7 {
            // Semi-Geosync
            distributionVC.form.setValues(["orbittype": distributionVC.orbitOptions[1]])
        }
        
        // Reloading the table
        distributionVC.tableView!.reloadData()
        
        // Changing the view
        tabBarController.shouldShow = 2
    }
    
    func closeEditActions() {
        self.tableView.setEditing(false, animated: true)
    }
    
    // MARK: DZNEmptyDataSetSource
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("NO_PLANET", comment: "")
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSLocalizedString("CHOOSE_A_PLANET", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
