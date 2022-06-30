//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 김민 on 2022/06/29.
//

import UIKit

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var diary: Diary? //일기를 전달받을 수 있는 프로퍼티 선언
    var indexPath: IndexPath?
    
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
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
    }
    

}
