//
//  AddScheduleViewController.swift
//  NCMBFSCalendarSample
//
//  Created by 清水智貴 on 2021/07/06.
//

import UIKit
import NCMB

class AddScheduleViewController: UIViewController {
    
    let datePicker = UIDatePicker()
    //カレンダーで選択した日付を値渡しするための変数
    var passedDate = Date()
    
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var eventTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTextField.text = dateToString(date: passedDate, format: DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))!)
        createDatePicker()
    }
    
    // MARK:- スケジュールを追加する関数
    @IBAction func saveSchedule(){
        //スケジュールを記入
        //スケジュールが既にあれば追加/なければ新規作成するロジックを記載
        let query = NCMBQuery(className: "Schedules")
        query?.whereKey("userId", equalTo: UserDefaults.standard.object(forKey: "userId"))
        query?.whereKey("scheduledDate", equalTo: self.dateTextField.text!)
        query?.findObjectsInBackground({ (results, error) in
            if error != nil {
                print(error)
            } else if results?.isEmpty == false {
                //もし既に何か予定があれば，スケジュールに予定を追加
                let eventObject = results![0] as! NCMBObject
                var events = eventObject.object(forKey: "events") as! [String]
                events.append(self.eventTextField.text!)
                eventObject.setObject(events, forKey: "events")
                eventObject.saveInBackground { (error) in
                    if error != nil {
                        print(error)
                    }
                }
            } else {
                //なければ予定を作成
                let eventObject = NCMBObject(className: "Schedules")
                
                // 配列で保存することで検索コストを減らせる
                eventObject?.setObject([self.eventTextField.text!], forKey: "events")
                eventObject?.setObject(self.dateTextField.text!, forKey: "scheduledDate")
                eventObject?.setObject(UserDefaults.standard.object(forKey: "userId"), forKey: "userId")
                eventObject?.saveInBackground({ (error) in
                    if error != nil {
                        print(error)
                    }
                })
            }
        })
        // ①storyboardのインスタンス取得
        let storyboard: UIStoryboard = self.storyboard!
        // ②遷移先ViewControllerのインスタンス取得
        let nextView = storyboard.instantiateViewController(withIdentifier: "calendarStoryboard") as! ViewController
        nextView.loadView()
        nextView.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK:- DatePickerの処理
extension AddScheduleViewController{
    //DatePickerを用いる関数
    func createDatePicker(){
        let date = passedDate
        datePicker.date = date
        datePicker.datePickerMode = .date
        // textFieldのinputViewにdatepickerを設定
        dateTextField.inputView = datePicker
        // UIToolbarを設定
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // 完了ボタンを設定
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: self,action: "")
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: nil, action: #selector(doneClicked))
        // 完了ボタンを追加
        toolbar.setItems([spaceBarBtn, doneButton], animated: true)
        // Toolbarを追加
        dateTextField.inputAccessoryView = toolbar
    }
    
    //完了ボタンを押した際の処理
    @objc func doneClicked(){
        // textFieldに選択した日付を代入
        dateTextField.text = dateToString(date: datePicker.date, format: DateFormatter.dateFormat(fromTemplate: "ydMMM(EEE)", options: 0, locale: Locale(identifier: "ja_JP"))!)
        // キーボードを閉じる
        self.view.endEditing(true)
    }
}

// MARK:- date型 ⇄ String型に変換する関数
extension AddScheduleViewController{
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
