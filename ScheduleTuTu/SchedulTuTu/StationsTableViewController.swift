//
//  StationsTableViewController.swift
//  SchedulTuTu
//
//  Created by Admin on 28.09.16.
//  Copyright © 2016 MakeY. All rights reserved.
//

import UIKit

class StationsTableViewController: UITableViewController, UISearchResultsUpdating {
    var stationsData = [[Station]]() //данные из файла. 2д необходимо для формирование секций
    var filteredData = [[Station]]() //filtered stationsDaata
    var resultSearchController:UISearchController! //переменная отвечающая за поиск и фильтрацию
    var selectedStation = Station?() //необходима для передачи экземпляра выбранной станции в ScheduleVC и полученния уже выбранной
    var selectedStationIndex = NSIndexPath?() //для поиска станции в массивах
    var direction = String()
    var tempStation = Station()
    var tempArray = [Station]() //tempStation и tempArray служат для разбора файла и формирования stationsDate
    var filtered = false
    var cities = [String]() //для хранения названий секций город+страна

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //считываем данные из файла
        DataManager.getStationsDataFromFileWithSuccess{ (data) -> Void in
            do {
                let parsedObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments)
                if let directions = parsedObject as? NSDictionary {
                    if let cities = directions[self.direction] as? NSArray{
                        for city in cities {
                            if let currentCity = city as? NSDictionary {
                                if let stations = currentCity["stations"] as? NSArray {
                                    for station in stations{
                                        if let currentStation = station as? NSDictionary {
                                            if let country = currentStation["countryTitle"] as? String {
                                                self.tempStation.country = country
                                            }
                                            if let cityTitle = currentStation["cityTitle"] as? String {
                                                self.tempStation.city = cityTitle
                                            }
                                            if let district = currentStation["districtTitle"] as? String {
                                                self.tempStation.district = district
                                            }
                                            if let region = currentStation["regionTitle"] as? String {
                                                self.tempStation.region = region
                                            }
                                            if let id = currentStation["stationId"] as? Int {
                                                self.tempStation.id = id
                                            }
                                            if let name = currentStation["stationTitle"] as? String {
                                                self.tempStation.name = name
                                            }
                                            if let point = currentStation["point"] as? NSDictionary {
                                                if let longitude = point["longitude"] as? Double {
                                                    self.tempStation.longitude = longitude
                                                }
                                                if let latitude = point["latitude"] as? Double {
                                                    self.tempStation.latitude = latitude
                                                }
                                            }
                                            self.tempArray.append(self.tempStation)
                                            self.tempStation = Station()
                                        }
                                    }
                                    
                                }
                            }
                            self.tempArray.sortInPlace({$0.name < $1.name}) //сортируем станции одного города по названиям
                            self.stationsData.append(self.tempArray)
                            self.tempArray = []
                        }
                        self.stationsData.sortInPlace({$0[0].country < $1[0].country}) //сортируем секции по стране
                        self.stationsData.sortInPlace({if $0[0].country == $1[0].country {
                            return $0[0].city < $1[0].city
                        } else {
                            return $0[0].country < $1[0].country}
                            }) //сортируем секции по городам стран
                        self.setSelectedIndex()
                        //заполняем массив названий секций. Больше он не изменяется
                        for currentSection in self.stationsData {
                            self.cities.append("\(currentSection[0].city), \(currentSection[0].country)")
                        }
                        self.refreshTable()
                    }
                }
            } catch let error as NSError? {
                print("error: \(error?.localizedDescription)")
            }
        }
        //подготавливаем настройки для поиска и фильрации
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = true
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
        resultSearchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = resultSearchController.searchBar
    }
    
    //функция фильтрации
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count > 0 {
            filtered = true
            filteredData.removeAll(keepCapacity: false)
            for currentSection in stationsData {
                let searchPredicate = NSPredicate(format: "(name CONTAINS[c] %@) OR (city CONTAINS[c] %@) OR (country CONTAINS[c] %@)", searchController.searchBar.text!, searchController.searchBar.text!, searchController.searchBar.text!)   //поиск происходит как по названию станции, так и по городу и стране
                let array = (currentSection as NSArray).filteredArrayUsingPredicate(searchPredicate)
                if array.count > 0 {
                    filteredData.append(array as! [Station])
                } //условие нужно, чтобы не было пустых секций
            }
            refreshTable()
        }
        else {
            filtered = false
            filteredData.removeAll(keepCapacity: false)
            filteredData = stationsData
            refreshTable()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //при нажатии ячейки в таблице определеляем в каком массиве искать сущность станции (filtered) и передаем ее в scheduleVC
        if segue.identifier == "SaveSelectedStation" {
            if let cell = sender as? UITableViewCell {
                if let indexPath = tableView.indexPathForCell(cell) {
                    selectedStationIndex = indexPath
                    if filtered {
                        selectedStation = filteredData[selectedStationIndex!.section][selectedStationIndex!.row]
                    } else {
                        selectedStation = stationsData[selectedStationIndex!.section][selectedStationIndex!.row]
                    }
                }
            }
        }
        
        //заполнение экрана stationDetail scene (информация о станции)
        if segue.identifier == "ShowDetails" {
            if let vc = segue.destinationViewController as? StationDetailsViewController {
                if let cell = sender as? UITableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell) {
                        navigationItem.title = "Назад"
                        resultSearchController.dismissViewControllerAnimated(true, completion: nil) //деактивируем searchBox
                        vc.title = cell.textLabel?.text
                        let station: Station
                        if filtered {
                            station = filteredData[indexPath.section][indexPath.row]
                        } else  {
                            station = stationsData[indexPath.section][indexPath.row]
                        }
                        vc.country = station.country
                        vc.name = station.name
                        vc.city = station.city
                        vc.district = station.district
                        vc.latitude = station.latitude
                        vc.longitude = station.longitude
                    }
                }
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if filtered {
            return filteredData.count
        } else {
            return stationsData.count
        }
        
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtered {
            return filteredData[section].count
        }
        else {
            return stationsData[section].count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let stationCell = tableView.dequeueReusableCellWithIdentifier("stationCell", forIndexPath: indexPath)
        let station: Station
        
        if filtered {
            station = filteredData[indexPath.section][indexPath.row]
        }
        else {
            station = stationsData[indexPath.section][indexPath.row]
        }
        
        stationCell.textLabel?.text = station.name
        
        //отмечаем цветом выбранную ранне
        if let index = selectedStationIndex {
            if station.id == stationsData[index.section][index.row].id {
                stationCell.textLabel?.textColor = UIColor.blueColor()
            } else {
                stationCell.textLabel?.textColor = UIColor.blackColor()
            }
        }
        return stationCell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //после нажатия, если у нас была выбрана станция то мы меняем  ее цвет
        if let index = selectedStationIndex {
            let stationCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index.row, inSection: index.section))
            stationCell?.textLabel?.textColor = UIColor.blackColor()
        }
        
        if filtered {
            selectedStation = filteredData[indexPath.section][indexPath.row]
        } else {
            selectedStation = stationsData[indexPath.section][indexPath.row]
        }
        setSelectedIndex()
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.blueColor()
    }
    
    //устанавливаем индекс выбранной ранне станции, сравнивая id в полученном масиве
    func setSelectedIndex() {
        var indexPath:NSIndexPath? = nil
        var index1 = 0
        while indexPath == nil && index1 < self.stationsData.count {
            if let selected = selectedStation {
                let id = selected.id
                if let result = self.stationsData[index1].indexOf({$0.id == id}) {
                    indexPath = NSIndexPath(forRow: result, inSection: index1)
                    selectedStationIndex = indexPath
                }
            }
            index1 += 1
        }
    }
    
    //при фильтрации получаем заголовки из сущностей секций
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filtered {
            return "\(filteredData[section][0].city), \(filteredData[section][0].country)"
        } else {
            return cities[section]
        }
    }
    
    
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
    }
    
    
    
}
