//
//  PlannerViewController.swift
//  CSE 335 Vacation App Project
//
//  Created by Paul Gellai on 10/12/18.
//  Copyright © 2018 Paul Gellai. All rights reserved.
// This view controller holds all events and flights in the view controller. It is designed to be a place where
// users can plan out their vacations using events and flights. Events have a title and a location. 

import UIKit

class PlannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ====== IBOUTLETS ====== //
    
    @IBOutlet weak var flightTB: UITableView!
    @IBOutlet weak var eventTB: UITableView!
    @IBOutlet weak var flightEditBtn: UIBarButtonItem!
    @IBOutlet weak var eventEditBtn: UIBarButtonItem!
    
    // ====== MODELS ====== //
    
    let flightModel = FlightModel()
    let eventModel = EventModel()
    
    // ====== INITIALIZER METHODS ===== //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*                                  /*
     ========= TABLEVIEW METHODS =========
     */                                  */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == flightTB {
            let cell = tableView.dequeueReusableCell(withIdentifier: "flightCell") as! FlightTableViewCell
            let flight = flightModel.get(at: indexPath.row)
            if flight.toDest {
                cell.flightLabel!.text = "Departure: \(flight.flyingFrom!)-\(flight.flyingTo!)"
                cell.dateLabel!.text = "\(flight.date!) \(flight.duration!)"
            } else {
                cell.flightLabel!.text = "Arrival: \(flight.flyingFrom!)-\(flight.flyingTo!)"
                cell.dateLabel!.text = "\(flight.date!) \(flight.duration!)"
            }
            
            cell.flightPic.image = UIImage(data: flight.image!)
            return cell
            // TODO: add attributes from flight to cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
            let event = eventModel.get(at: indexPath.row)
            cell.eventLabel!.text = "\(event.eventName!), \(event.eventLocation!)"
            cell.dateTimeLabel!.text = "\(event.eventDate!), \(event.eventTime!)"
            cell.eventPic.image = UIImage(data: event.image!)
            return cell
            // TODO: add attributes from event to cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == flightTB {
            return flightModel.getCount()
        } else {
            return eventModel.getCount()
        }
    }
    
    // ====== DELETE CELL ======
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == flightTB {
            if flightModel.getCount() <= 1 && tableView.isEditing {
                tableView.setEditing(false, animated: true)
            }
            flightModel.delete(i: indexPath.row)
            flightTB.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            if flightModel.getCount() == 0 {
                flightEditBtn.title = "Edit"
            }
        } else {
            if eventModel.getCount() <= 1 && tableView.isEditing {
                tableView.setEditing(false, animated: true)
            }
            eventModel.delete(i: indexPath.row)
            eventTB.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            if eventModel.getCount() == 0 {
                eventEditBtn.title = "Edit"
            }
        }
    }
    
    // ====== UNWIND SEGUE METHOD ====== //
    
    @IBAction func plannerUnwind(for unwindSegue: UIStoryboardSegue) {
        flightModel.updateFetchResults()
        eventModel.updateFetchResults()
        if flightTB != nil && eventTB != nil {
            flightTB.reloadData()
            eventTB.reloadData()
        }
    }
    
    // ====== PREPARE SEGUE ====== //
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "flightDetail" {
            let selectedIndex: IndexPath = flightTB.indexPath(for: sender as! UITableViewCell)!
            let uf = flightModel.get(at: selectedIndex.row)
            if uf.nameOfFlyingTo != nil && uf.nameOfFlyingFrom != nil {
                return true
            } else {
                self.present(buildOKAlertButton(title: "Please wait for data to be loaded."), animated: true)
                return false
            }
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flightDetail" || segue.identifier == "eventDetail" {
            if let viewController: FlightDetailViewController = segue.destination as? FlightDetailViewController {
                let selectedIndex: IndexPath = flightTB.indexPath(for: sender as! UITableViewCell)!
                let uf = flightModel.get(at: selectedIndex.row)
                viewController.dateStr = "Date: \(uf.date!)"
                if uf.toDest {
                    viewController.destOrArrivalStr = "Departure Flight"
                    viewController.toDest = true
                } else {
                    viewController.destOrArrivalStr = "Arrival Flight"
                    viewController.toDest = false
                }
                viewController.locationName = uf.nameOfFlyingFrom
                viewController.nameOfFlyingTo = uf.nameOfFlyingTo
                viewController.durationStr = "Duration: \(uf.duration!)"
                viewController.flightProviderStr = "Flight Provider: \(uf.gate!)"
                viewController.locationToDestStr = "\(uf.flyingFrom!)-\(uf.flyingTo!)"
                viewController.timeOfFlightStr = "Time: \(uf.flightTime!)"
                viewController.index = selectedIndex.row
                viewController.originalFlightProvider = uf.gate!
            } else if let viewController: EventDetailViewController = segue.destination as? EventDetailViewController {
                let selectedIndex: IndexPath = eventTB.indexPath(for: sender as! UITableViewCell)!
                let ue = eventModel.get(at: selectedIndex.row)
                viewController.dateStr = "Date: \(ue.eventDate!)"
                viewController.locationStr = "Location: \(ue.eventLocation!)"
                viewController.nameStr = ue.eventName
                viewController.timeStr = "Time: \(ue.eventTime!)"
                viewController.index = selectedIndex.row
                viewController.originalLocationStr = ue.eventLocation
            }
        }
    }
    
    /*                                  /*
     ========= IBACTION METHODS ==========
     */                                  */
    
    @IBAction func editFlights(_ sender: Any) {
        let bool = self.flightTB.isEditing
        if flightModel.getCount() != 0 {
            self.flightTB.setEditing(!bool, animated: true)
            if !bool {
                flightEditBtn.title = "Done"
            } else {
                flightEditBtn.title = "Edit"
            }
        }
        
    }
    
    @IBAction func editEvents(_ sender: Any) {
        let bool = self.eventTB.isEditing
        if eventModel.getCount() != 0 {
            self.eventTB.setEditing(!bool, animated: true)
            if !bool {
                eventEditBtn.title = "Done"
            } else {
                eventEditBtn.title = "Edit"
            }
        }
    }
    
    func buildOKAlertButton(title: String) -> UIAlertController {
        let t = title
        let alertController = UIAlertController(title: t, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alertController.addAction(okAction)
        return alertController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        flightModel.save()
        eventModel.save()
        flightTB.reloadData()
        eventTB.reloadData()
    }
}
