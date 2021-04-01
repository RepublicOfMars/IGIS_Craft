import Igis
import Scenes

  /*
     This class is responsible for the background Layer.
     Internally, it maintains the RenderableEntities for this layer.
   */


class BackgroundLayer : Layer, KeyDownHandler, KeyUpHandler {
    static let seed = Int.random(in:0...256)
    
    static let background = Background(seed:seed)
    static var cameras : [Camera] = []
    static var computerCount = 0
    var thisComputer = 0
    var computerIsActive = false
    var username = ""
    static var usernames : [String] = []
    static let chat = Chat()

    static var renderingComputer = 0

    var initString = ""

    var typing = false
    var command = ""
    
    var cameraIsRotating = (up:false, down:false, left:false, right:false)
    var cameraVelocity = (forward:0.0, left:0.0, up:0.0)
    var cameraIsSprinting = false
    var cameraIsFlying = true
    
    init() {
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")

        // We insert our RenderableEntities in the constructor
        insert(entity:BackgroundLayer.background, at:.back)
    }

    func initializeComputer() {
        BackgroundLayer.computerCount += 1
        thisComputer = BackgroundLayer.computerCount - 1
        BackgroundLayer.cameras.append(Camera())

        username = initString
        BackgroundLayer.usernames.append(username)

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
        if computerIsActive && BackgroundLayer.renderingComputer == thisComputer && Background.generated {
            var multiplier = 1.0
            if cameraIsSprinting{multiplier = 2}
            
            if cameraIsRotating.up{BackgroundLayer.cameras[thisComputer].cameraRotateUp()}
            if cameraIsRotating.down{BackgroundLayer.cameras[thisComputer].cameraRotateDown()}
            if cameraIsRotating.left{BackgroundLayer.cameras[thisComputer].cameraRotateLeft()}
            if cameraIsRotating.right{BackgroundLayer.cameras[thisComputer].cameraRotateRight()}

            cameraVelocity.up -= 0.2

            var collisionAdder = (up:0.5, forward:0.5, left:0.5)

            if cameraVelocity.forward < 0 {
                collisionAdder.forward = -0.5
            }
            if cameraVelocity.left < 0 {
                collisionAdder.left = -0.5
            }
            if cameraVelocity.up < 0 {
                collisionAdder.up = -1.5
            }
            
            if let VerticalCollisionBlock = Background.world.getBlock(at:BlockPoint3d(x:Int(BackgroundLayer.cameras[thisComputer].x),
                                                                                      y:Int(BackgroundLayer.cameras[thisComputer].y+cameraVelocity.up+collisionAdder.up),
                                                                                      z:Int(BackgroundLayer.cameras[thisComputer].z))) {
                
                if VerticalCollisionBlock.type == "air" {
                    BackgroundLayer.cameras[thisComputer].cameraUp(cameraVelocity.up)
                } else {
                    var BlockCollisionAdder = 1.0
                    if cameraVelocity.up > 0 {BlockCollisionAdder = -1.0}
                    
                    let relativePosition = (BackgroundLayer.cameras[thisComputer].y+collisionAdder.up) - (Double(VerticalCollisionBlock.location.y)+BlockCollisionAdder)
                    BackgroundLayer.cameras[thisComputer].cameraUp(-relativePosition)
                    cameraVelocity.up = 0
                }
            } else {
                BackgroundLayer.cameras[thisComputer].cameraUp(cameraVelocity.up)
            }
            
            BackgroundLayer.cameras[thisComputer].cameraForward(cameraVelocity.forward * multiplier)
            BackgroundLayer.cameras[thisComputer].cameraLeft(cameraVelocity.left * multiplier)
            
            /*
            if let HorizontalCollisionBlock = Background.world.getBlock(at:BlockPoint3d(x:Int(BackgroundLayer.cameras[thisComputer].x+cameraVelocity.forward+collisionAdder.forward),
                                                                                        y:Int(BackgroundLayer.cameras[thisComputer].y),
                                                                                        z:Int(BackgroundLayer.cameras[thisComputer].z+cameraVelocity.left+collisionAdder.left))) {
                
                if HorizontalCollisionBlock.type == "air" {
                    BackgroundLayer.cameras[thisComputer].cameraForward(cameraVelocity.forward * multiplier)
                    BackgroundLayer.cameras[thisComputer].cameraLeft(cameraVelocity.left * multiplier)
                } else {
                    cameraVelocity.forward = 0
                    cameraVelocity.left = 0
                }
            } else {
                BackgroundLayer.cameras[thisComputer].cameraForward(cameraVelocity.forward * multiplier)
                BackgroundLayer.cameras[thisComputer].cameraLeft(cameraVelocity.left * multiplier)
            }
             */
        }
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
        dispatcher.unregisterKeyUpHandler(handler: self)
    }

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        if computerIsActive {
            if !typing {
                switch code {
                case "KeyI":
                    cameraIsRotating.up = true
                case "KeyK":
                    cameraIsRotating.down = true
                case "KeyJ":
                    cameraIsRotating.left = true
                case "KeyL":
                    cameraIsRotating.right = true
                case "KeyW":
                    cameraVelocity.forward = 0.5
                case "KeyS":
                    cameraVelocity.forward = -0.5
                case "KeyA":
                    cameraVelocity.left = 0.5
                case "KeyD":
                    cameraVelocity.left = -0.5
                case "Space":
                    cameraVelocity.up += 1.8
                case "ShiftLeft":
                    cameraIsSprinting = true
                case "KeyR":
                    cameraIsRotating.up = false
                    cameraIsRotating.down = false
                    cameraIsRotating.left = false
                    cameraIsRotating.right = false
                    cameraVelocity.forward = 0
                    cameraVelocity.left = 0
                    cameraVelocity.up = 0
                    cameraIsSprinting = false
                case "Enter":
                    typing = true
                case "Slash":
                    typing = true
                    command.append("/")
                default:
                    Void()
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

                                BackgroundLayer.chat.input("Teleported '\(username)' to \(Int(x)), \(Int(y)), \(Int(z))")
                            }
                        }
                        
                        if arguments.count == 5 {
                            if let x = Double(arguments[2]), let y = Double(arguments[3]), let z = Double(arguments[4]) {
                                if BackgroundLayer.usernames.contains(String(arguments[1])) {
                                    for user in 0 ..< BackgroundLayer.usernames.count {
                                        if BackgroundLayer.usernames[user] == String(arguments[1]) {
                                            BackgroundLayer.cameras[user].x = x
                                            BackgroundLayer.cameras[user].y = y
                                            BackgroundLayer.cameras[user].z = z
                                            
                                            BackgroundLayer.chat.input("'\(username)' teleported '\(BackgroundLayer.usernames[user])' to \(Int(x)), \(Int(y)), \(Int(z))")
                                        }
                                    }
                                }
                            }
                        }
                    default:
                        BackgroundLayer.chat.input("\(username): \(command)")
                    }
                    command = ""
                    typing = false
                default:
                    if !shiftKey && !ctrlKey && !altKey {
                        command.append(key)
                    }
                }
            }
        } else {
            switch key {
            case "Backspace":
                initString = String(initString.dropLast())
            case "Enter":
                initializeComputer()
            default:
                if !shiftKey && !ctrlKey && !altKey {
                    initString.append(key)
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
                case "ShiftLeft":
                    cameraIsSprinting = false
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
            if thisComputer == 0 {
                BackgroundLayer.renderingComputer += 1
                if BackgroundLayer.renderingComputer >= BackgroundLayer.computerCount {
                    BackgroundLayer.renderingComputer = 0
                }
            }
            
            if BackgroundLayer.renderingComputer == thisComputer {
                clearCanvas(canvas:canvas)
                let sky = Rectangle(rect:Rect(topLeft:Point(x:0, y:0), size:canvas.canvasSize!), fillMode:.fill)
                
                canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
                canvas.render(FillStyle(color:Color(red:128, green:128, blue:196)))
                if !Background.generated {
                    canvas.render(FillStyle(color:Color(red:128, green:64, blue:32)))
                }
                canvas.render(sky)
                
                canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
                canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))
                
                BackgroundLayer.background.renderWorld(camera:BackgroundLayer.cameras[thisComputer], canvas:canvas)

                if Background.generated {
                    for player in 0 ..< BackgroundLayer.computerCount {
                        if player != thisComputer {
                            if let playerLocation = BackgroundLayer.cameras[player].getLocation().flatten(camera:BackgroundLayer.cameras[thisComputer], canvas:canvas) {
                                Cube(center:BackgroundLayer.cameras[player].getLocation()).renderCube(camera:BackgroundLayer.cameras[thisComputer],
                                                                                                      canvas:canvas,
                                                                                                      color:Color(red:164, green:164, blue:164))
                                Cube(center:Point3d(x:BackgroundLayer.cameras[player].getLocation().x,
                                                    y:BackgroundLayer.cameras[player].getLocation().y-1.0,
                                                    z:BackgroundLayer.cameras[player].getLocation().z)).renderCube(camera:BackgroundLayer.cameras[thisComputer],
                                                                                                                   canvas:canvas,
                                                                                                                   color:Color(red:164, green:164, blue:164))
                                let playerText = Text(location:playerLocation, text:BackgroundLayer.usernames[player])
                                playerText.alignment = .center
                                playerText.font = "8ptArial"
                                canvas.render(FillStyle(color:Color(red:196, green:196, blue:196)))
                                canvas.render(playerText)
                            }
                            
                        }
                    }
                    
                    canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
                    let cameraPosText = Text(location:Point(x:20, y:20), text:"Camera Position:", fillMode:.fill)
                    cameraPosText.alignment = .left
                    cameraPosText.font = "8pt Arial"
                    canvas.render(cameraPosText)
                    canvas.render(Text(location:Point(x:20, y:30), text:"X: \(Int(BackgroundLayer.cameras[thisComputer].x))", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:40), text:"Y: \(Int(BackgroundLayer.cameras[thisComputer].y))", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:50), text:"Z: \(Int(BackgroundLayer.cameras[thisComputer].z))", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:60), text:"Pitch: \(BackgroundLayer.cameras[thisComputer].pitch)", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:70), text:"Yaw: \(BackgroundLayer.cameras[thisComputer].yaw)", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:80), text:"Framerate: \(8/BackgroundLayer.computerCount)", fillMode:.fill))
                    canvas.render(Text(location:Point(x:20, y:90), text:"Currently Loaded Regions: \(BackgroundLayer.background.loadedRegions())", fillMode:.fill))
                    if let currentBlock = BackgroundLayer.background.getBlock(at:BlockPoint3d(x:Int(BackgroundLayer.cameras[thisComputer].x),
                                                                                              y:Int(BackgroundLayer.cameras[thisComputer].y),
                                                                                              z:Int(BackgroundLayer.cameras[thisComputer].z))) {
                        canvas.render(Text(location:Point(x:20, y:100), text:"Current block: \(currentBlock.type)", fillMode:.fill))
                    }
                    canvas.render(Text(location:Point(x:20, y:canvas.canvasSize!.height-20), text:">\(command)", fillMode:.fill))
                }
                BackgroundLayer.chat.render(canvas:canvas)
            }
        } else {
            clearCanvas(canvas:canvas)
            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            Text(location:Point(x:0, y:0), text:"").alignment = .center
            Text(location:Point(x:0, y:0), text:"").font = "36pt Arial"
            let initPrompt = Text(location:Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2-12), text:"Please Enter a Username: \(initString)")
            initPrompt.alignment = .center
            initPrompt.font = "16pt Arial"
            canvas.render(initPrompt)
            let onlineText = Text(location:Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2 + 12), text:"Users online:")
            onlineText.font = "12pt Arial"
            canvas.render(onlineText)
            for user in 0 ..< BackgroundLayer.usernames.count {
                canvas.render(Text(location:Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2 + 24 + 12*user), text:"\(BackgroundLayer.usernames[user])"))
            }
        }
    }
}
