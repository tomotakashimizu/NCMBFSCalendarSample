//
//  ViewController.swift
//  NCMBFSCalendarSample
//
//  Created by 清水智貴 on 2021/07/04.
//

import UIKit
import FSCalendar
import NCMB

class ViewController: UIViewController {
    
    //スケジュールモデルをインスタンス化(設計図を実体化)
    var schedule: Schedule!
    //日付をkey,schduleをvalueにした辞書型の配列を定義
    var schedules = [String: Schedule]()
    
    //タップした日付を入れる変数(初期値は今日)
    var selectedDate = Date()
    //予定が入っている日付を格納する配列
    var scheduledDates = [String]()
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FSCalendarの関数をViewControllerに委任する
        calendar.delegate = self
        //ViewControllerからFSCalendarに値を渡す
        calendar.dataSource = self
        //ViewControllerからTavleViewに値を渡す
        scheduleTableView.dataSource = self
        //TableViewの不要な線を消す
        scheduleTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    //segueを用いた値渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segueがtoAddScheduleだったら
        if segue.identifier == "toAddSchedule" {
            // 遷移先ViewCntrollerを取得
            let addScheduleVC = segue.destination as! AddScheduleViewController
            // 値渡し
            addScheduleVC.passedDate = selectedDate
        }
    }
}

// MARK:- FSCalendarに関する処理
extension ViewController:FSCalendarDelegate,FSCalendarDataSource{
    //日付をタップした際に呼ばれる関数
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        //tableViewの更新
        loadData()
    }
    
    //日付の下に点をつける関数
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = dateToString(date: date, format: DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))!)
        if self.scheduledDates.contains(dateString) {
            return schedules[dateString]!.eventCount
        }
        return 0
    }
    
    //カレンダーの月が変更した時に呼ばれる関数
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        selectedDate =  calendar.currentPage
        loadData()
    }
    
}

// MARK:- date型 ⇄ String型に変換する関数
extension ViewController{
    //date型→String型に変換する関数
    func dateToString(date:Date,format:String)->String{
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    //String型→date型に変換する関数
    func StringToDate(string:String,format:String)->Date{
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
        
    }
}

// MARK:- TableViewに関する処理
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateString = dateToString(date: selectedDate, format: DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))!)
        if self.scheduledDates.contains(dateString) {
            return schedules[dateString]?.eventCount ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let dateString = dateToString(date: selectedDate, format: DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))!)
        if self.scheduledDates.contains(dateString) {
            cell.textLabel?.text = schedules[dateString]?.events[indexPath.row]
            print(schedules[dateString]?.events[indexPath.row])
            return cell
        }
        return cell
    }
    
}

// MARK:- NCMBからデータを取ってきて tableView に表示する処理
extension ViewController{
    
    func loadData(){
        //NCMBから値を取得
        var query = NCMBQuery.getQuery(className: "Schedules")
        query.where(field: "userId", equalTo: UserDefaults.standard.object(forKey: "userId")!)
        query.findInBackground { result in
            switch result {
            case let .success(array):
                print("取得に成功しました 件数: \(array.count)")
                
                //ここでscheduleDates,schedulesを初期化しないと，loadData関数が呼ばれる度に要素が無限に増えてしまう
                self.scheduledDates = []
                self.schedules = [:]
                for resultObject in array {
                    let date: String? = resultObject["scheduledDate"]
                    let events: [String]? = resultObject["events"]
                    let eventCount = events!.count
                    //Scheduleモデルに値を格納して実体化する
                    let completeSchedule = Schedule(date: date!, events: events!, eventCount: eventCount)
                    self.scheduledDates.append(date!)
                    self.schedules.updateValue(completeSchedule, forKey: date!)
                }
                //calendarとTableViewを更新
                self.calendar.reloadData()
                self.scheduleTableView.reloadData()
                
            case let .failure(error):
                print("取得に失敗しました: \(error)")
            }
        }
    }
}

