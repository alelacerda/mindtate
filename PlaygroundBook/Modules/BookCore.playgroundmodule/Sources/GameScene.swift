import Foundation
import SpriteKit
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?
    
    func startBackgroundMusic(musicFileName: String) {
        
        if let bundle = Bundle.main.path(forResource: musicFileName, ofType: "mp3"){
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.setVolume(0.6, fadeDuration: 1)
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
        
    }
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    func fadeOutBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.setVolume(0.0, fadeDuration: 12)

    }
}

public class GameScene: SKScene {
    
    // variables
    var dragging: SKSpriteNode!
    var thoughtsCount: Int!
    var state: Int! //start = -1, intro = 0, sound = 1, breath = 2, labels = 3, end = 4
    var buttonPressed: Int!
    var music: Int! // 0 = nature, 1 = neutral, 2 = no sound
    var thoughts = ["friends", "family", "work", "vacation", "task", "cold", "heat", "happiness", "sadness", "comfort", "serenity", "childhood", "nature"]
    
    // images
    let character = SKSpriteNode(imageNamed: "character")
    let iconSensation = SKSpriteNode(imageNamed: "iconBody")
    let iconIdea = SKSpriteNode(imageNamed: "iconIdea")
    let iconMemory = SKSpriteNode(imageNamed: "iconMemory")
    let lamp = SKSpriteNode(imageNamed: "lamp")
    let plant = SKSpriteNode(imageNamed: "plant")
    let rug = SKSpriteNode(imageNamed: "rug")
    let logo = SKSpriteNode(imageNamed: "logo")
    let mouth = SKSpriteNode(imageNamed: "mouth")
    let cloud = SKSpriteNode(imageNamed: "cloud")
    
    // shapes
    let breath = SKShapeNode(circleOfRadius: 250)
    
    // buttons
    let buttonSound1 = SKSpriteNode(imageNamed: "natureSoundButton")
    let buttonSound2 = SKSpriteNode(imageNamed: "neutralSoundButton")
    let buttonSound3 = SKSpriteNode(imageNamed: "noSoundButton")
    let buttonContinue = SKSpriteNode(imageNamed: "continueButton")
    let buttonContinuePressed = SKSpriteNode(imageNamed: "continueButtonPressed")
    let buttonSound1Pressed = SKSpriteNode(imageNamed: "natureSoundButtonPressed")
    let buttonSound2Pressed = SKSpriteNode(imageNamed: "neutralSoundButtonPressed")
    let buttonSound3Pressed = SKSpriteNode(imageNamed: "noSoundButtonPressed")
    let buttonReturn = SKSpriteNode(imageNamed: "returnButton")
    let buttonReturnPressed = SKSpriteNode(imageNamed: "returnButtonPressed")
    
    // texts
    let startText = SKLabelNode(text: "click to start")
    var narration: SKLabelNode!
    var thoughtText: SKLabelNode!
    let sensationText = SKLabelNode(text: "sensation")
    let ideaText = SKLabelNode(text: "idea")
    let memoryText = SKLabelNode(text: "memory")
    let instructionLabel = SKLabelNode(text: "drag the label icon to the thought")
    
    // animations
    var characterFloat: SKAction!
    var up: SKAction!
    var down: SKAction!
    var breathIn: SKAction!
    var breathOut: SKAction!
    let textAnimation = SKAction.sequence([SKAction.fadeIn(withDuration: 0.8),SKAction.wait(forDuration: 4), SKAction.fadeOut(withDuration: 0.8)])
    let mouthAnimation = SKAction.sequence([SKAction.fadeIn(withDuration: 0.2), SKAction.wait(forDuration: 4.6), SKAction.fadeOut(withDuration: 0.2)])
    var textFloat: SKAction!
    var cloudFloat: SKAction!
    var mouthFloat: SKAction!
    
    // colors
    let textColor = UIColor(red: 101.0/255.0, green: 108.0/255.0, blue: 120.0/255.0, alpha: 1)
    let iconIdeaColor = UIColor(red: 252.0/255.0, green: 232.0/255.0, blue: 180.0/255.0, alpha: 1)
    let iconSensationColor = UIColor(red: 160.0/255.0, green: 144.0/255.0, blue: 170.0/255.0, alpha: 1)
    let iconMemoryColor = UIColor(red: 250.0/255.0, green: 213.0/255.0, blue: 242.0/255.0, alpha: 1)
    
