//
//  GameScene.swift
//  Game2
//
//  Created by Руслан Ольховка on 07.12.14.
//  Copyright (c) 2014 Руслан Ольховка. All rights reserved.
//

import SpriteKit
//import AVFoundation.AVAudioPlayer

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let carPositions: Array<CGFloat> = [-100, -35, 35, 100]
    var currentCarPosition: Int = 2;
    
    var overlay: SKNode?
    var speedLabel: SKLabelNode?
    
    var world: SKNode?
    var camera: SKNode?
    var car: SKSpriteNode!
    var target:SKNode!
    
    var carForce: CGFloat = 30
    
//    var player: AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {
        
//        let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bigmotor", ofType: "wav")!)
//        println(fileURL)
//        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
//        player.enableRate = true
//        player.prepareToPlay()
//        player.numberOfLoops = -1
//        player.play()
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // overlay
        self.overlay = SKNode()
        self.overlay!.name = "overlay"
        self.overlay!.zPosition = 10
        self.addChild(overlay!)
        
        // speedLabel
        self.speedLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.speedLabel!.fontSize = 22
        self.speedLabel?.position.y = size.height - 50
        self.speedLabel!.text = "0 km/h"
        self.overlay!.addChild(speedLabel!)
        
        // world
        self.world = SKNode()
        self.world?.name = "world"
        addChild(self.world!)
        
        self.physicsWorld.gravity.dy = 0
        
        // road
        var asphalt: SKSpriteNode
        asphalt = road()
        asphalt.position = CGPoint(x: 0, y: 0)
        self.world?.addChild(asphalt)
        asphalt = road()
        asphalt.position = CGPoint(x: 0, y: asphalt.size.height)
        self.world?.addChild(asphalt)
        asphalt = road()
        asphalt.position = CGPoint(x: 0, y: asphalt.size.height * 2)
        self.world?.addChild(asphalt)
        asphalt = road()
        asphalt.position = CGPoint(x: 0, y: asphalt.size.height * 3)
        self.world?.addChild(asphalt)
        
        car = SKSpriteNode(imageNamed:"Stinger")
        car.position.x = self.carPositions[self.currentCarPosition]
        car.name = "car"
        car.physicsBody = SKPhysicsBody(rectangleOfSize: car.size)
        car.physicsBody?.mass = 2
        car.physicsBody?.linearDamping = 1
        car.physicsBody?.angularDamping = 1
        self.world?.addChild(car)
        
//        car.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({ () -> Void in
//            self.car.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
//        }),SKAction.waitForDuration(1)])))
        
        car.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(applyForce), SKAction.waitForDuration(1/30)])))

        
        // Camera
        camera = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 10, height: 10))
        camera!.name = "camera"
        camera!.position.y = -100
//                camera!.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: 1))
                camera!.physicsBody?.linearDamping = 10
        camera!.physicsBody?.allowsRotation = false
        camera!.physicsBody?.mass = 0.001
        self.world?.addChild(camera!)

