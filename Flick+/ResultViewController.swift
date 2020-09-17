//
//  ResultViewController.swift
//  Flick+
//
//  Created by ikei6256 on 2020/05/25.
//  Copyright © 2020 ikei_org. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var score:Int = 0
    var difficultyNum:Int = ViewController().difficultyNum
    let TABLEROWS:Int = 10
    var rankings:[ScoreData] = []
    var newScoreRow:Int? // 記録更新した順位
    let rankingUrl: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataUrl = url.appendingPathComponent("ranking.json")
        return dataUrl
    }()

    struct ScoreData: Codable {
        var difficulty: String
        var scores: [Int]
    }

    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var newRecordLabel: UILabel!
    @IBAction func toTitleButtonAction(_ sender: Any) {
        // アラート生成
        let alertController = UIAlertController(title: "タイトルへ戻りますか？", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (action:UIAlertAction) -> Void in
            self.navigationController?.popToRootViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            // 何もしない
        })
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        self.scoreLabel.layer.cornerRadius = 10
        self.scoreLabel.clipsToBounds = true
        self.newRecordLabel.isHidden = true

        scoreLabel.text = "\(score)pts"

        self.rankings = self.loadScore()!
        for i in 0..<TABLEROWS {
            if( rankings[difficultyNum].scores[i] < self.score ){
                // スコアが高い時、レコード更新
                self.newRecordLabel.isHidden = false
                rankings[difficultyNum].scores.insert(self.score, at: i)
                rankings[difficultyNum].scores.remove(at: TABLEROWS)
                newScoreRow = i

                // jsonへ書き込み
                let data = try? JSONEncoder().encode(rankings)
                try? data?.write(to: rankingUrl)

                break;
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goRanking"){
            let nextView = segue.destination as! RankingViewController
            nextView.difficultyNum = self.difficultyNum
            if(newScoreRow != nil){
                nextView.newScoreRow = self.newScoreRow
            }
        }
    }

    // jsonファイル読み込み処理
    func getJSONData() throws -> Data? {
        let data = try? Data(contentsOf: rankingUrl)
        return data
    }

    // JSONデータからスコアをロードする処理
    func loadScore() -> [ScoreData]? {
        guard let jsonData:Data = try? getJSONData() else { return nil }
        guard let jsonDecoded = try? JSONDecoder().decode([ScoreData].self, from: jsonData ) else { return nil }
        return jsonDecoded
    }

}
