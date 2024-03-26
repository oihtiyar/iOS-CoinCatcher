//
//  GameOver.swift
//  CoinCatcher
//
//  Created by Oğuz İhtiyar on 15.03.2024.
//


import SpriteKit
import GameplayKit

class GameOver: SKScene {
    
   public var win = true
    
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        let label = self.childNode(withName: "//Label") as? SKLabelNode
        if win == false {
            label?.text = "Better Luck Next Time"
        }
        
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scene = GameScene(fileNamed: "GameScene")
        scene!.scaleMode = .aspectFit
        self.view?.presentScene(scene)
        
    }
    
    

}
