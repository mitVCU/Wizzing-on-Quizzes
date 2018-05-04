//
//  PeerServiceManager.swift
//  Wizzing on Quizzes
//
//  Created by Mit Amin on 5/4/18.
//  Copyright © 2018 Mit Amin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class PeerServiceManager: NSObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var session: MCSession!
    var peerID: MCPeerID!
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.browser = MCBrowserViewController(serviceType: "player", session: session)
        self.assistant = MCAdvertiserAssistant(serviceType: "player", discoveryInfo: nil, session: session)
        
        assistant.start()
//        session.delegate = self
//        browser.delegate = self
    }
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        // Called when a connected peer changes state (for example, goes offline)
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}
