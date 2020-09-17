//
//  PlayingViewController.swift
//  Flick+
//
//  Created by ikei6256 on 2020/05/25.
//  Copyright © 2020 ikei_org. All rights reserved.
//

import UIKit

class PlayingViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBAction func resetButtonAction(_ sender: Any) {
        timer?.invalidate()

        // アラート生成
        let alertController = UIAlertController(title: "やり直しますか？", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.score = 0
            self.score_tmp = 0
            self.setText()
            self.countDownLabel.text = "残り \(self.TIMELIMIT)"
            self.startingTimer()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            self.countDownTimer()
            self.inputField.isEnabled = true
            self.inputField.becomeFirstResponder()
        })
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        inputField.isEnabled = false
        present(alertController, animated: true, completion: nil)
    }

    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBAction func pauseButtonAction(_ sender: Any) {
        timer?.invalidate()

        // アラート生成
        let alertController = UIAlertController(title: "ポーズ", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "スタート", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.countDownTimer()
            self.inputField.isEnabled = true
            self.inputField.becomeFirstResponder()
        })
        alertController.addAction(defaultAction)
        inputField.isEnabled = false
        present(alertController, animated: true, completion: nil)
    }

    struct JsonData: Codable {
        var difficulty: String
        var texts: [String]
    }

    // 難易度 0:やさしい 1:ふつう 2:むずかしい
    var difficultyNum:Int = 0
    var textData:[String] = []
    var checkedNum:Int = 0

    var timer:Timer?
    let TIMELIMIT:Int = 60
    var count = 0 // タイマー用のカウンタ
    var score = 0 // スコア
    var score_tmp = 0 // 入力中と一致する分の仮スコア
    var inputCount = 0 // 入力中の文字列

    override func viewDidLoad() {
        super.viewDidLoad()

        score = 0
        difficultyLabel.text = ViewController().difficultyList[difficultyNum]

        inputField.isEnabled = false
        pauseButton.isEnabled = false
        resetButton.isEnabled = false
        self.inputField.delegate = self

        setText()
        startingTimer()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResult" {
            let nextView = segue.destination as! ResultViewController
            nextView.score = self.score
            nextView.difficultyNum = self.difficultyNum
        }
    }

    /* テキスト入力時の処理 */
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if(textField.text == textLabel.text){
            // スコア更新
            score += textLabel.text!.count
            scoreLabel.text = "\(score)pts"
            score_tmp = 0
            inputField.text = ""

            // 新しいテキスト
            if(!textData.isEmpty){
                textLabel.text = textData.remove(at: 0)
            } else {
                // 空だったら終了
                timer?.invalidate()
                finishPlaying()
                return
            }

            return
        }

        // 入力したテキストと問題テキストの前方一致する部分を調べる
        inputCount = textField.text!.count
        if(inputCount > 0){
            for i in 1...inputCount{
                if(textLabel.text!.hasPrefix( textField.text!.prefix(i) )){
                    score_tmp = i
                    // 前方一致分だけtextFieldの文字色を変える
                    let attrText = NSMutableAttributedString(string: textLabel.text!)
                    attrText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, score_tmp))
                    textLabel.attributedText = attrText
                } else {
                    break
                }
            }
        }
    }

    /*
     * jsonファイル読み込み処理
     */
    func getJSONData() throws -> Data? {
        guard let path = Bundle.main.path(forResource: "texts", ofType: "json") else { return nil }
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }

    /*
     * 問題テキストをセットする処理
     */
    func setText(){
        guard let jsonData:Data = try? getJSONData() else { return }
        guard let jsonDecoded = try? JSONDecoder().decode([JsonData].self, from: jsonData) else { return }
        textData = jsonDecoded[difficultyNum].texts
        textData.shuffle()
        textLabel.text = "3"
    }

    /*
     * 「ゲーム開始」「停止時からの復帰」のタイマーの画面更新処理
     */
    func startingTimerUpdate() -> Int{
        let remainCount = 3 - count
        if(remainCount <= 0){
            inputField.isEnabled = true
            resetButton.isEnabled = true
            pauseButton.isEnabled = true
            textLabel.text = textData.remove(at: 0)
        }else{
            textLabel.text = "\(remainCount)"
        }
        return remainCount
    }

    // 経過時間の処理
    @objc func startingTimerInterrupt(_ timer:Timer){
        count += 1
        if(startingTimerUpdate() <= 0){
            count = 0
            timer.invalidate() // タイマー停止

            // ゲームスタート
            inputField.becomeFirstResponder()
            countDownTimer()
        }
    }

    // カウントダウン処理
    func startingTimer(){
        inputField.text = ""
        count = 0
        if let startingTimer = timer {
            if startingTimer.isValid == true {
                return
            }
        }
        // タイマースタート
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.startingTimerInterrupt(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }

    /*
     * 残り時間ラベルの更新処理
     */
    func countDownUpdate() -> Int{
        let remainCount = TIMELIMIT - count
        countDownLabel.text = "残り \(remainCount)"
        if(remainCount <= 0){
            finishPlaying()
        }
        return remainCount
    }

    // 経過時間の処理
    @objc func countDownInterrupt(_ timer:Timer){
        count += 1
        if(countDownUpdate() <= 0){
            count = 0
            timer.invalidate() // タイマー停止
        }
    }

    func countDownTimer(){
        if let startingTimer = timer {
            if startingTimer.isValid == true {
                return
            }
        }
        // タイマースタート
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.countDownInterrupt(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }

    // タイマー終了処理
    func finishPlaying(){
        // アラート生成
        let alertController = UIAlertController(title: "終了!", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "goResult", sender: nil)
        })
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)

        // 入力不可
        inputField.isEnabled = false

        score += score_tmp
        scoreLabel.text = "\(score)pts"
    }
}
