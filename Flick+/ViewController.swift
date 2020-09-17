//
//  ViewController.swift
//  Flick+
//
//  Created by ikei6256 on 2020/05/24.
//  Copyright © 2020 ikei_org. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var difficultyLabel: UILabel!

    let difficultKey:String = "difficult_value"
    var difficultyNum:Int = 0

    let difficultyList = ["やさしい", "ふつう", "むずかしい", "モン○ト"]

    override func viewDidLoad() {
        super.viewDidLoad()
        difficultyLabelUpdate()

        // ランキングファイルが存在しない場合アプリケーションバンドルからDocumentsディレクトリへコピーする
        if (!FileManager.default.fileExists(atPath:
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("ranking.json").path) ){
            try? FileManager.default.copyItem(
                at: URL(fileURLWithPath: Bundle.main.path(forResource: "ranking", ofType: "json")!),
                to: URL(fileURLWithPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("ranking.json").path) )
        }

    }

    func difficultyLabelUpdate() {
        difficultyLabel.text = "【 " + difficultyList[difficultyNum] + " 】"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goPlaying" {
            let nextView = segue.destination as! PlayingViewController
            nextView.difficultyNum = self.difficultyNum
        }
    }

    @IBAction func StartButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "goPlaying", sender: nil)
    }

    @IBAction func labelTap(_ sender: Any) {
        if(difficultyNum >= difficultyList.count-1){
            difficultyNum = 0
        }else{
            difficultyNum += 1
        }
        difficultyLabelUpdate()
    }
}
