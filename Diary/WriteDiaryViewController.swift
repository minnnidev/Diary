//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 김민 on 2022/06/29.
//

import UIKit

class WriteDiaryViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? //datePicker에서 선택된 date를 저장해 주는 프로퍼티
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureContentsTextView()
        configureDatePicker()
    }
    
    //함수 - 내용 textView 테두리 구현 private으로 하는 이유?
    private func configureContentsTextView() {
        //red, green, blue 값에는 0.0~1.0 사이 값 넣어줘야 함
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        //layor 관련은 borderColor가 아닌 cgColor로 설정해야 함
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5 //테두리 너비
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        //UIControl 객체가 이벤트에 응답하는 방식을 설정 - target, action: 이벤트가 발생하였을 때 그에 응답하여 호출된 메서드(Selector)
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)) , for: .valueChanged)
        self.dateTextField.inputView = self.datePicker //키보드가 아닌 date picker이 나옴
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
    }
    
    //datePicker나 키보드가 나왔을 때 다른 곳을 터치하면 사라지도록 구현
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //유저가 화면을 누르면 호출
    }
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter() //데이터 타입의 형태를 사람이 읽을 수 있는 형태로
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formmater.string(from: datePicker.date)
    }
    
}
