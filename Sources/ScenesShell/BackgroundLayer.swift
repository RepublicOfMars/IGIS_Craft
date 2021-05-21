import Igis
import Scenes
import Foundation

  /*
     This class is responsible for the background Layer.
     Internally, it maintains the RenderableEntities for this layer.
   */

func absVal(_ n: Double) -> Double {
    if n < 0 {
        return -1 * n
    }
    return n
}

class BackgroundLayer : Layer, KeyDownHandler, KeyUpHandler, MouseMoveHandler, MouseDownHandler {
    static let seed = Int.random(in:0...256)
    
    let background = Background()
    var camera : Camera = Camera()
    static var computerCount = 0
    var thisComputer = 0
    var computerIsActive = false
    var playerSpawned = false
    static let chat = Chat()

    var initString = ""

    var typing = false
    var command = ""
    
    var cameraIsRotating = (up:false, down:false, left:false, right:false)
    var cameraIsMoving = (forward:false, left:false, backward:false, right:false)
    var cameraVelocity = (forward:0.0, left:0.0, up:0.0)
    var cameraIsFlying = true
    var onGround = false

    var firstComputer = false
    static var playerJoined = false

    var selectedBlock : BlockPoint3d? = nil
    var placeBlock : BlockPoint3d? = nil
    var mining = false

    let world : SimpleWorld

    static var frame = 0

    static let inventory = Inventory()
    static let settings = Settings()

    var previousCameraLocation = Point3d(x:0, y:0, z:0)
    
    init() {
        if !BackgroundLayer.playerJoined {
            firstComputer = true
            BackgroundLayer.playerJoined = true
        }
        
        BackgroundLayer.computerCount += 1
        thisComputer = BackgroundLayer.computerCount - 1
        world = SimpleWorld(seed:BackgroundLayer.seed)
        
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")

        // We insert our RenderableEntities in the constructor
        insert(entity:background, at:.back)
    }

    func spawnPlayer() {
        let spawnLocation = (x:Int.random(in:0..<world.worldSize.horizontal),
                             z:Int.random(in:0..<world.worldSize.horizontal))
        var spawnY = world.worldSize.vertical-1
        var spawnLocationFound = false

        while !spawnLocationFound {
            if world.getBlock(at:BlockPoint3d(x:spawnLocation.x, y:spawnY, z:spawnLocation.z)).type != "air" {
                spawnY += 3
                spawnLocationFound = true
            } else {
                spawnY -= 1
            }
        }
        
        camera.move(x:Double(spawnLocation.x), y:Double(spawnY), z:Double(spawnLocation.z))
    }
    
    override func preSetup(canvasSize:Size, canvas:Canvas) {
        dispatcher.registerKeyDownHandler(handler: self)
        dispatcher.registerKeyUpHandler(handler: self)
        dispatcher.registerMouseMoveHandler(handler: self)
        dispatcher.registerMouseDownHandler(handler: self)
    }

