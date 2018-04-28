//
//  QuizViewController.swift
//  Wizzing on Quizzes
//
//  Created by Mit Amin on 4/26/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import Foundation
import UIKit

class QuizViewController {
    
    //Mark IB-Outlets
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var person1: UIImageView!
    @IBOutlet weak var person2: UIImageView!
    @IBOutlet weak var person3: UIImageView!
    @IBOutlet weak var person4: UIImageView!
    @IBOutlet weak var p1Answer: UILabel!
    @IBOutlet weak var p2Answer: UILabel!
    @IBOutlet weak var p3Answer: UILabel!
    @IBOutlet weak var p4Answer: UILabel!
    @IBOutlet weak var p1Score: UILabel!
    @IBOutlet weak var p2Score: UILabel!
    @IBOutlet weak var p3Score: UILabel!
    @IBOutlet weak var p4Score: UILabel!
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var question: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func aTapped(_ sender: UIButton) {
    }
    @IBAction func bTapped(_ sender: UIButton) {
    }
    
    @IBAction func cTapped(_ sender: Any) {
    }
    @IBAction func dTapped(_ sender: UIButton) {
    }
}
