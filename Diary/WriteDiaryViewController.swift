//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 김민 on 2022/06/29.
//

import UIKit

//열거형
enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
    func DidSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? //datePicker에서 선택된 date를 저장해 주는 프로퍼티
    var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureinputField()
        self.configureEditMode() //수정화면을 눌렀을 때 화면 구성
        self.confirmButton.isEnabled = false //처음엔 등록 버튼이 비활성화되도록
    }
    
    //DiaryDetailViewController에서 수정 버튼을 눌렀을 때 받은 열거형 이용
    private func configureEditMode() {
            switch self.diaryEditorMode {
                case let .edit(_, diary):
                self.titleTextField.text = diary.title
                self.contentsTextView.text = diary.contents
                self.dateTextField.text = self.dateToString(date: diary.date)
                self.diaryDate = diary.date
                self.confirmButton.title  = "수정"
            default:
                break
        }
    }
    
    //Date->String 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    
    private func configureContentsTextView() {
        //red, green, blue 값에는 0.0~1.0 사이 값 넣어줘야 함
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        //layor 관련은 borderColor가 아닌 cgColor로 설정해야 함
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5 //테두리 너비
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    private func configureinputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChanged(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChanged(_:)), for: .editingChanged)
    }
    
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        //UIControl 객체가 이벤트에 응답하는 방식을 설정 - target, action: 이벤트가 발생하였을 때 그에 응답하여 호출된 메서드(Selector)
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)) , for: .valueChanged)
        self.dateTextField.inputView = self.datePicker //키보드가 아닌 date picker이 나옴
    }
    
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        //등록 버튼을 누르면 diary 객체를 정의함
        guard let title = self.titleTextField.text else {return}
        guard let contents = self.contentsTextView.text else {return}
        guard let date = self.diaryDate else {return}
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        
        switch self.diaryEditorMode {
        case .new: //일기를 등록하는 행위
            self.delegate?.DidSelectRegister(diary: diary)
        case let .edit(indexPath, _): //일기를 수정하는 행위, notification center 이용
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"), //알림을 식별하는 태그
                object: diary, //Noitfication을 통해 전달할 객체
                userInfo: [ //관련된 값
                    "indexPath.row": indexPath.row
                ]
            )
        }
        self.delegate?.DidSelectRegister(diary: diary)
        self.navigationController?.popViewController(animated: true) //일기장 화면으로 돌아감 
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
        self.dateTextField.sendActions(for: .editingChanged)
        //날짜가 변경될 때마다 editing changed
        //sendAction 안 쓰고 editingChanged valueChanged 쓰면 안 되나? -> 안 됨
        //datePicker가 UIControl을 상속받으므로 sendActions 필요
    }
    
    @objc private func titleTextFieldDidChanged(_ textField: UITextField) {
        self.validateInputField() //제목이 입력될 때마다 활성화 여부 검사
    }
    
    @objc private func dateTextFieldDidChanged(_ textField: UITextField) {
        self.validateInputField() //날짜가 변경될 때마다 등록 버튼 활성화 여부 검사
    }
 
    //등록 버튼의 활성화 여부 체크
    private func validateInputField() {
        //?? -> 닐 코얼레이싱
        //모든 input Field가 비어 있지 않으면 등록 버튼이 활성화되도록
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty && !(self.dateTextField.text?.isEmpty ?? true)
    }
}

extension WriteDiaryViewController: UITextViewDelegate {
    //텍스트 뷰에 텍스트가 입력될 때마다 호출
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
