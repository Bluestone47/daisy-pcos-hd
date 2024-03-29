//
//  PartBViewController.swift
//  DAISY PCOS HD
//
//  Created by XIAN DONG on 14/3/19.
//  Copyright © 2019 XIAN DONG. All rights reserved.
//

import UIKit

class PartBViewController: UIViewController, CanReceiveHADS {
    
    @IBOutlet weak var partBLabel: UILabel!
    
    @IBOutlet weak var berlinLabel: UILabel!
    @IBOutlet weak var hadsLabel: UILabel!
    @IBOutlet weak var essLabel: UILabel!
    
    @IBOutlet weak var hadsButton: UIButton!
    @IBOutlet weak var HADSScoreLabel: UILabel!
    
    let berlinLabelColor = UIColor(rgb: 0x3F51B5)
    let hadsLabelColor = UIColor(rgb: 0xFF5722)
    let essLabelColor = UIColor(rgb: 0x009688)
    
    var saveLocalResult = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadLabels()
        
    }
    
    func loadLabels() {
        
        partBLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        berlinLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        berlinLabel.textColor = berlinLabelColor
        berlinLabel.backgroundColor = .clear
        berlinLabel.layer.cornerRadius = 10
        berlinLabel.layer.borderWidth = 2
        berlinLabel.layer.borderColor = berlinLabelColor.cgColor
        
        hadsLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        hadsLabel.textColor = hadsLabelColor
        hadsLabel.backgroundColor = .clear
        hadsLabel.layer.cornerRadius = 10
        hadsLabel.layer.borderWidth = 2
        hadsLabel.layer.borderColor = hadsLabelColor.cgColor
        
        essLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        essLabel.textColor = essLabelColor
        essLabel.backgroundColor = .clear
        essLabel.layer.cornerRadius = 10
        essLabel.layer.borderWidth = 2
        essLabel.layer.borderColor = essLabelColor.cgColor
        
    }
    
    //MARK: - Taking HADS Test
    /***************************************************************/
    
    @IBAction func hadsPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToHADS", sender: self)
        
    }
    
    // Receive results from HADS and show score in label
    func dataReceived(depressionScore: Int, anxietyScore: Int) {
        
        let depressionScoreCase = scoreCase(score: depressionScore)
        let anxietyScoreCase = scoreCase(score: anxietyScore)
        
        hadsButton.isEnabled = false
        HADSScoreLabel.text = "Your depression score is \(depressionScore) (\(depressionScoreCase)).\nYour anxiety score is \(anxietyScore) (\(anxietyScoreCase))."
        
        HADSScoreLabel.backgroundColor = .clear
        HADSScoreLabel.layer.cornerRadius = 10
        HADSScoreLabel.layer.borderWidth = 1
        HADSScoreLabel.layer.borderColor = hadsLabelColor.cgColor
    }
    
    func scoreCase(score: Int) -> String {
        var scoreCase = ""
        
        if score >= 0 && score <= 7 {
            scoreCase = "Normal"
        }
        else if score >= 8 && score <= 10 {
            scoreCase = "Borderline abnormal"
        }
        else if score >= 11 && score <= 21 {
            scoreCase = "Abnormal"
        }
        
        return scoreCase
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToHADS" {
            
            let hadsVC = segue.destination as! HADSViewController
            
            hadsVC.delegate = self
            
        }
        
    }
    
    //MARK: - Store results locally
    /***************************************************************/
    
    // store the results in a local json file
    func storeLocalResults() {
        
        let patientID = QuizResult.shared().result["patientID"] as! String
        if LocalResults.localResults[patientID] != nil {
            LocalResults.localResults[patientID]?.append(ChartFactory().formatResults())
        }
        else {
            LocalResults.localResults[patientID] = [ChartFactory().formatResults()]
        }
        
        // write results to json file
        JsonFileFactory.writeJSONToFile(fileName: "UserResults", dictionary: LocalResults.localResults)
        
        print("New Data Stored in File!")
        print(JsonFileFactory.readJSONFromFile(fileName: "UserResults") as! [String : Array<[String : Any]>])
        
        // check the results
        let records: [[String: Any]] = LocalResults.localResults[patientID]!
        for record in records {
            print(record["date"]!)
            let score = record["hadsScore"] as? [String: Int]
            print(score!["depression"]!)
            print(score!["anxiety"]!)
        }
        
    }
    
    // read the stored result
//    func readLocalResults() {
//        
//        LocalResults.localResults = JsonFileFactory.readJSONFromFile(fileName: "UserResults") as! [String : Array<[String : Any]>]
//        
//        print("Data History Read!")
//        
//    }
    
    // get Today's date
    func getCurrentDate() {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        QuizResult.shared().result["date"] = formattedDate
        
    }
    
    //MARK: - Finish PartB
    /***************************************************************/
    
    @IBAction func nextPressed(_ sender: Any) {
        
        // get the finish date
        getCurrentDate()
        
//        readLocalResults()
        
        // if user finished HADS, update the local results
        if saveLocalResult && QuizResult.shared().hadsFinished == true {
            storeLocalResults()
            saveLocalResult = false
        }
        
        performSegue(withIdentifier: "goToFinish", sender: self)
        
    }
    
}