    // music
    let natureMusic = "natural"
    let neutralMusic = "neutral"
    var musicPlaying = 2 // 0 = nature, 1 = neutral, 2 = no sound
    var centerX: CGFloat!
    var centerY: CGFloat!
    
    
    public override func didMove(to view: SKView) {
        centerX = self.frame.midX
        centerY = self.frame.midY
        
        // character animation
        up = SKAction.move(to: CGPoint(x: centerX, y: centerY + 8), duration: 2)
        up.timingMode = .easeInEaseOut
        
        down = SKAction.move(to: CGPoint(x: centerX, y: centerY), duration: 2)
        down.timingMode = .easeInEaseOut
        
        characterFloat = SKAction.repeatForever(SKAction.sequence([up, down]))
        
        up = SKAction.move(to: CGPoint(x: centerX + 3, y: centerY + 110), duration: 2)
        up.timingMode = .easeInEaseOut
        
        down = SKAction.move(to: CGPoint(x: centerX + 3, y: centerY + 102), duration: 2)
        down.timingMode = .easeInEaseOut
        
        mouthFloat = SKAction.repeatForever(SKAction.sequence([up, down]))
        
        //start text
        startText.fontName = "Gill Sans"
        startText.fontSize = 50
        startText.position = CGPoint(x: centerX, y: centerY - 600)
        startText.fontColor = textColor
        startText.alpha = 0
        self.addChild(startText)
        
        // start scene
        logo.position = CGPoint(x: centerX, y: centerY)
        logo.alpha = 0
        self.addChild(logo)
        state = -1
        logo.run(SKAction.fadeIn(withDuration: 1))
        startText.run(SKAction.fadeIn(withDuration: 1))
    }

