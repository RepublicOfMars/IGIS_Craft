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

class BackgroundLayer : Layer, KeyDownHandler, KeyUpHandler {
    static let seed = Int.random(in:0...256)
    
    static let background = Background(seed:seed)
    static var cameras : [Camera] = []
    static var computerCount = 0
    var thisComputer = 0
    var computerIsActive = false
    static let chat = Chat()

    var initString = ""

    var typing = false
    var command = ""
    
    var cameraIsRotating = (up:false, down:false, left:false, right:false)
    var cameraVelocity = (forward:0.0, left:0.0, up:0.0)
    var cameraIsFlying = true
    var onGround = false

    var firstComputer = false
    static var playerJoined = false

    var selectedBlock : BlockPoint3d? = nil
    var placeBlock : BlockPoint3d? = nil
    var mining = false

    static var frame = 0

    static let inventory = Inventory()
    
    init() {
        if !BackgroundLayer.playerJoined {
            firstComputer = true
            BackgroundLayer.playerJoined = true
        }
        
        BackgroundLayer.computerCount += 1
        thisComputer = BackgroundLayer.computerCount - 1
        
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")

        // We insert our RenderableEntities in the constructor
        insert(entity:BackgroundLayer.background, at:.back)
    }

    func initializeComputer() {
        BackgroundLayer.cameras.append(Camera())
        computerIsActive = true

        let spawnLocation = (x:Int.random(in:0..<16*BackgroundLayer.background.worldSize.x), z:Int.random(in:0..<16*BackgroundLayer.background.worldSize.x))

        let spawnHeight = 32 + Int(8.0*(+Noise(x:spawnLocation.x, z:spawnLocation.z, seed:BackgroundLayer.seed)))
        
        BackgroundLayer.cameras[thisComputer].move(x:Double(spawnLocation.x)+0.5, y:Double(spawnHeight)+3.0, z:Double(spawnLocation.z)+0.5)
    }
    
    override func preSetup(canvasSize:Size, canvas:Canvas) {
        dispatcher.registerKeyDownHandler(handler: self)
        dispatcher.registerKeyUpHandler(handler: self)
    }

    override func preCalculate(canvas:Canvas) {
        if computerIsActive && Background.generated {
            
            if cameraIsRotating.up{BackgroundLayer.cameras[thisComputer].cameraRotateUp()}
            if cameraIsRotating.down{BackgroundLayer.cameras[thisComputer].cameraRotateDown()}
            if cameraIsRotating.left{BackgroundLayer.cameras[thisComputer].cameraRotateLeft()}
            if cameraIsRotating.right{BackgroundLayer.cameras[thisComputer].cameraRotateRight()}
            
            cameraVelocity.up -= 0.25 //gravity
            //Vertical collision

            let verticalRay = Turtle3d()
            verticalRay.x = BackgroundLayer.cameras[thisComputer].x
            verticalRay.y = BackgroundLayer.cameras[thisComputer].y
            verticalRay.z = BackgroundLayer.cameras[thisComputer].z
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
                if let verticalRayBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(verticalRay.x), y:Int(verticalRay.y), z:Int(verticalRay.z))) {
                    if verticalRayBlock.type != "air" {
                        verticalCollision = true
                    }
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
                BackgroundLayer.cameras[thisComputer].x = verticalRay.x
                BackgroundLayer.cameras[thisComputer].y = verticalRay.y
                BackgroundLayer.cameras[thisComputer].z = verticalRay.z
                cameraVelocity.up = 0.0
            } else {
                BackgroundLayer.cameras[thisComputer].cameraUp(cameraVelocity.up)
            }

            if verticalRayDistance == 0 {
                onGround = true
            } else {
                onGround = false
            }
            
            //forward/backward collision
            
            let forwardRay = Turtle3d()
            forwardRay.x = BackgroundLayer.cameras[thisComputer].x
            forwardRay.y = BackgroundLayer.cameras[thisComputer].y
            forwardRay.z = BackgroundLayer.cameras[thisComputer].z
            forwardRay.yaw = BackgroundLayer.cameras[thisComputer].yaw
            var forwardRayDistance = 0.0
            var forwardCollision = false
            
