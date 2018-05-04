//
//  ViewController.swift
//  Wizzing on Quizzes
//
//  Created by Mit Amin on 4/20/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class ViewController:  UIViewController , MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    var session : MCSession!
    var peerID: MCPeerID!
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var numOfPlayers = 1

    
    
    @IBOutlet weak var onClickConnect: UIBarButtonItem!
    @IBOutlet weak var startQuiz: UIButton!
    @IBOutlet weak var multiOrSingle: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.browser = MCBrowserViewController(serviceType: "connection", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "connection", discoveryInfo: nil, session: session)

        assistant.start()
        session.delegate = self
        browser.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        session.delegate = self
        browser.delegate = self
    }
    
    @IBAction func onClickStartQuiz(_ sender: UIButton) {
        let playType = multiOrSingle.selectedSegmentIndex
        if (playType == 0){
            print("Its solo mode")
            if (session.connectedPeers.count == 0){
            performSegue(withIdentifier: "startQuiz", sender: self)
            }
            else{createAlert(body:" Can't play single while connected to another device")}
        }
        else if (playType == 1){
            if (session.connectedPeers.count < 1){
                createAlert(body: "You are not connected to anyone")
            }
            else if (session.connectedPeers.count > 3){
                createAlert(body: "You are connected to more than 3 people. Please disconnect from some players")
            }
            //TODO start game for all players
            let data =  NSKeyedArchiver.archivedData(withRootObject: "multi")
            do{
                print("it's multi player time")
                print(session.connectedPeers.count, " connected peeers VC")
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                performSegue(withIdentifier: "startQuiz", sender: self)
            }
            catch let err {print("This error hapenend ", err)}
        }
    }
    
    @IBAction func onClickConnect(_ sender: UIButton) {
        present(browser, animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case MCSessionState.connected:
                numOfPlayers = numOfPlayers + 1
                print("Connected: \(peerID.displayName)")

            case MCSessionState.connecting:
                print("Connecting: \(peerID.displayName)")

            case MCSessionState.notConnected:
                numOfPlayers = numOfPlayers - 1
                print("Not Connected: \(peerID.displayName)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startQuiz" {
            if let QuizViewController = segue.destination as? QuizViewController {
                QuizViewController.numOfPlayers = numOfPlayers
                QuizViewController.session = session
                QuizViewController.browser = browser
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("inside didReceiveData")
        // this needs to be run on the main thread
        DispatchQueue.main.async(execute: {
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                if (receivedString == "multi"){
                    self.performSegue(withIdentifier: "startQuiz", sender: self)
                }
            }
        })

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func createAlert(body:String) {
        let ac = UIAlertController(title: "Error", message: body, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}

