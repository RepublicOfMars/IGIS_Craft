import Igis
import Scenes

  /*
     This class is responsible for the background Layer.
     Internally, it maintains the RenderableEntities for this layer.
   */


class BackgroundLayer : Layer, KeyDownHandler, KeyUpHandler {
    let background = Background()
    var cameraIsRotating = (up:false, down:false, left:false, right:false)
    var cameraIsMoving = (forward:false, backward:false, left:false, right:false)

    init() {
        // Using a meaningful name can be helpful for debugging
        super.init(name:"Background")

        // We insert our RenderableEntities in the constructor
        insert(entity:background, at:.back)
    }

    override func preSetup(canvasSize:Size, canvas:Canvas) {
        dispatcher.registerKeyDownHandler(handler: self)
        dispatcher.registerKeyUpHandler(handler: self)
    }

    override func preCalculate(canvas:Canvas) {
        if cameraIsRotating.up{background.cameraRotateUp()}
        if cameraIsRotating.down{background.cameraRotateDown()}
        if cameraIsRotating.left{background.cameraRotateLeft()}
        if cameraIsRotating.right{background.cameraRotateRight()}
        if cameraIsMoving.forward{background.cameraForward()}
        if cameraIsMoving.backward{background.cameraBackward()}
        if cameraIsMoving.left{background.cameraLeft()}
        if cameraIsMoving.right{background.cameraRight()}
    }

    override func postTeardown() {
        dispatcher.unregisterKeyDownHandler(handler: self)
        dispatcher.unregisterKeyUpHandler(handler: self)
    }

    func onKeyDown(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
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
        default:
            print("Invalid Key '\(key)'")
        }
    }

    func onKeyUp(key:String, code:String, ctrlKey:Bool, shiftKey:Bool, altKey:Bool, metaKey:Bool) {
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
        default:
            print("Invalid Key '\(key)'")
        }
    }
}
