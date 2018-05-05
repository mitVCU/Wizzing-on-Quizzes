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
    var answerLetter = String()
    var myName: String!
    var quizNumber = 1
    var count = 0
    
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
       // setUpConnectivity()
        grabQuizJSON()
        
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
                if (!submitted){
                    submit()
                }
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
    func sendScore(){
        print ("sending score")
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: ["score", "\(p1Points)"])
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .unreliable)
            print(" sending score")
        }
        catch let err {
            print("Error in sending data \(err)")
        }
    }
    
    func sendAnswer() {
        switch currAnswer{
        case 1:
            answerLetter = "A"
        case 2:
            answerLetter = "B"
        case 3:
            answerLetter = "C"
        case 4:
            answerLetter = "D"
        default:
           answerLetter = " "
        }
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: ["asnwer", answerLetter])
        
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
        sendScore()
        currAnswer = -1
        answerCount += 1
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
        
        let yourScore = p1Points
        let p2ScoreV = Int(self.p2Score!.text!)
        let p3ScoreV =  Int(self.p3Score!.text!)
        let p4ScoreV =  Int(self.p4Score!.text!)
        
        let scoreArray: [Int] = [yourScore, p2ScoreV!, p3ScoreV!, p4ScoreV!]
        let max = scoreArray.max()
        
        if currQuestion == questions.count {
            if max == yourScore {
                timerLabel.text = "You won"
            } else {
                timerLabel.text = "You lost"
            }

        }
        ResetBtn.alpha = 1
        self.TIMER.invalidate()
    }
    
    func determinePlace() -> Int {
        //TODO: Compare to other users score
        return 1
    }
    @objc func checkForYaw() {
        if let data = moitionMangager.deviceMotion {
            let yaw = data.attitude.yaw
            if yaw > 1 || yaw < -1 {
                if (!submitted){
                    submit()
                }
            }
        }
    }

    @objc func countDown (){
        if (answerCount == numOfPlayers && currQuestion != questions.count){
            newQuestion()
            submitted = false
            
            answerCount = 0
        }
        else if (currQuestion == questions.count) { seconds = 0}
       
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
            else if (currQuestion == questions.count){
              endGame()
            }
        } else {
            timerLabel.text = "\(seconds)"
            seconds = seconds - 1
        }
    }
    func updatePlayerScore(score:Int, id:Int) {
        print ("hey moriah")
        print(id, "id in method")
        print(score, "score that sent to blah")
        switch id {
        case 0:
            p2Score.text = "\(score)"
            print("answer 2")
        case 1:
            p3Score.text = "\(score)"
        case 2:
            p4Score.text = "\(score)"
        default:
            print ("you are out of bounds")
        }
    }
    var answerCount = 0
    func updatePlayerAnswers(answer: String, id: Int) {
        print ("hey moriah")
        print(id, "id in method")
        switch id {
        case 0:
            p2Answer.text = answer
            print("answer 2")
            answerCount += 1
        case 1:
            p3Answer.text = answer
            answerCount += 1
        case 2:
            p4Answer.text = answer
            answerCount += 1
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
            if let receivedArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? Array<String> {
                    print(receivedArray, " What I recieved")
                    let id = session.connectedPeers.index(of: peerID)
                    if (receivedArray[0] == "asnwer"){
                        print(id!, ": id sending answer")
                        print(receivedArray[1], "answer")
                        print(receivedArray[1], "let answ")
                        self.updatePlayerAnswers(answer: receivedArray[1], id: id!)
                        self.count = self.count + 1
                    }
                    else if (receivedArray[0] == "score" ){
                        print (receivedArray[1], " : sending score")
                        let a = Int(receivedArray[1])!
                        self.updatePlayerScore(score: a, id: id!)
                    }
                    else if (receivedArray[0] == "moveOn"){
                        self.newQuestion()
                }
            }
        })
    }
    func moveOn()  {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: ["moveOn", " "])
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .unreliable)
            print(" moving on")
        }
        catch let err {
            print("Error in sending data \(err)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func convertAnswer(currA : Int) -> String{
        var send = String()
        switch currA{
        case 1:
            send = "A"
        case 2:
            send = "B"
        case 3:
            send = "C"
        case 4:
            send = "D"
        default:
           send = " "
        }
        return send
    }


}
