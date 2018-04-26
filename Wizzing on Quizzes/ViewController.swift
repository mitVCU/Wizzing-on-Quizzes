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
            print("we are at 0")
        }
        else if (playType == 1){
            print("it's one 1")
        }
    }
    
    @IBAction func onClickConnect(_ sender: UIButton) {
        present(browser, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
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
}

