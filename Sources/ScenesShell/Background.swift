import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */


class Background : RenderableEntity {
    let camera = Camera()
    var sky = Rectangle(rect:Rect(), fillMode:.fillAndStroke)

    init() {
        // Using a meaningful name can be helpful for debugging
        
        super.init(name:"Background")
    }

    override func render(canvas:Canvas) {
        sky = Rectangle(rect:Rect(topLeft:Point(x:0, y:0), size:canvas.canvasSize!))
        
        canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
        canvas.render(FillStyle(color:Color(red:128, green:128, blue:196)))
        canvas.render(sky)
        
        canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
        canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))      
        
        Block(location:BlockPoint3d(x:0, y:-2, z:5)).renderBlock(camera:camera, canvas:canvas)        
        canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
        canvas.render(Text(location:Point(x:20, y:20), text:"Camera Position:", fillMode:.fill))
        canvas.render(Text(location:Point(x:20, y:30), text:"X: \(Int(camera.x))", fillMode:.fill))
        canvas.render(Text(location:Point(x:20, y:40), text:"Y: \(Int(camera.y))", fillMode:.fill))
        canvas.render(Text(location:Point(x:20, y:50), text:"Z: \(Int(camera.z))", fillMode:.fill))
        canvas.render(Text(location:Point(x:20, y:60), text:"Pitch: \(camera.pitch)", fillMode:.fill))
        canvas.render(Text(location:Point(x:20, y:70), text:"Yaw: \(camera.yaw)", fillMode:.fill))
    }

    func cameraRotateLeft() {
        camera.rotate(yaw:-2.0)
    }

    func cameraRotateRight() {
        camera.rotate(yaw:2.0)
    }

    func cameraRotateUp() {
        camera.rotate(pitch:2.0)
    }

    func cameraRotateDown() {
        camera.rotate(pitch:-2.0)
    }

    func cameraForward() {
        camera.move(z:0.125)
    }

    func cameraBackward() {
        camera.move(z:-0.125)
    }

    func cameraLeft() {
        camera.move(x:0.125)
    }

    func cameraRight() {
        camera.move(x:-0.125)
    }
}
