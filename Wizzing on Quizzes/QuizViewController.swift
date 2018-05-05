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
import MultipeerConnectivity

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

class QuizViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate  {

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
    var yawTimer = Timer()
    var answers = [UIButton?]()
    var currAnswer = -1
    var numOfPlayers = 1
    var p1Points = 0
    var button = UIButton()
    var submitted = false
    var moitionMangager = CMMotionManager()
    var peerId = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession!
    var mcAdvertiserAsst: MCAdvertiserAssistant!
    var selectedAnswer: Int = -1
    var lastZ = 0
    var session : MCSession!
    var browser: MCBrowserViewController!
    var myName: String!
    var quizNumber = 1
    
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
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var flipBubble1: UIImageView!
    @IBOutlet weak var flipBubble2: UIImageView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print ("mem problem")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(session.connectedPeers.count, "connected peers")
        session.delegate = self
        browser.delegate = self
        grabQuizJSON()
        
        myName =  String(UIDevice.current.name.first!)
        p1Name.text = myName
        
        self.becomeFirstResponder()
        
        yawTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(checkForYaw), userInfo: nil, repeats: true)
        
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
        
        moitionMangager.startAccelerometerUpdates()
        moitionMangager.accelerometerUpdateInterval = 0.2
        moitionMangager.startDeviceMotionUpdates()
        moitionMangager.startAccelerometerUpdates(to: OperationQueue.main) {
            (data, err) in
        
            if let data = data {
                if data.acceleration.x > 1.0 {
                    self.moveAnswerRight()
                } else if data.acceleration.x < -1.0 {
                    self.moveAnswerLeft()
                }
                
                if data.acceleration.y > 1.0 {
                    self.moveAnswerUp()
                } else if data.acceleration.y < -1.0{
                    self.moveAnswerDown()
                }
                
                if data.acceleration.z < -1.0 {
                    print("submit")
                }

                
            } else {
                print("where's all the data")
            }
        }
    }
    
    @objc func checkForYaw() {
        if let data = moitionMangager.deviceMotion {
            let yaw = data.attitude.yaw
            if yaw > 1 || yaw < -1 {
                submit()
            }
        }
    }
    
    
    func moveAnswerLeft() {
        if currAnswer != -1 {
            if currAnswer == 2 {
                aButton.sendActions(for: .touchUpInside)
            } else if currAnswer == 4{
                cButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    func moveAnswerRight() {
        if currAnswer != -1 {
            if currAnswer == 1 {
                bButton.sendActions(for: .touchUpInside)
            } else if currAnswer == 3{
                dButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    func moveAnswerUp() {
        if currAnswer != -1 {
            if currAnswer == 3 {
                aButton.sendActions(for: .touchUpInside)
            } else if currAnswer == 4{
                bButton.sendActions(for: .touchUpInside)
            }
        }
        
    }
    
    func moveAnswerDown() {
        if currAnswer != -1 {
            if currAnswer == 1 {
                cButton.sendActions(for: .touchUpInside)
            } else if currAnswer == 2{
                dButton.sendActions(for: .touchUpInside)
            }
        }
        
    }
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Why are you shaking me?")
            var randomChoice = (answers.random())!!
            var randomChoiceNotAlreadySelected = true
            while randomChoiceNotAlreadySelected {
                if randomChoice.tag != currAnswer {
                    randomChoiceNotAlreadySelected = false
                } else {
                    randomChoice = (answers.random())!!
                }
            }
            if (currAnswer == -1){
                currAnswer = randomChoice.tag
                randomChoice.alpha = 0.5
            }
            else{
                answers[currAnswer - 1]?.alpha = 1
                currAnswer = randomChoice.tag
                randomChoice.alpha = 0.5
            }
        }
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.moitionMangager.stopDeviceMotionUpdates()
    }
    
    func grabQuizJSON() {
        guard let url = URL(string: jsonUrlString) else {
            self.jsonUrlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
            "hi mo"
            grabQuizJSON()
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {
                return
            }
            do {
                let quiz = try JSONDecoder().decode(QuizResponse.self, from: data)
                self.saveJSONData(quiz: quiz)
                print(quiz)
            } catch let jsonError {
                print("Error decoding json", jsonError)
                self.quizNumber = 1
                self.jsonUrlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
                self.grabQuizJSON()
            }
            }.resume()
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

        
        // To ensure UI change is done on main thread
        // if not shit goes south
        DispatchQueue.main.async {
            self.newQuestion()
        }
    }
    
    func newQuestion() {
        
        seconds = 20
        questionCount.text = "Question \(currQuestion+1)/\(questions.count)"
        print("New question number", currQuestion)
        question.text = questions[currQuestion]
        
        p1Answer.text = ""
        p2Answer.text = ""
        p3Answer.text = ""
        p4Answer.text = ""
        
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
            button.alpha = 1
            button.setTitle(answersChoices[currQuestion][i-1], for: .normal)
          //  button.addTarget(self, action: #selector(multipleTap(_:event:)), for: UIControlEvents.touchDownRepeat)
        }
        currQuestion = currQuestion + 1
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        if (!submitted){
            if (currAnswer == -1){
                print("First tap")
                sender.alpha = 0.5
                currAnswer = sender.tag
            }
            else if (currAnswer == sender.tag) {
                print("Second tap")
                submit()
            }
            else{
                print("Chose new answer")
                answers[currAnswer - 1]?.alpha = 1
                currAnswer = sender.tag
                sender.alpha = 0.5
            }
        }
        print(currAnswer)
    }
    
    /*
    @objc func multipleTap(_ sender: UIButton, event: UIEvent) {
        let touch: UITouch = event.allTouches!.first!
        if (touch.tapCount == 2 ) {
            submit()
        }
    }
 */
    
    func sendAnswer() {
        var msg = ""
        switch currAnswer{
        case 1:
            msg = "A"
        case 2:
            msg = "B"
        case 3:
            msg = "C"
        case 4:
            msg = "D"
        default:
           msg = "ER"
        }
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: msg)
        
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .unreliable)
            print("sucess in sending")
        }
        catch let err {
            print("Error in sending data \(err)")
        }
    }
    
    
    func submit() {
        print(currAnswer,"Submitting Answer")
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
        sendAnswer()
        if (currAnswer == correctAnswer){
            p1Points = p1Points + 1
            p1Score.text = "\(p1Points)"
        }
        
        currAnswer = -1
        
        if (numOfPlayers == 1) {
            if (currQuestion != questions.count) {
               // newQuestion()
               // submitted = false
             //   seconds = 6
                
                seconds = 0
            } else {
                endGame()
            }
        } else {
            //TODO check to see if other players have submitted
        }
    }
    
    func endGame() {
    
        if numOfPlayers == 1 {
            // that short so it fits on a small screen
            timerLabel.text = "Game Over: \(p1Points) points"
        } else {
            let place = determinePlace()
            if place == 1 {
                timerLabel.text = "You Won with \(p1Points) Points"
            } else if place == 2 {
                timerLabel.text = "\(place)nd with \(p1Points) Points"
            } else if place == 3 {
                timerLabel.text = "\(place)rd with \(p1Points) Points"
            } else if place == 4{
                timerLabel.text = "\(place)th with \(p1Points) Points"
            }
        }
        ResetBtn.alpha = 1
        self.TIMER.invalidate()
    }
    
    func determinePlace() -> Int {
        //TODO: Compare to other users score
        return 1
    }

    @objc func countDown (){
        
        if (seconds == 0){
            TIMER.invalidate()

            print("will be submitting answer") //TODO send answer
            if (!submitted){
                submit()
            }
            
            if (currQuestion != questions.count){
                seconds = 20
                TIMER = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
                newQuestion()
                submitted = false
                
            }
            else{
              endGame()
            }
        } else {
            timerLabel.text = "\(seconds)"
            seconds = seconds - 1
        }
    }
    
    func updatePlayerAnswers(answer: String, id: Int) {
        print ("hey moriah")
        print(id, "id in method")
        switch id {
        case 0:
            p2Answer.text = answer
            print("answer 2")
        case 1:
            p3Answer.text = answer
        case 2:
            p4Answer.text = answer
        default:
            print ("you are out of bounds")
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        //Find new JSON
        
        quizNumber += 1
        self.jsonUrlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz\(quizNumber).json"
        
        
        print("Moriah", quizNumber)
         currQuestion = -1
         numberOfQuestions = 0
         topic = ""
         currQuestion = 0
         correctAnswer = 0
         seconds = 5
         TIMER = Timer()
         yawTimer = Timer()
         answers = [UIButton?]()
         currAnswer = -1
         p1Points = 0
         button = UIButton()
         submitted = false
         selectedAnswer = -1
         lastZ = 0

         viewDidLoad()
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // this needs to be run on the main thread
        DispatchQueue.main.async(execute: {
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String {
                let id = session.connectedPeers.index(of: peerID)
                print(id!, ": id sending anwer")
                print(receivedString, "answer")
                self.updatePlayerAnswers(answer: receivedString, id: id!)
            }
        })
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }


}
