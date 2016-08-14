//
//  ViewController.swift
//  MyLittleMonster
//
//  Created by Tihomir Videnov on 3/6/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: dragImg!
    @IBOutlet weak var heartImg: dragImg!
    @IBOutlet weak var skull1Img: UIImageView!
    @IBOutlet weak var skull2Img: UIImageView!
    @IBOutlet weak var skull3Img: UIImageView!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: Timer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHearth: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        
        skull1Img.alpha = DIM_ALPHA
        skull2Img.alpha = DIM_ALPHA
        skull3Img.alpha = DIM_ALPHA
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(_:)), name: "onTargetDropped" as NSNotification.Name, object: nil)
        
        do {
            
            let resourcePath = Bundle.main.path(forResource: "cave-music", ofType: "mp3")!
            let url = URL(fileURLWithPath: resourcePath)
            
            try musicPlayer = AVAudioPlayer(contentsOf: url)
            
            try sfxBite = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "bite", ofType: "wav")!))
            try sfxDeath = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "death", ofType: "wav")!))
            try sfxHearth = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "heart", ofType: "wav")!))
            try sfxSkull = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "skull", ofType: "wav")!))

            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxSkull.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxHearth.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startTimer()
    }
    
    func itemDroppedOnCharacter(_ notif: AnyObject) {
        monsterHappy = true
        startTimer()
        foodImg.alpha = DIM_ALPHA
        foodImg.isUserInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.isUserInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHearth.play()
        } else {
            sfxBite.play()
        }
        
    }

    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        
        if !monsterHappy {
            
            penalties += 1
            sfxSkull.play()
            
            if penalties == 1 {
                skull1Img.alpha = OPAQUE
                skull2Img.alpha = DIM_ALPHA
            } else if penalties == 2 {
                skull2Img.alpha = OPAQUE
                skull3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                skull3Img.alpha = OPAQUE
            } else {
                skull1Img.alpha = DIM_ALPHA
                skull2Img.alpha = DIM_ALPHA
                skull3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                timer.invalidate()
                gameOver()
            }

            
        }
        
        let rand = arc4random_uniform(2) // gives number 0 or 1
        
        
        // 0 is the hearth, 1 is the food
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.isUserInteractionEnabled = false
            
            heartImg.alpha = OPAQUE
            heartImg.isUserInteractionEnabled = true
        } else {
            heartImg.alpha = DIM_ALPHA
            heartImg.isUserInteractionEnabled = false
            
            foodImg.alpha = OPAQUE
            foodImg.isUserInteractionEnabled = true
        }
        
        currentItem = rand
        monsterHappy = false
    }
    
    func gameOver() {
        timer.invalidate()
        monsterImg.playDeathAnimation()
        sfxDeath.play()
    }

}