            while forwardRayDistance < absVal(cameraVelocity.forward) && !forwardCollision {
                forwardRayDistance += 1/16
                if cameraVelocity.forward > 0 {
                    forwardRay.forward(steps:1/16)
                } else {
                    forwardRay.forward(steps:-1/16)
                }

                if let forwardRayBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(forwardRay.x), y:Int(forwardRay.y), z:Int(forwardRay.z))) {
                    if forwardRayBlock.type != "air" {
                        forwardCollision = true
                    }
                }
                
                if let forwardRayBelowBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(forwardRay.x), y:Int(forwardRay.y)-1, z:Int(forwardRay.z))) {
                    if forwardRayBelowBlock.type != "air" {
                        forwardCollision = true
                    }
                }
            }

            if forwardCollision {
                if cameraVelocity.forward > 0 {
                    forwardRay.forward(steps:-0.5)
                } else {
                    forwardRay.forward(steps:0.5)
                }
                BackgroundLayer.cameras[thisComputer].x = forwardRay.x
                BackgroundLayer.cameras[thisComputer].y = forwardRay.y
                BackgroundLayer.cameras[thisComputer].z = forwardRay.z
            } else {
                BackgroundLayer.cameras[thisComputer].cameraForward(cameraVelocity.forward)   
            }
            
            //Left/Right collision
            
            let leftRay = Turtle3d()
            leftRay.x = BackgroundLayer.cameras[thisComputer].x
            leftRay.y = BackgroundLayer.cameras[thisComputer].y
            leftRay.z = BackgroundLayer.cameras[thisComputer].z
            leftRay.yaw = BackgroundLayer.cameras[thisComputer].yaw - 90
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
                
                if let leftRayBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(leftRay.x), y:Int(leftRay.y), z:Int(leftRay.z))) {
                    if leftRayBlock.type != "air" {
                        leftCollision = true
                    }
                }
                
                if let leftRayBelowBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(leftRay.x), y:Int(leftRay.y)-1, z:Int(leftRay.z))) {
                    if leftRayBelowBlock.type != "air" {
                        leftCollision = true
                    }
                }
            }

            if leftCollision {
                if cameraVelocity.left > 0 {
                    leftRay.forward(steps:-0.5)
                } else {
                    leftRay.forward(steps:0.5)
                }
                BackgroundLayer.cameras[thisComputer].x = leftRay.x
                BackgroundLayer.cameras[thisComputer].y = leftRay.y
                BackgroundLayer.cameras[thisComputer].z = leftRay.z
            } else {
                BackgroundLayer.cameras[thisComputer].cameraLeft(cameraVelocity.left)   
            }
        }
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
        dispatcher.unregisterKeyUpHandler(handler: self)
    }

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        if computerIsActive {
            if !typing {
                if !BackgroundLayer.inventory.isOpen() {
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
                        cameraVelocity.forward = 1
                    case "KeyS":
                        cameraVelocity.forward = -1
                    case "KeyA":
                        cameraVelocity.left = 1
                    case "KeyD":
                        cameraVelocity.left = -1
                    case "KeyU": //Break block
                        mining = true
                    case "KeyO": //Place block
                        if let location = placeBlock {
                            if BackgroundLayer.inventory.place() {
                                BackgroundLayer.background.setBlock(at:location, to:BackgroundLayer.inventory.selected())   
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
                    default:
                        Void()
                    }
                } else {
                    if code == "KeyE" || code == "Escape" {
                        BackgroundLayer.inventory.toggle()
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
                                BackgroundLayer.cameras[thisComputer].x = x
                                BackgroundLayer.cameras[thisComputer].y = y
                                BackgroundLayer.cameras[thisComputer].z = z
                                
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
                case "KeyW":
                    cameraVelocity.forward = 0
                case "KeyS":
                    cameraVelocity.forward = 0
                case "KeyA":
                    cameraVelocity.left = 0
                case "KeyD":
                    cameraVelocity.left = 0
                case "KeyU":
                    mining = false
                default:
                    do {}
                }
            }
        }
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
            sunTurtle.x = BackgroundLayer.cameras[thisComputer].x
            sunTurtle.y = BackgroundLayer.cameras[thisComputer].y
            sunTurtle.z = BackgroundLayer.cameras[thisComputer].z
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

            sunPath.renderPath(camera:BackgroundLayer.cameras[thisComputer],
                               canvas:canvas,
                               color:Color(red:UInt8(255*timeOfDayMultiplier), green:UInt8(255*timeOfDayMultiplier), blue:UInt8(196*timeOfDayMultiplier)),
                               solid:true,
                               outline:false)
            //render the moon
            let moonPath = Path3d()
            let moonTurtle = Turtle3d()
            moonTurtle.x = BackgroundLayer.cameras[thisComputer].x
            moonTurtle.y = BackgroundLayer.cameras[thisComputer].y
            moonTurtle.z = BackgroundLayer.cameras[thisComputer].z
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
            
            moonPath.renderPath(camera:BackgroundLayer.cameras[thisComputer],
                               canvas:canvas,
                               color:Color(red:UInt8(128), green:UInt8(128), blue:UInt8(128+68*(timeOfDayMultiplier))),
                               solid:true,
                               outline:false)
            
            BackgroundLayer.background.renderWorld(camera:BackgroundLayer.cameras[thisComputer], canvas:canvas)

            if Background.generated {
                
                canvas.render(FillStyle(color:Color(red:UInt8(192*(1-timeOfDayMultiplier)), green:UInt8(192*(1-timeOfDayMultiplier)), blue:UInt8(192*(1-timeOfDayMultiplier)))))
                let cameraPosText = Text(location:Point(x:20, y:20), text:"Camera Position:", fillMode:.fill)
                cameraPosText.alignment = .left
                cameraPosText.font = "8pt Arial"
                canvas.render(cameraPosText)
                canvas.render(Text(location:Point(x:20, y:30), text:"X: \(Int(BackgroundLayer.cameras[thisComputer].x))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:40), text:"Y: \(Int(BackgroundLayer.cameras[thisComputer].y))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:50), text:"Z: \(Int(BackgroundLayer.cameras[thisComputer].z))", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:60), text:"Pitch: \(BackgroundLayer.cameras[thisComputer].pitch)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:70), text:"Yaw: \(BackgroundLayer.cameras[thisComputer].yaw)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:80), text:"Framerate: 8", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:90), text:"Currently Loaded Regions: \(BackgroundLayer.background.loadedRegions())", fillMode:.fill))
                if let currentBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(BackgroundLayer.cameras[thisComputer].x),
                                                                                          y:Int(BackgroundLayer.cameras[thisComputer].y),
                                                                                          z:Int(BackgroundLayer.cameras[thisComputer].z))) {
                    canvas.render(Text(location:Point(x:20, y:100), text:"Current block: \(currentBlock.type)", fillMode:.fill))
                }
                canvas.render(Text(location:Point(x:20, y:110), text:"Computers Connected: \(BackgroundLayer.computerCount)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:120), text:"Frame: \(BackgroundLayer.frame), Sun Angle: \(Int(sunAngle)%360)", fillMode:.fill))
                canvas.render(Text(location:Point(x:20, y:canvas.canvasSize!.height-20), text:">\(command)", fillMode:.fill))
                
                //show selected block
                var blockSelected = false
                var blocksForward = 0.0
                let ray = Turtle3d()
                
                ray.x = BackgroundLayer.cameras[thisComputer].x
                ray.y = BackgroundLayer.cameras[thisComputer].y
                ray.z = BackgroundLayer.cameras[thisComputer].z
                ray.pitch = BackgroundLayer.cameras[thisComputer].pitch
                ray.yaw = BackgroundLayer.cameras[thisComputer].yaw
                
                selectedBlock = nil
                placeBlock = nil
                
                while !blockSelected && blocksForward <= 4.5 {
                    if let block = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z))) {
                        if block.type != "air" {
                            BackgroundLayer.background.setBlock(at:BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z)), to:"selected")
                            selectedBlock = BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z))
                            
                            ray.forward(steps:-1/16)

                            placeBlock = BlockPoint3d(x:Int(ray.x), y:Int(ray.y), z:Int(ray.z))
                            
                            blockSelected = true
                        }
                    }

                    ray.forward(steps:1/16)
                    blocksForward += 1/16
                }

                
                if mining {
                    if let blockToBreak = selectedBlock {
                        BackgroundLayer.background.setBlock(at:blockToBreak, to:"mine")
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
            }
            BackgroundLayer.chat.render(canvas:canvas)
        } else {
            clearCanvas(canvas:canvas)
            if firstComputer {
                initializeComputer()
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
