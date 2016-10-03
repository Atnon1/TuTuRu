//
//  scheduleViewController.swift
//  SchedulTuTu
//
//  Created by Admin on 29.09.16.
//  Copyright © 2016 MakeY. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
   
   
    @IBOutlet weak var stationFrom: UITableViewCell!
    @IBOutlet weak var stationTo: UITableViewCell!
    @IBOutlet weak var dateTextField: UITextField!
    
    var race = Race()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationTo.textLabel?.text = "Выберите станцию прибытия"
        stationTo.textLabel?.textColor = UIColor.lightGrayColor()
        stationFrom.textLabel?.text = "Выберите станцию отправления"
        stationFrom.textLabel?.textColor = UIColor.lightGrayColor()
        
        //создаем toolbar для datePicker
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.Default
        let todayBtn = UIBarButtonItem(title: "Сегодня", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ScheduleViewController.tappedToolBarBtn))
        let doneBtn = UIBarButtonItem(/*barButtonSystemItem: UIBarButtonSystemItem.Done,*/ title:"Готово", style: UIBarButtonItemStyle.Plain,  target: self, action: #selector(ScheduleViewController.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clearColor()
        label.text = "Выберите число:"
        label.textAlignment = NSTextAlignment.Center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,doneBtn], animated: true)
        dateTextField.inputAccessoryView = toolBar
    }
    
    //при нажатии на "Готово"
    func donePressed(sender: UIBarButtonItem) {
        dateTextField.resignFirstResponder()
    }
    
    //описываем действие кнопки Сегодня на datepicker
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateformatter.locale = NSLocale(localeIdentifier: "ru_RU")
        dateTextField.text = dateformatter.stringFromDate(NSDate())
        race.date = NSDate()
        dateTextField.resignFirstResponder()
    }


    //поведение при редактировании dateTextField, создание datepicker
    
    
    @IBAction func editingDate(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.locale = NSLocale(localeIdentifier: "ru_RU")
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(ScheduleViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        datePickerView.minimumDate = NSDate()
        if let curentDate = race.date { 
            datePickerView.date = curentDate
        } else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
            dateTextField.text = dateFormatter.stringFromDate(NSDate())
            race.date = NSDate()
        }
    }
    
    //передача значения datePicker
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
        race.date = sender.date
    }
    
    // segue для получения данных о выборе станции
    @IBAction func selectedStation(segue:UIStoryboardSegue) {
        if let stationsTableViewController = segue.sourceViewController as? StationsTableViewController,
            selectedStation = stationsTableViewController.selectedStation {
            //получаем данные для станции отправления
            if stationsTableViewController.direction == "citiesFrom"{
                race.stationFrom = selectedStation
                stationFrom.textLabel?.text = selectedStation.name
                stationFrom.accessoryType = .DetailButton
            } else if stationsTableViewController.direction == "citiesTo" {  //для станций прибытия
                race.stationTo = selectedStation
                stationTo.textLabel?.text = selectedStation.name
                stationTo.accessoryType = .DetailButton
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = "К поездам"
        //задаем данные для работы в StationsTableViewController
        if segue.identifier == "ChooseStationFrom" {
            if let stationsTableViewController = segue.destinationViewController as? StationsTableViewController {
                stationsTableViewController.selectedStation = race.stationFrom //устанавливаем уже выбранную станцию откуда
                stationsTableViewController.direction = "citiesFrom"
                stationsTableViewController.title = "Станции отправления"
            }
        }
        
        if segue.identifier == "ChooseStationTo" {
            if let stationsTableViewController = segue.destinationViewController as? StationsTableViewController {
                stationsTableViewController.selectedStation = race.stationTo //устанавливаем уже выбранную станцию откуда
                stationsTableViewController.direction = "citiesTo"
                stationsTableViewController.title = "Станции прибытия"
            }
        }
        
        //заполнение экрана stationDetail scene (информация о станции)
        if segue.identifier == "ShowDetailsTo" || segue.identifier == "ShowDetailsFrom" {
            if let vc = segue.destinationViewController as? StationDetailsViewController {
                let station: Station
                if segue.identifier == "ShowDetailsTo" {
                    station = race.stationTo!
                } else {
                    station = race.stationFrom!
                }
                navigationItem.title = "Назад"
                vc.title = station.name
                vc.country = station.country
                vc.name = station.name
                vc.city = station.city
                vc.district = station.district
                vc.latitude = station.latitude
                vc.longitude = station.longitude
            }
        }
    }
    

    //делаем активными textfield при нажатии на ячейку даты
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            dateTextField.becomeFirstResponder()
        }
    }
    
}

