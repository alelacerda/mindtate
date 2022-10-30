//#-hidden-code
//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  The Swift file containing the source code edited by the user of this playground book.
//

import PlaygroundSupport
import SpriteKit
import UIKit
import BookCore

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 1024, height: 1536))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFit
    
    scene.backgroundColor = UIColor(red:245.0/255.0, green:247.0/255.0,  blue:255.0/255.0, alpha:1)
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundPage.current.liveView = sceneView
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code


/*:
 # **Mindtate**
 
*To meditate* is to pay attention to the breath while noticing where the mind wanders off.
 
This is an ancient pratice that allows us to learn to **stay in the present** and to **recognize our thoughts** and accept them, without any judgements. It also **reduces stress**, **helps us understand our pains** and **improves our focus**.
 
 This playground is an *interactive experience* for those who want to start experimenting with this technique.
 
 ---
 
 ## Breathing
 
 **Paying attention to our breathing is the most essential part of a meditation pratice.** It *anchors* ourselves in the present and makes us notice and connect to our whole bodies and minds.
 
 Simply *breathe in* slowly through your nose and *breathe out* slowly through your mouth, trying to maintain a calm pace.
 
 
 ---
 
 ## Labeling Thoughts
 
If you notice your mind has wandered, **don't panic**. Simply notice your thoughts, recognize them, label them, and let them go, returning your attention to  your breath.
 

 - Note: There's no right or wrong when it comes to labeling your thoughts. *It's up for you to decide which label goes with which thought.*
 
 
 ---
 
 ## Closing your pratice
 
 When you decide you're ready to stop, take a moment to notice your surroundings, notice how your body feels, notice your emotions. **Do it gently and don't rush.**
 
 
 **And that's it!** Hopefully you will feel much calmer and relaxed by the end, and with each pratice the process of meditating will become easier everytime.
 
 */

