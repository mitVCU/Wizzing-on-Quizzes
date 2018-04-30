//
//  ViewController.swift
//  Wizzing on Quizzes
//
//  Created by Mit Amin on 4/20/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import UIKit
import MultipeerConnectivity
class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    var session : MCSession!
    var peerID: MCPeerID!
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var numOfPlayers = 1

    
    var connectedPeers = [MCPeerID]()
    
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
    
    @IBAction func onClickStartQuiz(_ sender: UIButton) {
        let playType = multiOrSingle.selectedSegmentIndex
        if (playType == 0){
            print("Its solo mode")
            performSegue(withIdentifier: "startQuiz", sender: self)
        }
        else if (playType == 1){
            if (connectedPeers.count < 1){
                createAlert(body: "You are not connected to anyone")
            }
            else if (connectedPeers.count > 3){
                createAlert(body: "You are connected to more than 3 people. Please disconnect some players")
            }
            performSegue(withIdentifier: "startQuiz", sender: self)
            print("it's multi player time")
           
        }
    }
    
    @IBAction func onClickConnect(_ sender: UIButton) {
        present(browser, animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case MCSessionState.connected:
                connectedPeers.append(peerID)
                numOfPlayers = numOfPlayers + 1
                print("Connected: \(peerID.displayName)")
            
            case MCSessionState.connecting:
                print("Connecting: \(peerID.displayName)")
            
            case MCSessionState.notConnected:
                connectedPeers = connectedPeers.filter({ $0 !== peerID })
                numOfPlayers = numOfPlayers - 1
                print("Not Connected: \(peerID.displayName)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startQuiz" {
            if let viewController = segue.destination as? QuizViewController {
                viewController.numOfPlayers = numOfPlayers
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("recieving stuff")
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