    func start(){
        // thought cloud
        cloud.position = CGPoint(x: centerX, y: centerY)
        cloud.alpha = 0
        self.addChild(cloud)
        
        // ** TEXTS **
        // text narration
        narration = SKLabelNode(fontNamed: "Gill Sans")
        narration.fontSize = 60
        narration.position = CGPoint(x: centerX, y: centerY + 400)
        narration.fontColor = textColor
        narration.alpha = 0
        narration.numberOfLines = 0
        self.addChild(narration)
        
        //thought text
        thoughtText = SKLabelNode(fontNamed: "Gill Sans")
        thoughtText.fontSize = 40
        thoughtText.fontColor = textColor
        thoughtText.alpha = 0
        self.addChild(thoughtText)
        
        sensationText.fontName = "Gill Sans"
        sensationText.fontSize = 40
        sensationText.fontColor = iconSensationColor
        sensationText.alpha = 0
        sensationText.position = CGPoint(x: centerX, y: centerY - 556)
        self.addChild(sensationText)
        
        ideaText.fontName = "Gill Sans"
        ideaText.fontSize = 40
        ideaText.fontColor = iconIdeaColor
        ideaText.alpha = 0
        ideaText.position = CGPoint(x: centerX - 328, y: centerY - 556)
        self.addChild(ideaText)
        
        memoryText.fontName = "Gill Sans"
        memoryText.fontSize = 40
        memoryText.fontColor = iconMemoryColor
        memoryText.alpha = 0
        memoryText.position = CGPoint(x: centerX + 328, y: centerY - 556)
        self.addChild(memoryText)
        
        instructionLabel.fontName = "Gill Sans"
        instructionLabel.fontSize = 40
        instructionLabel.fontColor = textColor
        instructionLabel.alpha = 0
        instructionLabel.position = CGPoint(x: centerX, y: centerY - 600)
        self.addChild(instructionLabel)
        
        // ** BREATH **
        // breath declaration and position
        breath.fillColor = UIColor(red: 222.0/255.0, green: 226.0/255.0, blue: 255.0/255.0, alpha: 1)
        breath.strokeColor = UIColor(red: 222.0/255.0, green: 226.0/255.0, blue: 255.0/255.0, alpha: 1)
        breath.position = CGPoint(x:centerX, y:centerY)
        breath.alpha = 0
        self.addChild(breath)
        
        // ** OBJECTS **
        rug.position = CGPoint(x: centerX, y: centerY - 160)
        rug.alpha = 0
        self.addChild(rug)
        
        plant.position = CGPoint(x: centerX + 230, y: centerY - 40)
        plant.alpha = 0
        self.addChild(plant)
        
        lamp.position = CGPoint(x: centerX - 230, y: centerY - 58)
        lamp.alpha = 0
        self.addChild(lamp)
        
        // ** CHARACTER **
        // character position
        character.position = CGPoint(x: centerX, y: centerY)
        character.alpha = 0
        self.addChild(character)
        
        mouth.position = CGPoint(x: centerX + 3, y: centerY + 102)
        mouth.alpha = 0
        self.addChild(mouth)
        
        
        // ** BUTTONS **
        buttonContinue.position = CGPoint(x: centerX, y: centerY - 600)
        buttonContinue.alpha = 0
        self.addChild(buttonContinue)
        
        buttonContinuePressed.position = CGPoint(x: centerX, y: centerY - 600)
        buttonContinuePressed.alpha = 0
        self.addChild(buttonContinuePressed)
        
        buttonReturn.position = CGPoint(x: centerX, y: centerY - 600)
        buttonReturn.alpha = 0
        self.addChild(buttonReturn)
        
        buttonReturnPressed.position = CGPoint(x: centerX, y: centerY - 600)
        buttonReturnPressed.alpha = 0
        self.addChild(buttonReturnPressed)
        
        buttonSound1.position = CGPoint(x: centerX, y: centerY + 140)
        buttonSound1.alpha = 0
        self.addChild(buttonSound1)
        
        buttonSound1Pressed.position = CGPoint(x: centerX, y: centerY + 140)
        buttonSound1Pressed.alpha = 0
        self.addChild(buttonSound1Pressed)
        
        buttonSound2.position = CGPoint(x: centerX, y: centerY)
        buttonSound2.alpha = 0
        self.addChild(buttonSound2)
        
        buttonSound2Pressed.position = CGPoint(x: centerX, y: centerY)
        buttonSound2Pressed.alpha = 0
        self.addChild(buttonSound2Pressed)
        
        buttonSound3.position = CGPoint(x: centerX, y: centerY - 140)
        buttonSound3.alpha = 0
        self.addChild(buttonSound3)
        
        buttonSound3Pressed.position = CGPoint(x: centerX, y: centerY - 140)
        buttonSound3Pressed.alpha = 0
        self.addChild(buttonSound3Pressed)
        
        // ** VARIABLES **
        dragging = nil
        thoughtsCount = 0
        
        // ** LABEL ICONS **
        iconIdea.position = CGPoint(x: centerX - 328, y: centerY - 428)
        iconIdea.alpha = 0
        self.addChild(iconIdea)
        
        iconSensation.position = CGPoint(x: centerX, y: centerY - 428)
        iconSensation.alpha = 0
        self.addChild(iconSensation)
        
        iconMemory.position = CGPoint(x: centerX + 328, y: centerY - 428)
        iconMemory.alpha = 0
        self.addChild(iconMemory)
        
        intro()
    }
    