    override func preCalculate(canvas:Canvas) {
        if computerIsActive && !world.generating {

            previousCameraLocation = Point3d(x:camera.x, y:camera.y, z:camera.z)
            
            if cameraIsRotating.up{camera.cameraRotateUp()}
            if cameraIsRotating.down{camera.cameraRotateDown()}
            if cameraIsRotating.left{camera.cameraRotateLeft()}
            if cameraIsRotating.right{camera.cameraRotateRight()}
            
            cameraVelocity.up -= 0.25 //gravity
            
            //camera movement
            let speedLimit = 2.0
            if cameraIsMoving.forward && cameraVelocity.forward < speedLimit {
                cameraVelocity.forward += 0.5
            }
            if cameraIsMoving.left && cameraVelocity.left < speedLimit {
                cameraVelocity.left += 0.5
            }
            if cameraIsMoving.backward && cameraVelocity.forward > -speedLimit {
                cameraVelocity.forward -= 0.5
            }
            if cameraIsMoving.right && cameraVelocity.left > -speedLimit {
                cameraVelocity.left -= 0.5
            }
            
            if !cameraIsMoving.backward && !cameraIsMoving.forward && cameraVelocity.forward != 0 {
                if cameraVelocity.forward > 0.5 {
                    cameraVelocity.forward -= 0.5
                } else if cameraVelocity.forward < -0.5 {
                    cameraVelocity.forward += 0.5
                } else {
                    cameraVelocity.forward = 0.0
                }
            }
            if !cameraIsMoving.left && !cameraIsMoving.right && cameraVelocity.left != 0 {
                if cameraVelocity.left > 0.5 {
                    cameraVelocity.left -= 0.5
                } else if cameraVelocity.left < -0.5 {
                    cameraVelocity.left += 0.5
                } else {
                    cameraVelocity.left = 0.0
                }
            }
            //Vertical collision

            let verticalRay = Turtle3d()
            verticalRay.x = camera.x
            verticalRay.y = camera.y
            verticalRay.z = camera.z
            if cameraVelocity.up > 0 {
                verticalRay.pitch = 90.0
                verticalRay.y += 0.5
            } else {
                verticalRay.pitch = -90.0
                verticalRay.y -= 1.5
            }
            var verticalRayDistance = 0.0
            var verticalCollision = false

            while verticalRayDistance < absVal(cameraVelocity.up) && !verticalCollision {
                let verticalRayBlock = world.getBlock(at:BlockPoint3d(x:Int(verticalRay.x), y:Int(verticalRay.y), z:Int(verticalRay.z)))
                if verticalRayBlock.type != "air" {
                    verticalCollision = true
                }
                
                if !verticalCollision {
                    verticalRayDistance += 1/32
                    verticalRay.forward(steps:1/32)
                }
            }
            
            if verticalCollision {
                if cameraVelocity.up > 0 {
                    verticalRay.y -= 0.5
                } else {
                    verticalRay.y += 1.5
                }
                camera.x = verticalRay.x
                camera.y = verticalRay.y
                camera.z = verticalRay.z
                cameraVelocity.up = 0.0
            } else {
                camera.cameraUp(cameraVelocity.up)
            }

            if verticalRayDistance == 0 {
                onGround = true
            } else {
                onGround = false
            }
            
            //forward/backward collision
            
            let forwardRay = Turtle3d()
            forwardRay.x = camera.x
            forwardRay.y = camera.y
            forwardRay.z = camera.z
            forwardRay.yaw = camera.yaw
            var forwardRayDistance = 0.0
            var forwardCollision = false
            
            while forwardRayDistance < absVal(cameraVelocity.forward) && !forwardCollision {
                forwardRayDistance += 1/16
                if cameraVelocity.forward > 0 {
                    forwardRay.forward(steps:1/16)
                } else {
                    forwardRay.forward(steps:-1/16)
                }

                let forwardRayBlock = world.getBlock(at:BlockPoint3d(x:Int(forwardRay.x), y:Int(forwardRay.y), z:Int(forwardRay.z)))
                if forwardRayBlock.type != "air" {
                    forwardCollision = true
                }
                
                let forwardRayBelowBlock = world.getBlock(at:BlockPoint3d(x:Int(forwardRay.x), y:Int(forwardRay.y)-1, z:Int(forwardRay.z)))
                if forwardRayBelowBlock.type != "air" {
                    forwardCollision = true
                }
            }

            if forwardCollision {
                if cameraVelocity.forward > 0 {
                    forwardRay.forward(steps:-0.5)
                } else {
                    forwardRay.forward(steps:0.5)
                }
                camera.x = forwardRay.x
                camera.y = forwardRay.y
                camera.z = forwardRay.z
            } else {
                camera.cameraForward(cameraVelocity.forward)   
            }
            
            //Left/Right collision
            
            let leftRay = Turtle3d()
            leftRay.x = camera.x
            leftRay.y = camera.y
            leftRay.z = camera.z
            leftRay.yaw = camera.yaw - 90
            leftRay.correctRotation()
            var leftRayDistance = 0.0
            var leftCollision = false
            
            while leftRayDistance < absVal(cameraVelocity.left) && !leftCollision {
                leftRayDistance += 1/16
                if cameraVelocity.left > 0 {
                    leftRay.forward(steps:1/16)
                } else {
                    leftRay.forward(steps:-1/16)
                }
                
                let leftRayBlock = world.getBlock(at:BlockPoint3d(x:Int(leftRay.x), y:Int(leftRay.y), z:Int(leftRay.z)))
                if leftRayBlock.type != "air" {
                    leftCollision = true
                }
                
                
                let leftRayBelowBlock = world.getBlock(at:BlockPoint3d(x:Int(leftRay.x), y:Int(leftRay.y)-1, z:Int(leftRay.z)))
                if leftRayBelowBlock.type != "air" {
                    leftCollision = true
                }
                
            }

            if leftCollision {
                if cameraVelocity.left > 0 {
                    leftRay.forward(steps:-0.5)
                } else {
                    leftRay.forward(steps:0.5)
                }
                camera.x = leftRay.x
                camera.y = leftRay.y
                camera.z = leftRay.z
            } else {
                camera.cameraLeft(cameraVelocity.left)   
            }
        }
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
        dispatcher.unregisterKeyUpHandler(handler: self)
        dispatcher.unregisterMouseMoveHandler(handler: self)
        dispatcher.unregisterMouseDownHandler(handler: self)
    }

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        if computerIsActive {
            if !typing {
                if !BackgroundLayer.inventory.isOpen() && !BackgroundLayer.settings.isOpen() {
                    switch code {
                    case "KeyI": //Rotation
                        cameraIsRotating.up = true
                    case "KeyK":
                        cameraIsRotating.down = true
                    case "KeyJ":
                        cameraIsRotating.left = true
                    case "KeyL":
                        cameraIsRotating.right = true
                    case "KeyW": //Movement
                        cameraIsMoving.forward = true
                    case "KeyS":
                        cameraIsMoving.backward = true
                    case "KeyA":
                        cameraIsMoving.left = true
                    case "KeyD":
                        cameraIsMoving.right = true
                    case "KeyU": //Break block
                        mining = true
                    case "KeyO": //Place block
                        if let location = placeBlock {
                            if BackgroundLayer.inventory.place() {
                                world.setBlock(at:location, to:BackgroundLayer.inventory.selected())   
                            }
                        }
                    case "Space": //jump
                        if onGround {
                            cameraVelocity.up += 2.0
                        }
                    case "KeyZ":
                        BackgroundLayer.inventory.scroll(right:false)
                    case "KeyC":
                        BackgroundLayer.inventory.scroll()
                    case "Enter":
                        typing = true
                    case "Slash":
                        typing = true
                        command.append("/")
                    case "KeyE": //open inventory
                        BackgroundLayer.inventory.toggle()
                    case "Escape": //open settings
                        BackgroundLayer.settings.openSettings()
                    default:
                        Void()
                    }
                } else {
                    if code == "KeyE" || code == "Escape" {
                        BackgroundLayer.inventory.closeInventory()
                        BackgroundLayer.settings.closeSettings()
                    }
                }
            } else {
                //input
                switch key {
                case "Backspace":
                    command = String(command.dropLast())
                case "Escape":
                    command = ""
                    typing = false
                case "Enter":
                    let arguments = command.split(separator : " ")

                    switch arguments[0] {
                    case "/tp":
                        if arguments.count == 4 {
                            if let x = Double(arguments[1]), let y = Double(arguments[2]), let z = Double(arguments[3]) {
                                camera.x = x
                                camera.y = y
                                camera.z = z
                                
                                BackgroundLayer.chat.input("Teleported to \(Int(x)), \(Int(y)), \(Int(z))")
                            }
                        }
                    default:
                        BackgroundLayer.chat.input(":\(command)")
                    }
                    command = ""
                    typing = false
                default:
                    if !shiftKey && !ctrlKey && !altKey {
                        command.append(key)
                    }
                }
            }
        }
    }

    func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        if computerIsActive {
            if !typing {
                switch code {
                case "KeyI":
                    cameraIsRotating.up = false
                case "KeyK":
                    cameraIsRotating.down = false
                case "KeyJ":
                    cameraIsRotating.left = false
                case "KeyL":
                    cameraIsRotating.right = false
                case "KeyW": //Movement
                    cameraIsMoving.forward = false
                case "KeyS":
                    cameraIsMoving.backward = false
                case "KeyA":
                    cameraIsMoving.left = false
                case "KeyD":
                    cameraIsMoving.right = false
                case "KeyU":
                    mining = false
                default:
                    do {}
                }
            }
        }
    }

    func onMouseMove(globalLocation:Point, movement:Point) {
        BackgroundLayer.inventory.hoverOver(point:globalLocation)
        BackgroundLayer.settings.hoverOver(point:globalLocation)
    }

    func onMouseDown(globalLocation:Point) {
        BackgroundLayer.inventory.hoverOver(point:globalLocation)
        BackgroundLayer.inventory.click()
        BackgroundLayer.settings.hoverOver(point:globalLocation)
        BackgroundLayer.settings.click()
    }

    func clearCanvas(canvas:Canvas) {
        if let canvasSize = canvas.canvasSize {
            let canvasRect = Rect(topLeft:Point(), size:canvasSize)
            let canvasClearRectangle = Rectangle(rect:canvasRect, fillMode:.clear)
            canvas.render(canvasClearRectangle)
        }
    }
    
    override func postCalculate(canvas:Canvas) {
        
        if computerIsActive {
            clearCanvas(canvas:canvas)
            
            var sunAngle = (Double(BackgroundLayer.frame)/1440)*180
            let sky = Rectangle(rect:Rect(topLeft:Point(x:0, y:0), size:canvas.canvasSize!), fillMode:.fill)

            while sunAngle > 360 {
                sunAngle -= 360
            }
            
            var timeOfDayMultiplier = 1.0
            if sunAngle > 170 && sunAngle < 200 {
                timeOfDayMultiplier = (200.0 - sunAngle) / 30
            }
            if sunAngle >= 200 && sunAngle <= 340 {
                timeOfDayMultiplier = 0.0
            }
            if sunAngle > 340 {
                timeOfDayMultiplier = (sunAngle - 340) / 30
            }
            if sunAngle < 10 {
                timeOfDayMultiplier = (sunAngle + 20) / 30
            }
            
            canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(FillStyle(color:Color(red:UInt8(128*timeOfDayMultiplier),
                                                green:UInt8(128*timeOfDayMultiplier),
                                                blue:UInt8(196*timeOfDayMultiplier))))
            canvas.render(sky)
            
            canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))

            //render the sun
            let sunPath = Path3d()
            let sunTurtle = Turtle3d()
            sunTurtle.x = camera.x
            sunTurtle.y = camera.y
            sunTurtle.z = camera.z
            sunTurtle.rotate(yaw:90)
            sunTurtle.rotate(pitch:sunAngle)

            sunTurtle.forward(steps:32)
            sunTurtle.rotate(pitch:90)
            sunTurtle.forward(steps:1)
            sunPath.lineTo(Point3d(x:sunTurtle.x, y:sunTurtle.y, z:sunTurtle.z+1))
            sunPath.lineTo(Point3d(x:sunTurtle.x, y:sunTurtle.y, z:sunTurtle.z-1))
            sunTurtle.rotate(pitch:-180)
            sunTurtle.forward(steps:2)
            sunPath.lineTo(Point3d(x:sunTurtle.x, y:sunTurtle.y, z:sunTurtle.z-1))
            sunPath.lineTo(Point3d(x:sunTurtle.x, y:sunTurtle.y, z:sunTurtle.z+1))

            sunPath.renderPath(camera:camera,
                               canvas:canvas,
                               color:Color(red:UInt8(255*timeOfDayMultiplier), green:UInt8(255*timeOfDayMultiplier), blue:UInt8(196*timeOfDayMultiplier)),
                               solid:true,
                               outline:false)
            //render the moon
            let moonPath = Path3d()
            let moonTurtle = Turtle3d()
            moonTurtle.x = camera.x
            moonTurtle.y = camera.y
            moonTurtle.z = camera.z
            moonTurtle.rotate(yaw:90)
            moonTurtle.rotate(pitch:sunAngle+180)

            moonTurtle.forward(steps:32)
            moonTurtle.rotate(pitch:90)
            moonTurtle.forward(steps:1)
            moonPath.lineTo(Point3d(x:moonTurtle.x, y:moonTurtle.y, z:moonTurtle.z+1))
            moonPath.lineTo(Point3d(x:moonTurtle.x, y:moonTurtle.y, z:moonTurtle.z-1))
            moonTurtle.rotate(pitch:-180)
            moonTurtle.forward(steps:2)
            moonPath.lineTo(Point3d(x:moonTurtle.x, y:moonTurtle.y, z:moonTurtle.z-1))
            moonPath.lineTo(Point3d(x:moonTurtle.x, y:moonTurtle.y, z:moonTurtle.z+1))
            
            moonPath.renderPath(camera:camera,
                               canvas:canvas,
                               color:Color(red:UInt8(128), green:UInt8(128), blue:UInt8(128+68*(timeOfDayMultiplier))),
                               solid:true,
                               outline:false)
            
            world.render(camera:camera, canvas:canvas)

            if !world.generating {
                if BackgroundLayer.inventory.isOpen() || BackgroundLayer.settings.isOpen() {
                    canvas.render(CursorStyle(style:CursorStyle.Style(rawValue:"initial")!))
                } else {
                    canvas.render(CursorStyle(style:CursorStyle.Style(rawValue:"none")!))
                }
                if !playerSpawned {
                    camera.x = 0
                    camera.y = 0
                    camera.z = 0
                    spawnPlayer()
                    playerSpawned = true
                }
                canvas.render(FillStyle(color:Color(red:UInt8(192*(1-timeOfDayMultiplier)), green:UInt8(192*(1-timeOfDayMultiplier)), blue:UInt8(192*(1-timeOfDayMultiplier)))))
                let cameraPosText = Text(location:Point(x:20, y:20), text:"Camera Position:", fillMode:.fill)
                cameraPosText.alignment = .left
                cameraPosText.font = "8pt Arial"
                canvas.render(cameraPosText)
                canvas.render(Text(location:Point(x:20, y:30), text:"X: \(Int(camera.x))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:40), text:"Y: \(Int(camera.y))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:50), text:"Z: \(Int(camera.z))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:60), text:"Pitch: \(camera.pitch)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:70), text:"Yaw: \(camera.yaw)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:80), text:"Speed: \(Double(Int(80.0 * previousCameraLocation.distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z))))/10)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:90), text:"Computers Connected: \(BackgroundLayer.computerCount)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:100), text:"Render Distance: \(world.renderDistance)", fillMode:.fill))
                let seconds = BackgroundLayer.frame/8
                let minutes = seconds/60
                var secondsString = "\(seconds%60)"
                if secondsString.count < 2 {
                    secondsString = "0\(secondsString)"
                }
                canvas.render(Text(location:Point(x:20, y:110), text:"Run Time: \(minutes):\(secondsString)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:canvas.canvasSize!.height-20), text:">\(command)", fillMode:.fill))
                
                //show selected block
                var blockSelected = false
                var blocksForward = 0.0
                let ray = Turtle3d()
                
                ray.x = camera.x
                ray.y = camera.y
                ray.z = camera.z
                ray.pitch = camera.pitch
                ray.yaw = camera.yaw
                
                selectedBlock = nil
                placeBlock = nil
                
                while !blockSelected && blocksForward <= 4.5 {
                    let block = world.getBlock(at:BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z)))
                    if block.type != "air" {
                        world.setBlock(at:BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z)), to:"selected")
                        selectedBlock = BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z))
                        
                        ray.forward(steps:-1/16)

                        placeBlock = BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z))
                        
                        blockSelected = true
                        
                    }

                    ray.forward(steps:1/16)
                    blocksForward += 1/16
                }

                //process mining
                if mining {
                    if let blockToBreak = selectedBlock {
                        let block = world.getBlock(at:blockToBreak)
                        let multiplier = BackgroundLayer.inventory.miningMultiplier(block:block.type).multiplier
                        world.setBlock(at:blockToBreak, to:"m\(multiplier)")
                    }
                }
                
                //crosshair
                let crosshairSize = canvas.canvasSize!.height/64
                let crosshair = Turtle(canvasSize:canvas.canvasSize!)
                crosshair.penWidth(width:2)
                crosshair.penColor(color:Color(red:64, green:64, blue:64))
                for _ in 0 ..< 4 {
                    crosshair.penDown()
                    crosshair.forward(steps:crosshairSize)
                    crosshair.backward(steps:crosshairSize)
                    crosshair.right(degrees:90)
                }
                canvas.render(crosshair)

                //render inventory
                BackgroundLayer.inventory.renderInventory(canvas:canvas)
                BackgroundLayer.settings.render(canvas:canvas)

                world.updateMaxPolygons(to:BackgroundLayer.settings.getMaxPolygonsToRender())
            } else {
                canvas.render(CursorStyle(style:CursorStyle.Style(rawValue:"wait")!))
            }
            BackgroundLayer.chat.render(canvas:canvas)
        } else {
            clearCanvas(canvas:canvas)
            if firstComputer {
                computerIsActive = true
            } else {
                renderNoise(canvas:canvas, quality:16, multiplier:128, frame:BackgroundLayer.frame, baseColor:Color(red:128, green:128, blue:128))
                canvas.render(FillStyle(color:Color(red:255, green:255, blue:255)))
                let initPrompt = Text(location:Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2), text:"Multiplayer is currently unsupported.")
                initPrompt.alignment = .center
                initPrompt.font = "\(canvas.canvasSize!.height/16)pt Arial"
                canvas.render(initPrompt)
            }
        }
        
        BackgroundLayer.frame += 1
    }
}
