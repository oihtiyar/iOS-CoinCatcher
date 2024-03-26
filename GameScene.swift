//
//  GameScene.swift
//  CoinCatcher
//
//  Created by Oğuz İhtiyar on 15.03.2024.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let anvilCategory:UInt32 = 0x1          //0000 0001 (1)
    let coinCategory:UInt32 = 0x10         //0000 0010 (2)
    let characterCategory:UInt32 = 0x100   //0000 0100 (4)
    let groundCategory:UInt32 = 0x1000      //0000 1000 (8)
    
    private var label : SKLabelNode?
    private var character : SKSpriteNode?
    private var characterTextures:[SKTexture] = []
    private var numObjs = 0
    private var collectedCoins = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//Label") as? SKLabelNode
        self.character = self.childNode(withName: "//character") as? SKSpriteNode
        
        characterTextures.append(SKTexture(imageNamed: "frame1"))
        characterTextures.append(SKTexture(imageNamed: "frame2"))
        
        let animation = SKAction.animate(with: characterTextures, timePerFrame: 0.1)
        let animationRepeat = SKAction.repeatForever(animation)
        character!.run(animationRepeat)
        
        character?.physicsBody?.categoryBitMask = characterCategory
        character?.physicsBody?.contactTestBitMask = coinCategory | anvilCategory
        character?.physicsBody?.collisionBitMask = coinCategory | anvilCategory
        
        let ground = self.childNode(withName: "//ground") as?SKSpriteNode
        ground?.physicsBody?.categoryBitMask = groundCategory
        ground?.physicsBody?.contactTestBitMask = coinCategory | anvilCategory
        ground?.physicsBody?.collisionBitMask = coinCategory | anvilCategory
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.8)
        
    }
    func dropObj(){
        //randomly select what to drop and where to position it
        let random = Int.random(in: 1...2) //1=avil, 2=coin
        let randomX = Int.random(in: -400...400)
        let randomY = Int.random(in: 640...800)
        
        let obj = SKSpriteNode(imageNamed: "goldCoin") // var let ile degistirildi
        obj.position = CGPoint (x: randomX, y: randomY)
        obj.size = CGSize(width: 150, height: 150)
        obj.name = "coin"
        
        obj.physicsBody = SKPhysicsBody.init(circleOfRadius: 40)
        obj.physicsBody?.categoryBitMask = coinCategory
        obj.physicsBody?.contactTestBitMask = groundCategory | characterCategory
        addChild(obj)
        
        if (random == 1){
            obj.name = "anvil"
            obj.texture = SKTexture(imageNamed: "anvil")
            obj.physicsBody?.categoryBitMask = anvilCategory
        }
        numObjs += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            if location.x > (character?.position.x)! {
                character?.position.x += 50 //move character to right
            }
            else if location.x < (character?.position.x)! {
                character?.position.x -= 50 //move character to left
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        let bodyA = contact.bodyA.node?.name
        let bodyB = contact.bodyB.node?.name
        print("**Contact \(bodyA) and \(bodyB)")
        
        if ((bodyA == "ground") && (bodyB == "anvil")) || ((bodyA == "ground") && (bodyB == "coin")) {
            contact.bodyB.node?.removeFromParent()
            numObjs -= 1
        }
        else if ((bodyA == "coin") && (bodyB == "ground")) || ((bodyA == "anvil") && (bodyB == "ground")) {
            contact.bodyA.node?.removeFromParent()
            numObjs -= 1
        }
        
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == characterCategory | coinCategory {
            collectedCoins += 1
            label?.text = "Coins Collected: \(collectedCoins)"
            if (bodyA == "coin"){
                contact.bodyA.node?.removeFromParent()
            }
            else {
                contact.bodyB.node?.removeFromParent()
            }
            
            if collectedCoins >= 10 {
                let scene = GameOver(fileNamed: "GameOver")
                scene!.win = true
                scene!.scaleMode = .aspectFit
                let transition = SKTransition.push(with: .up, duration: 5.0)
                self.view?.presentScene(scene!, transition: transition)
            }
        }
        else if collision == characterCategory | anvilCategory {
            character?.texture = SKTexture(imageNamed: "hit")
            let scene = GameOver(fileNamed: "GameOver")
            scene!.win = false
            scene!.scaleMode = .aspectFit
            let transition = SKTransition.push(with: .up, duration: 5.0)
            self.view?.presentScene(scene!, transition: transition)
        }
    }
        
        override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
            
            if (numObjs < 3) {
                dropObj()
            }
        }
    }