    func intro() {
        
        narration.text = " Hi, I'm Ale and today I'm\nfeeling a bit mentally tired"
        character.run(SKAction.fadeIn(withDuration: 0.8))
        rug.run(SKAction.fadeIn(withDuration: 0.8))
        lamp.run(SKAction.fadeIn(withDuration: 0.8))
        plant.run(SKAction.fadeIn(withDuration: 0.8), completion: {
            self.mouth.run(self.mouthAnimation)
            self.narration.run(self.textAnimation, completion:{
                self.narration.text = "Will you meditate with me?"
                self.mouth.run(self.mouthAnimation)
                self.narration.run(SKAction.fadeIn(withDuration: 0.8))
                self.buttonContinue.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeIn(withDuration: 0.8)]))
            })
        })
        
    }
    
    func chooseSound() {
        let buttonFadeIn = SKAction.fadeIn(withDuration: 0.5)
        narration.text = "First, we need to make\nourselves comfortable"
        
        mouth.run(mouthAnimation)
        narration.run(textAnimation, completion:{
            
            self.narration.text = "   Let's choose a\nbackground sound"
            self.mouth.run(SKAction.fadeIn(withDuration: 0.2))
            self.narration.run(SKAction.fadeIn(withDuration: 0.8), completion:{
                
                self.lamp.run(SKAction.fadeOut(withDuration: 1))
                self.rug.run(SKAction.fadeOut(withDuration: 1))
                self.plant.run(SKAction.fadeOut(withDuration: 1))
                self.mouth.run(SKAction.fadeOut(withDuration: 1))
                self.character.run(SKAction.fadeOut(withDuration: 1), completion:{
                    self.buttonSound1.run(buttonFadeIn, completion: {
                        self.buttonSound2.run(buttonFadeIn, completion: {
                            self.buttonSound3.run(buttonFadeIn)
                        })
                    })
                })
            })
        })
    }
    
    func changeSound(newMusic: Int){
        if newMusic == 0 && music != 0 {
            MusicPlayer.shared.stopBackgroundMusic()
            MusicPlayer.shared.startBackgroundMusic(musicFileName: natureMusic)
            musicPlaying = 0
        } else if newMusic == 1 && music != 1 {
            MusicPlayer.shared.stopBackgroundMusic()
            MusicPlayer.shared.startBackgroundMusic(musicFileName: neutralMusic)
            musicPlaying = 1
        } else if newMusic == 2 && music != 2 {
            MusicPlayer.shared.stopBackgroundMusic()
            musicPlaying = 2
        }
    }
    
    func breathing() {
        
        // breath texts
        let breathInText = SKLabelNode(text:"Breathe in")
        let breathOutText = SKLabelNode(text: "Breathe out")

        // breath actions
        let hold = SKAction.wait(forDuration:1)
        breathIn = SKAction.sequence([SKAction.fadeIn(withDuration: 5),hold])
        breathOut = SKAction.sequence([SKAction.fadeOut(withDuration: 5),hold])
        let breathInOut = SKAction.repeatForever(SKAction.sequence([breathIn,breathOut]))
        
        
        breathInText.fontName = "Gill Sans"
        breathInText.fontSize = 60
        breathInText.position = CGPoint(x: centerX, y: centerY + 500)
        breathInText.fontColor = textColor
        breathInText.alpha = 0

        breathOutText.fontName = "Gill Sans"
        breathOutText.fontSize = 60
        breathOutText.position = CGPoint(x: centerX, y: centerY + 500)
        breathOutText.fontColor = textColor
        breathOutText.alpha = 0

        
        // breath animations
        breathIn.timingMode = .easeInEaseOut
        breathOut.timingMode = .easeInEaseOut
        
        self.addChild(breathInText)
        self.addChild(breathOutText)
        //self.addChild(holdText)
        
        breath.alpha = 0
        
        let breathText = SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.wait(forDuration: 4), SKAction.fadeOut(withDuration: 0.5)])
        

        rug.run(SKAction.fadeIn(withDuration:1))
        plant.run(SKAction.fadeIn(withDuration:1))
        lamp.run(SKAction.fadeIn(withDuration:1))
        character.run(SKAction.sequence([SKAction.fadeIn(withDuration:1), SKAction.wait(forDuration: 3.6)]), completion: {
            self.narration.text = "Now let's pay attention to\n         our breathing"
            self.mouth.run(self.mouthAnimation)
            self.narration.run(self.textAnimation, completion: {
                self.rug.run(SKAction.fadeOut(withDuration:1))
                self.plant.run(SKAction.fadeOut(withDuration:1))
                self.lamp.run(SKAction.fadeOut(withDuration:1), completion: {
                    self.character.run(self.characterFloat)
                    self.mouth.run(self.mouthFloat)
                    breathInText.run(breathText)
                    self.breath.run(self.breathIn, completion: {
                        breathOutText.run(breathText)
                        self.breath.run(self.breathOut, completion: {
                            breathInText.run(breathText)
                            self.breath.run(self.breathIn, completion: {
                                breathOutText.run(breathText)
                                self.breath.run(self.breathOut, completion: {
                                    self.breath.run(breathInOut)
                                    self.narration.text = "Keep breathing like this..."
                                    self.mouth.run(self.mouthAnimation)
                                    self.narration.run(self.textAnimation, completion:{
                                        self.state = 3
                                        breathInText.removeFromParent()
                                        breathOutText.removeFromParent()
                                        self.labelThoughts()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    func labelThoughts() {
        if thoughtsCount == 0 {
            narration.text = "Some wandering thoughts\n       might come up..."
            
            narration.run(SKAction.wait(forDuration: 8), completion: {
                self.mouth.run(self.mouthAnimation)
                self.narration.run(self.textAnimation, completion:{
                    self.randomThought(time: 2.0, positionY: Int(self.centerY) + 320)
                    self.narration.text = "Recognize the thought,\n    label it and let it go"
                    
                    self.narration.run(SKAction.wait(forDuration: 4.5), completion: {
                        self.mouth.run(self.mouthAnimation)
                        self.narration.run(self.textAnimation, completion: {
                            self.iconIdea.run(SKAction.fadeIn(withDuration: 0.8))
                            self.ideaText.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.wait(forDuration: 0.8), SKAction.fadeOut(withDuration: 0.8)]))
                            self.iconSensation.run(SKAction.fadeIn(withDuration: 0.8))
                            self.sensationText.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.wait(forDuration: 0.8), SKAction.fadeOut(withDuration: 0.8)]))
                            self.iconMemory.run(SKAction.fadeIn(withDuration: 0.8))
                            self.memoryText.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.wait(forDuration: 0.8), SKAction.fadeOut(withDuration: 0.8)]))
                            self.instructionLabel.run(SKAction.fadeIn(withDuration: 0.8))
                        })
                    })
                    
                })
            })
        }
    }
    
    func randomThought(time: Double, positionY: Int) {
        let positionX = Int(self.centerX) + Int.random(in: -320...320)
        let upThought = SKAction.move(to: CGPoint(x: positionX, y: positionY+8), duration: 2)
        let downThought = SKAction.move(to: CGPoint(x: positionX, y: positionY), duration: 2)
        upThought.timingMode = .easeInEaseOut
        downThought.timingMode = .easeInEaseOut
        
        textFloat = SKAction.repeatForever(SKAction.sequence([upThought,downThought]))
        
        
        
        let upCloud = SKAction.move(to: CGPoint(x: positionX, y: positionY + 8 + 15), duration: 2)
        let downCloud = SKAction.move(to: CGPoint(x: positionX, y: positionY + 15), duration: 2)
        upCloud.timingMode = .easeInEaseOut
        downCloud.timingMode = .easeInEaseOut
        
        cloudFloat = SKAction.repeatForever(SKAction.sequence([upCloud,downCloud]))
        
        thoughtText.fontColor = textColor
        let count = thoughts.count - 1
        let index = Int.random(in: 0...count)
        thoughtText.text = thoughts[index]
        thoughts.remove(at: index)
        thoughtText.position = CGPoint(x: positionX, y: positionY)
        cloud.position = CGPoint(x:positionX, y: positionY + 15)
        cloud.run(self.cloudFloat)
        thoughtText.run(self.textFloat)
        cloud.run(SKAction.sequence([SKAction.wait(forDuration: time), SKAction.fadeIn(withDuration: 1.5)]))
        thoughtText.run(SKAction.sequence([SKAction.wait(forDuration: time), SKAction.fadeIn(withDuration: 1.5)]))
        
    }
    
    func ending(){
        narration.text = "  When you're ready, start\nnoticing your sorroundings\n and return to the present"
        iconIdea.run(SKAction.fadeOut(withDuration: 1))
        iconSensation.run(SKAction.fadeOut(withDuration: 1))
        iconMemory.run(SKAction.fadeOut(withDuration: 1))
        instructionLabel.run(SKAction.fadeOut(withDuration: 1))
        narration.run(SKAction.wait(forDuration: 3), completion: {
            self.mouth.run(self.mouthAnimation)
            self.narration.run(self.textAnimation, completion: {
                self.buttonContinue.run(SKAction.fadeIn(withDuration: 0.5))
            })
        })
    }
    
    func clearScene(){
        // ** TEXTS **
        // text narration
        narration.removeFromParent()
        
        //thought text
        thoughtText.removeFromParent()
        cloud.removeFromParent()
        
        ideaText.removeFromParent()
        memoryText.removeFromParent()
        sensationText.removeFromParent()
        instructionLabel.removeFromParent()
        
        // ** BREATH **
        breath.removeFromParent()
        
        // ** OBJECTS **
        rug.removeFromParent()
        lamp.removeFromParent()
        plant.removeFromParent()
        
        // ** CHARACTER **
        character.removeFromParent()
        mouth.removeFromParent()

        // ** BUTTONS **

        buttonContinue.removeFromParent()
        buttonContinuePressed.removeFromParent()
        buttonReturn.removeFromParent()
        buttonReturnPressed.removeFromParent()
        buttonSound1.removeFromParent()
        buttonSound1Pressed.removeFromParent()
        buttonSound2.removeFromParent()
        buttonSound2Pressed.removeFromParent()
        buttonSound3.removeFromParent()
        buttonSound3Pressed.removeFromParent()
        
        // ** LABEL ICONS **
        iconIdea.removeFromParent()
        iconMemory.removeFromParent()
        iconSensation.removeFromParent()
        
    }
    
    public func touchDown(atPoint pos: CGPoint) {
        
        switch state{
        case -1:
            //start
            startText.run(SKAction.fadeOut(withDuration: 1))
            logo.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.wait(forDuration: 1)]), completion: {
                self.state = 0
                self.start()
            })
        case 0:
            //intro
            if buttonContinue.alpha == 1 && buttonContinue.contains(pos){
                //makes button darker
                buttonContinuePressed.alpha = 1
            }

        case 1:
            //sound
            var flagButton = 0
            if buttonSound1.alpha == 1 && buttonSound1.contains(pos){
                
                //makes button darker
                buttonSound1Pressed.alpha = 1
                flagButton = 1
                
            }else if buttonSound2.alpha == 1 && buttonSound2.contains(pos){
                
                //makes button darker
                buttonSound2Pressed.alpha = 1
                flagButton = 1
                
            }else if buttonSound3.alpha == 1 && buttonSound3.contains(pos){
                
                //makes button darker
                buttonSound3Pressed.alpha = 1
                flagButton = 1
                
            }else if buttonContinue.alpha == 1 && buttonContinue.contains(pos){
                //makes button darker
                buttonContinuePressed.alpha = 1
            }
            if flagButton == 1 && buttonContinue.alpha == 0 {
                buttonContinue.run(SKAction.fadeIn(withDuration: 0.5))
            }
            
        case 3:
            //label
            if iconSensation.alpha == 1 && iconSensation.contains(pos){
                dragging = iconSensation
                self.sensationText.alpha = 1
                self.sensationText.run(SKAction.fadeOut(withDuration: 6))
            }else if iconIdea.alpha == 1 && iconIdea.contains(pos){
                dragging = iconIdea
                self.ideaText.alpha = 1
                self.ideaText.run(SKAction.fadeOut(withDuration: 6))
            }else if iconMemory.alpha == 1 && iconMemory.contains(pos){
                dragging = iconMemory
                self.memoryText.alpha = 1
                self.memoryText.run(SKAction.fadeOut(withDuration: 6))
            }
            
        case 4:
            //ending
            if buttonContinue.alpha == 1 && buttonContinue.contains(pos){
                //makes button darker
                buttonContinuePressed.alpha = 1
            } else if buttonReturn.alpha == 1 && buttonReturn.contains(pos){
                //makes button darker
                buttonReturnPressed.alpha = 1
            }
            
        default:
            //default
            dragging = nil
        }
        
    }
    
    public func touchMoved(toPoint pos: CGPoint) {
        if dragging != nil{
            dragging.position = pos
        }
    }
    
    public func touchUp(atPoint pos: CGPoint){
        switch state{
        case 0:
            //intro
            if buttonContinue.alpha == 1 && buttonContinue.contains(pos){
                //makes button lighter
                buttonContinuePressed.alpha = 0
                
                //button fade
                narration.run(SKAction.fadeOut(withDuration: 1))
                buttonContinue.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.wait(forDuration: 1)]), completion: {
                    // calls next state
                    self.state = 1
                    self.chooseSound()
                })
            }
        case 1:
            //sound
            if buttonSound1.alpha == 1 && buttonSound1.contains(pos){
                //makes button lighter
                buttonSound1Pressed.alpha = 0
                // change sound
                changeSound(newMusic: 0)
                
            }else if buttonSound2.alpha == 1 && buttonSound2.contains(pos){
                //makes button lighter
                buttonSound2Pressed.alpha = 0
                // change sound
                changeSound(newMusic: 1)

            }else if buttonSound3.alpha == 1 && buttonSound3.contains(pos){
                //makes button lighter
                buttonSound3Pressed.alpha = 0
                //change sound
                changeSound(newMusic: 2)
            
            }else if buttonContinue.alpha == 1 && buttonContinue.contains(pos){

                let buttonFadeOut = SKAction.fadeOut(withDuration: 0.5)
                
                //makes button lighter
                buttonContinuePressed.alpha = 0
                
                // button fade
                narration.text = "Good choice!"
                narration.run(textAnimation)
                
                buttonSound1.run(buttonFadeOut, completion: {
                    self.buttonSound2.run(buttonFadeOut, completion: {
                        self.buttonSound3.run(buttonFadeOut, completion: {
                            self.buttonContinue.run(SKAction.sequence([buttonFadeOut, SKAction.wait(forDuration: 2)]), completion: {
                                //calls next state
                                self.state = 2
                                self.breathing()
                            })
                        })
                    })
                })
            }
        case 3:
            //label
            if dragging != nil {
                if thoughtText.alpha == 1 && thoughtText.contains(pos) {
                    if dragging == iconIdea {
                        thoughtText.fontColor = self.iconIdeaColor
                        dragging.position = CGPoint(x: centerX - 328, y: centerY - 428)
                        
                    }else if dragging == iconSensation{
                        thoughtText.fontColor = self.iconSensationColor
                        dragging.position = CGPoint(x: centerX, y: centerY - 428)
                        
                    } else if dragging == iconMemory {
                        thoughtText.fontColor = self.iconMemoryColor
                        dragging.position = CGPoint(x: centerX + 328, y: centerY - 428)
                        
                    }
                    let fade = SKAction.fadeOut(withDuration: 5)
                    fade.timingMode = .easeInEaseOut
                    self.cloud.run(fade)
                    self.thoughtText.run(fade, completion: {
                        self.dragging = nil
                        self.thoughtsCount += 1
                        if self.thoughtsCount < 3 {
                            self.randomThought(time: Double.random(in:2...10), positionY: Int(self.centerY) + Int.random(in: 270...340))
                        } else {
                            self.state = 4
                            self.ending()
                            self.thoughtText.removeAllActions()
                            self.cloud.removeAllActions()
                        }
                    })
                } else {
                    if dragging == iconSensation{
                        dragging.position = CGPoint(x: centerX, y: centerY - 428)
                    } else if dragging == iconMemory {
                        dragging.position = CGPoint(x: centerX + 328, y: centerY - 428)
                    } else if dragging == iconIdea {
                        dragging.position = CGPoint(x: centerX - 328, y: centerY - 428)
                    }
                    dragging = nil
                }
            }
            
        case 4:
            //ending
            if buttonContinue.alpha == 1 && buttonContinue.contains(pos){
                //makes button lighter
                buttonContinuePressed.alpha = 0
               
                buttonContinue.run(SKAction.fadeOut(withDuration: 0.5), completion: {
                    if self.musicPlaying != 2 {
                        MusicPlayer.shared.fadeOutBackgroundMusic()
                    }
                    let returnCharacter = SKAction.move(to: CGPoint(x: self.centerX, y: self.centerY), duration: 2)
                    returnCharacter.timingMode = .easeInEaseOut
                    self.character.removeAllActions()
                    self.character.run(returnCharacter)
                    self.mouth.removeAllActions()
                    self.mouth.position = CGPoint(x: self.centerX + 3, y: self.centerY + 102)
                    self.breath.removeAllActions()
                    self.breath.run(SKAction.fadeOut(withDuration: 4))
                    self.rug.run(SKAction.fadeIn(withDuration: 4), completion: {
                        self.plant.run(SKAction.fadeIn(withDuration: 3), completion: {
                            self.lamp.run(SKAction.fadeIn(withDuration: 2), completion: {
                                self.narration.text = "Thanks for meditating with me,\n      I feel much better now!"
                                self.mouth.run(self.mouthAnimation)
                                self.narration.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8), SKAction.wait(forDuration: 3)]), completion:{
                                    self.buttonReturn.run(SKAction.fadeIn(withDuration: 1), completion: {
                                        MusicPlayer.shared.stopBackgroundMusic()
                                    })
                                })
                            })
                        })
                    })
                })
            } else if buttonReturn.alpha == 1 && buttonReturn.contains(pos){
                //makes button lighter
                buttonReturnPressed.alpha = 0
                
                narration.run(SKAction.fadeOut(withDuration: 1))
                character.run(SKAction.fadeOut(withDuration: 1))
                rug.run(SKAction.fadeOut(withDuration: 1))
                lamp.run(SKAction.fadeOut(withDuration: 1))
                plant.run(SKAction.fadeOut(withDuration: 1))
                buttonReturn.run(SKAction.fadeOut(withDuration: 1), completion: {
                    self.clearScene()
                    //return to initial state
                    self.state = -1
                    self.logo.run(SKAction.fadeIn(withDuration: 1))
                    self.startText.run(SKAction.fadeIn(withDuration: 1))
                    self.musicPlaying = 2
                })
            }
        default:
            //default
            dragging = nil
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: self)) }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: self)) }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }

    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

