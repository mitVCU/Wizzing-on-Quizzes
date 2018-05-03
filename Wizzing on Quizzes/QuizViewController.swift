//
//  QuizViewController.swift
//  Wizzing on Quizzes
//
//  Created by Mit Amin on 4/26/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

struct QuizResponse: Decodable {
    let numberOfQuestions: Int
    let questions: [Question]
    let topic: String
    
    struct Question: Decodable {
        let number: Int
        let questionSentence: String
        let options: [String: String]
        let correctOption: String
      
    }
}

class QuizViewController: UIViewController {
    
    //temp data
    var  questions = ["Favorite pet?", "Favorite Color?", "Favorite city?"]
    var answersChoices = [["dog", "cat", "bird", "cow"], ["blue", "purple", "red", "green"], ["New York   ", "Tokyo", "Richmond", "Paris"]]
    var correctAnswers = ["dog", "blue", "Richmond"]
    
    //Variables
    var jsonUrlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
    var numberOfQuestions = 0
    var topic = ""
    var currQuestion = 0
    var correctAnswer = 0
    var seconds = 5
    var TIMER = Timer()
    var answers = [UIButton?]()
    var currAnswer = -1
    var numOfPlayers = 1
    var p1Points = 0
    var button = UIButton()
    var submitted = false
    
    //Mark IB-Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var questionCount: UILabel!
    @IBOutlet weak var p1Score: UILabel!
    @IBOutlet weak var p2Score: UILabel!
    @IBOutlet weak var p3Score: UILabel!
    @IBOutlet weak var p4Score: UILabel!
    @IBOutlet weak var p4: UIImageView!
    @IBOutlet weak var p3: UIImageView!
    @IBOutlet weak var p2: UIImageView!
    @IBOutlet weak var p1: UIImageView!
    @IBOutlet weak var p1Name: UILabel!
    @IBOutlet weak var p2Name: UILabel!
    @IBOutlet weak var p3Name: UILabel!
    @IBOutlet weak var p4Name: UILabel!
    @IBOutlet weak var p4Answer: UILabel!
    @IBOutlet weak var p3Answer: UILabel!
    @IBOutlet weak var p2Answer: UILabel!
    @IBOutlet weak var p1Answer: UILabel!
    @IBOutlet weak var ResetBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: jsonUrlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {
                return
            }
            
            do {
                let quiz = try JSONDecoder().decode(QuizResponse.self, from: data)
                print(quiz.numberOfQuestions)
                self.saveJSONData(quiz: quiz)
                
            } catch let jsonError {
                print("Error decoding json", jsonError)
            }
//            let dataAsAString = String(data: data, encoding: .utf8)
//            print(dataAsAString)
        }.resume()
    
        ResetBtn.alpha = 0
        TIMER = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        print(numOfPlayers,"numb")
        switch numOfPlayers{
        case 1:
            p2.alpha = 0.3
            p3.alpha = 0.3
            p4.alpha = 0.3
        case 2:
            p3.alpha = 0.3
            p4.alpha = 0.3
        case 3:
            p4.alpha = 0.3
        default:
            p1.alpha = 1
            p2.alpha = 1
            p3.alpha = 1
            p4.alpha = 1
        }
    }
    
    func saveJSONData(quiz: QuizResponse) {
        numberOfQuestions = quiz.numberOfQuestions
        topic = quiz.topic
        questions = []
        correctAnswers = []
        answersChoices = []
        for each in quiz.questions {
            questions.append(each.questionSentence)
            var jsonAnswerChoices: [String] = []
            for each in each.options {
                let answer =  each.key + " " + each.value
                  jsonAnswerChoices.append(answer)
            }
            answersChoices.append(jsonAnswerChoices.sorted())
            correctAnswers.append(each.correctOption)
        }
        
        print(questions)
        print(answersChoices)
        print(correctAnswers)
        
        // To ensure UI change is done on main thread
        // if not shit goes south
        DispatchQueue.main.async {
            self.newQuestion()
        }
    }
    
    func newQuestion() {
        questionCount.text = "Question \(currQuestion+1)/\(questions.count)"
        question.text = questions[currQuestion]
        
        switch correctAnswers[currQuestion]{
        case "A":
            correctAnswer = 1
        case "B":
            correctAnswer = 2
        case "C":
            correctAnswer = 3
        case "D":
            correctAnswer = 4
        default:
            correctAnswer = 1
        }

        //create btn
        for i in 1...4{
            button = view.viewWithTag(i) as! UIButton
            answers.append(button)
            button.setTitle(answersChoices[currQuestion][i-1], for: .normal)
            button.addTarget(self, action: #selector(multipleTap(_:event:)), for: UIControlEvents.touchDownRepeat)
        }
        currQuestion = currQuestion + 1
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        if (!submitted){
            if (currAnswer == -1){
                sender.alpha = 0.5
                currAnswer = sender.tag
            }
            else{
                answers[currAnswer - 1]?.alpha = 1
                currAnswer = sender.tag
                sender.alpha = 0.5
            }
        }
        print(currAnswer)
    }
    
    @objc func multipleTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2 ) {
            submit()
        }
    }
    
    func submit() {
        print(currAnswer,"current Answer")
        submitted = true
        switch currAnswer{
        case 1:
            p1Answer.text = "A"
        case 2:
            p1Answer.text = "B"
        case 3:
            p1Answer.text = "C"
        case 4:
            p1Answer.text = "D"
        default:
            p1Answer.alpha = 0
        }
        
        if (currAnswer == correctAnswer){
            p1Points = p1Points + 1
            p1Score.text = "\(p1Points)"
        }
    }
    

    @objc func countDown (){
        seconds = seconds - 1
        timerLabel.text = "\(seconds)"
        if (seconds == 0){
            TIMER.invalidate()

            print("will be submitting answer") //TODO send answer
            submit()
    
            if (currQuestion != questions.count){
                seconds = 5
                TIMER = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
                newQuestion()
                submitted = false
            }
            else{
                timerLabel.text = "You Won with \(p1Points) Points"
                ResetBtn.alpha = 1
            }
        }
    }
}
