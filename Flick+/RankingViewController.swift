//
//  RankingViewController.swift
//  Flick+
//
//  Created by ikei6256 on 2020/05/25.
//  Copyright © 2020 ikei_org. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    var rankings:[ScoreData] = []
    var difficultyNum:Int = ViewController().difficultyNum
    var difficultyNum_tmp:Int?
    let difficultyList:[String] = ViewController().difficultyList
    let TABLEROWS:Int = ResultViewController().TABLEROWS
    let rankingUrl: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataUrl = url.appendingPathComponent("ranking.json")
        return dataUrl
    }()
    let titleLabel = UILabel()
    var newScoreRow:Int?
    var isReloadTableView:Bool = false

    struct ScoreData: Codable {
        var difficulty: String
        var scores: [Int]
    }

    @IBOutlet weak var rankingTableView: UITableView!
    @IBAction func resetButton(_ sender: Any) {
        // アラート生成
        let alertController = UIAlertController(title: "ランキングをリセットしますか？", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (action:UIAlertAction) -> Void in
            // アプリケーションバンドルからランキングデータを読み込んでDocumentsのランキングデータを更新する
            try? FileManager.default.removeItem(at: self.rankingUrl)
            try? FileManager.default.copyItem(
                at: URL(fileURLWithPath: Bundle.main.path(forResource: "ranking", ofType: "json")!),
                to: URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("ranking.json").path) )
            self.rankings = self.loadScore()!
            self.newScoreRow = nil
            self.isReloadTableView = true
            self.rankingTableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action:UIAlertAction) -> Void in
            //
        })
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        difficultyNum_tmp = difficultyNum
        // ランキング読み込み
        rankings = self.loadScore()!
        // カスタムセルの呼び出し
        rankingTableView.register( UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "reUseCell")
        // ナビゲーションタイトルのタップ動作を登録
        titleLabel.text = "   " + difficultyList[difficultyNum] + "   "
        titleLabel.textAlignment = .center
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.navigationTitleAction))
        titleLabel.addGestureRecognizer(tap)
        titleLabel.isUserInteractionEnabled = true
        navigationItem.titleView = titleLabel
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

    // TableViewデリゲートメソッド:セルの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    // TableViewデータソースメソッド:セルの値
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "reUseCell", for: indexPath) as! CustomTableViewCell

        // 1,2,3位の高さを調整する
        if( indexPath.row < 3 ) {
            tableView.rowHeight = 100
        } else{
            tableView.rowHeight = 40
        }

        // セルに表示する値を設定する
        cell.cellManage(indexPath:indexPath, rankings: self.rankings, difficultyNum: self.difficultyNum)

        // 記録更新行の装飾
        if(indexPath.row == newScoreRow && difficultyNum == difficultyNum_tmp){
            cell.cellLabel.text! += "  new!"
            let attrText = NSMutableAttributedString(string: cell.cellLabel.text!)
            attrText.addAttribute(.foregroundColor, value: UIColor.systemPink,
                                  range: NSMakeRange(attrText.string.count-4, 4))
            cell.cellLabel.attributedText = attrText

            cell.contentView.backgroundColor = .gray
            UIView.animate(withDuration: 1.5, animations: {
                cell.contentView.backgroundColor = .none
            })
        }

        return cell
    }

    // TableViewリセット時に点滅
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(isReloadTableView){
            cell.contentView.backgroundColor = .gray
            UIView.animate(withDuration: 1.5, animations: {
                cell.contentView.backgroundColor = .none
            })
        }
        if(indexPath.row == TABLEROWS-1){
            self.isReloadTableView = false
        }
    }

    // ナビゲーションバーのタイトルタップ時の動作
    @objc func navigationTitleAction(){
        let alert: UIAlertController = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)

        var defaultActions:[UIAlertAction] = []
        for i in 0..<difficultyList.count {
            defaultActions.append( UIAlertAction(title: difficultyList[i], style: .default, handler:{
                (action: UIAlertAction!) -> Void in
                // 難易度に応じてランキングを更新
                self.titleLabel.text = "   " + self.difficultyList[i] + "   "
                self.difficultyNum = i
                self.rankingTableView.reloadData()
            }))
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            // cansel
        })

        for i in 0..<difficultyList.count {
            alert.addAction(defaultActions[i])
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // ナビゲーションバーで移動時の処理(UINavigationControllerデリゲートメソッド)
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 遷移先が結果表示画面に戻る場合
        if let controller = viewController as? ResultViewController {
            controller.difficultyNum = self.difficultyNum_tmp!
            print(difficultyNum)
        }
    }
}
