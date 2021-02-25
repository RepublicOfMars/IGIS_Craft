import Igis
import Scenes

  /*
     This class is responsible for the background Layer.
     Internally, it maintains the RenderableEntities for this layer.
   */


class BackgroundLayer : Layer, KeyDownHandler, KeyUpHandler {
    static let background = Background()
    static var cameras : [Camera] = []
    static var computerCount = 0
    var thisComputer = 0
    var computerIsActive = false
    var username = ""
    static var usernames : [String] = []

    static var renderingComputer = 0

    var initString = ""
    
    var cameraIsRotating = (up:false, down:false, left:false, right:false)
    var cameraIsMoving = (forward:false, backward:false, left:false, right:false, up:false, down:false)
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
        
        BackgroundLayer.cameras[thisComputer].move(y:14)
    }
    
    override func preSetup(canvasSize:Size, canvas:Canvas) {
        dispatcher.registerKeyDownHandler(handler: self)
        dispatcher.registerKeyUpHandler(handler: self)
    }

    override func preCalculate(canvas:Canvas) {
        if computerIsActive {
            var multiplier = 1.0
            if cameraIsSprinting{multiplier = 2}
            
            if cameraIsRotating.up{BackgroundLayer.cameras[thisComputer].cameraRotateUp()}
            if cameraIsRotating.down{BackgroundLayer.cameras[thisComputer].cameraRotateDown()}
            if cameraIsRotating.left{BackgroundLayer.cameras[thisComputer].cameraRotateLeft()}
            if cameraIsRotating.right{BackgroundLayer.cameras[thisComputer].cameraRotateRight()}
            
            if cameraIsMoving.forward{BackgroundLayer.cameras[thisComputer].cameraForward(multiplier)}
            if cameraIsMoving.backward{BackgroundLayer.cameras[thisComputer].cameraBackward(multiplier)}
            if cameraIsMoving.left{BackgroundLayer.cameras[thisComputer].cameraLeft(multiplier)}
            if cameraIsMoving.right{BackgroundLayer.cameras[thisComputer].cameraRight(multiplier)}
            
            if cameraIsFlying{
                if cameraIsMoving.up{BackgroundLayer.cameras[thisComputer].cameraUp(multiplier)}
                if cameraIsMoving.down{BackgroundLayer.cameras[thisComputer].cameraDown(multiplier)}
            }
        }
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
        dispatcher.unregisterKeyUpHandler(handler: self)
    }

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
        if computerIsActive {
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
                cameraIsMoving.forward = true
            case "KeyS":
                cameraIsMoving.backward = true
            case "KeyA":
                cameraIsMoving.left = true
            case "KeyD":
                cameraIsMoving.right = true
            case "KeyZ":
                cameraIsMoving.down = true
            case "KeyC":
                cameraIsMoving.up = true
            case "ShiftLeft":
                cameraIsSprinting = true
            case "KeyR":
                cameraIsRotating.up = false
                cameraIsRotating.down = false
                cameraIsRotating.left = false
                cameraIsRotating.right = false
                cameraIsMoving.left = false
                cameraIsMoving.right = false
                cameraIsMoving.down = false
                cameraIsMoving.up = false
                cameraIsSprinting = false
            default:
                print("", terminator:"")
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
                cameraIsMoving.forward = false
            case "KeyS":
                cameraIsMoving.backward = false
            case "KeyA":
                cameraIsMoving.left = false
            case "KeyD":
                cameraIsMoving.right = false
            case "KeyZ":
                cameraIsMoving.down = false
            case "KeyC":
                cameraIsMoving.up = false
            case "ShiftLeft":
                cameraIsSprinting = false
            default:
                print("", terminator:"")
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
                canvas.render(sky)
                
                canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
                canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))
                
                BackgroundLayer.background.renderWorld(camera:BackgroundLayer.cameras[thisComputer], canvas:canvas)

                for player in 0 ..< BackgroundLayer.computerCount {
                    if player != thisComputer {
                        if let playerLocation = BackgroundLayer.cameras[player].getLocation().flatten(camera:BackgroundLayer.cameras[thisComputer], canvas:canvas) {
                            Cube(center:BackgroundLayer.cameras[player].getLocation()).renderCube(camera:BackgroundLayer.cameras[thisComputer],
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
                canvas.render(Text(location:Point(x:20, y:80), text:"Framerate: \(14/BackgroundLayer.computerCount)", fillMode:.fill))
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
