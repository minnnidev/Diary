//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 김민 on 2022/06/29.
//

import UIKit

protocol DiaryDetailViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var diary: Diary? //일기를 전달받을 수 있는 프로퍼티 선언
    var indexPath: IndexPath?
    var delegate: DiaryDetailViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }
    
    //Date->String 함수
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    

    @IBAction func tapEditButton(_ sender: UIButton) {
        //수정 버튼을 누르면 WriteDiaryViewController로 이동
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else {return}
        guard let indexPath = self.indexPath else {return}
        guard let diary = self.diary else {return}
        viewController.diaryEditorMode = .edit(indexPath, diary) //viewController(WriteDiaryViewController)에 열거형 전달
        NotificationCenter.default.addObserver(
            self, //어떤 인스턴스에서 옵저빙할 건지
            selector: #selector(editDiaryNotification(_:)), //notification을 탐지하다가 이벤트가 발생할 경우 selector에 정의된 함수 호출
            name: NSNotification.Name("editDiary"), //editDiary notification 관찰
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        //수정된 다이어리 객체를 전달을 받아서 뷰에 업데이트 시킴
        //post에서 보낸 수정된 다이어리를 받아오기
        guard let diary = notification.object as? Diary else {return}
        guard let low = notification.userInfo?["indexPath.row"] as? Int else {return}
        self.diary = diary
        self.configureView() //수정된 뷰 내용으로 일기 업데이트
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else {return}
        self.delegate?.didSelectDelete(indexPath: indexPath) //indexPath 전달
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit { //인스턴스가 메모리 해제되기 직전에 호출
        NotificationCenter.default.removeObserver(self) //관찰이 필요 없을 때는 옵저버 제거
    }

}