//        self.physicsWorld.speed = 0.2
        
        target = SKSpriteNode(color: UIColor.greenColor(), size: CGSize(width: 1, height: 1))
        target.position.x = self.carPositions[self.currentCarPosition]
        self.world?.addChild(target)
        
        // addCars
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addCar),SKAction.waitForDuration(3, withRange: 1)])))
        
        // Gestures
        var swipe: UISwipeGestureRecognizer
        swipe = UISwipeGestureRecognizer(target: self, action: "onSwipe:")
        swipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view!.addGestureRecognizer(swipe)
        swipe = UISwipeGestureRecognizer(target: self, action: "onSwipe:")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view!.addGestureRecognizer(swipe)
        swipe = UISwipeGestureRecognizer(target: self, action: "onSwipe:")
        swipe.direction = UISwipeGestureRecognizerDirection.Up
        self.view!.addGestureRecognizer(swipe)
        swipe = UISwipeGestureRecognizer(target: self, action: "onSwipe:")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.view!.addGestureRecognizer(swipe)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func applyForce()
    {
        self.car?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: self.carForce))
        
        car.physicsBody!.velocity.dx = -target.position.x.distanceTo(car.position.x) * 8
        
        world!.enumerateChildNodesWithName("wheel", usingBlock: { (node, stop) -> Void in
            let wheelForce = ((node.position.x < 0) ? self.skRand(0, high: 1/4) : self.skRand(1/2, high: 1)) * self.carForce
            let rotation = node.zRotation
            node.physicsBody?.applyImpulse(CGVector(dx: -sin(rotation) * wheelForce, dy: cos(rotation) * wheelForce))
            if node.position.y < self.car!.position.y - 2000
            {
                node.removeFromParent()
            }
        })
    }
    
    func road() -> SKSpriteNode
    {
        let asphalt = SKSpriteNode(imageNamed: "Asphalt")
        asphalt.name = "asphalt"
//        asphalt.anchorPoint.y = 0
        asphalt.zPosition = -1
        
//        let lBorder = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 1, height: asphalt.size.height))
//        lBorder.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 0, y: lBorder.size.height))
//        lBorder.physicsBody?.friction = 0
//        lBorder.physicsBody?.restitution = 0
//        lBorder.position.x = -asphalt.size.width / 2
//        asphalt.addChild(lBorder)
        
//        let rBorder = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 1, height: asphalt.size.height))
//        rBorder.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 0, y: rBorder.size.height))
//        rBorder.physicsBody?.friction = 0
//        rBorder.physicsBody?.restitution = 0
//        rBorder.position.x = asphalt.size.width / 2
//        asphalt.addChild(rBorder)
        
        return asphalt
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        addCar()
        
//        car.physicsBody?.velocity.dy = 200
//        car.physicsBody?.applyForce(CGVector(dx: 0, dy: 1000))
//        car.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(world!)
//            target.position.x = location.x
//            SKAction.moveToX(location.x, duration: 1, curve: SKActionCurve.BounceEaseIn)
            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
    }
    
    func skRandf() -> CGFloat {
        return CGFloat(rand()) / CGFloat(RAND_MAX)
    }
    
    func skRand(low: CGFloat, high: CGFloat) -> CGFloat {
        return skRandf() * (high - low) + low
    }
    
    func addCar()
    {
        var random = skRand(0,high: 3)
        var carName = ""
        if random < 1
        {
            carName = "shark"
        }
        else if random < 2
        {
            carName = "jefferson"
        }
        else
        {
            carName = "truck"
        }
        
        let wheel = SKSpriteNode(imageNamed: carName)
        wheel.name = "wheel"
        wheel.physicsBody = SKPhysicsBody(rectangleOfSize: wheel.size)
        wheel.physicsBody?.affectedByGravity = false
        wheel.physicsBody?.mass = 1 //wheel.size.height*wheel.size.width/10000
        wheel.physicsBody?.linearDamping = 2 //500/(wheel.size.height*wheel.size.width);
        wheel.physicsBody?.angularDamping = 1
        //        wheel.physicsBody?.usesPreciseCollisionDetection = true

        wheel.position = CGPoint(
            x: self.carPositions[Int(self.skRand(0, high: 4))],
            y: car.position.y + 1000)
        
        if wheel.position.x < 0
        {
            wheel.zRotation = CGFloat(M_PI)
        }
        world?.addChild(wheel)
    }
    
    override func didSimulatePhysics() {
        target.position.y = car.position.y + 300 // - 5 * fabs(car.position.x.distanceTo(target.position.x))
        
        let a = car.position.x.distanceTo(target.position.x)
        let b = car.position.y.distanceTo(target.position.y)
        let rotation = -asin(a / sqrt(a * a + b * b))
        
        let v = car.physicsBody!.velocity
        car.zRotation = -asin(v.dx / sqrt(v.dx * v.dx + v.dy * v.dy))
        
        
        let carSpeed = Int(sqrt(pow((car.physicsBody?.velocity.dx)!,2) + pow((car.physicsBody?.velocity.dy)!,2))/10)
        self.speedLabel?.text = "\(carSpeed) km/h"

//        player.rate = Float(carSpeed) / 10
        
        self.world!.enumerateChildNodesWithName("asphalt", usingBlock: { (node, stop) -> Void in
            let node1: SKSpriteNode = node as SKSpriteNode
            
            if node.position.y - self.car!.position.y < -node1.size.height*2
            {
                node.position.y += node1.size.height * 4
            }
        })
        
//        self.camera!.physicsBody?.applyForce(CGVector(dx: 0, //pow(self.camera!.position.x.distanceTo(car!.position.x-10)/50,5),
//            dy: pow(self.camera!.position.y.distanceTo(car!.position.y-10)/50,5)))
        camera?.position.y = car.position.y - 80
        self.centerOnNode(self.camera!)
        
    }
    
    func centerOnNode(node: SKNode) {
        
        let cameraPositionInScene = node.scene?.convertPoint(node.position, fromNode: node.parent!)
        node.parent!.position.x -= cameraPositionInScene!.x
        node.parent!.position.y -= cameraPositionInScene!.y
    }
    
    func onSwipe(tap: UISwipeGestureRecognizer)
    {
        switch (tap.direction) {
        case UISwipeGestureRecognizerDirection.Right:
            self.currentCarPosition++
            self.moveTarget()
            break;
        case UISwipeGestureRecognizerDirection.Left:
            self.currentCarPosition--
            self.moveTarget()
            break;
        case UISwipeGestureRecognizerDirection.Up:
            self.carForce *= 1.25
            break;
        case UISwipeGestureRecognizerDirection.Down:
            self.carForce /= 1.25
            break;
        default:
            break;
        }
    }

    func moveTarget()
    {
        
        if self.currentCarPosition >= self.carPositions.count
        {
            self.currentCarPosition--;
        }
        if self.currentCarPosition < 0
        {
            self.currentCarPosition = 0
        }
        
        let duration = NSTimeInterval(0.2 * 40 / self.carForce)
        let movement = SKAction.moveToX(self.carPositions[self.currentCarPosition], duration: duration)
//        movement.timingFunction = CubicEaseIn
        movement.timingMode = SKActionTimingMode.EaseIn
        target.runAction(movement)
    }
    
}
