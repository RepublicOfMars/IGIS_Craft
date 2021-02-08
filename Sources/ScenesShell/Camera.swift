import Igis
import Scenes

class Camera {
    var x : Double
    var y : Double
    var z : Double

    var pitch : Double
    var yaw : Double

    init() {
        x = 0
        y = 0
        z = 0
        
        pitch = 0
        yaw = 0
    }

    func correctRotation() {
        if pitch > 90 {
            pitch = 90
        }
        if pitch < -90 {
            pitch = -90
        }
        
        if yaw > 180 {
            yaw -= 360
        }
        if yaw < -180 {
            yaw += 360
        }
    }

    func move(x:Double=0, y:Double=0, z:Double=0) {
        self.x += x
        self.y += y
        self.z += z
    }

    func rotate(pitch:Double=0, yaw:Double=0) {
        self.pitch += pitch
        self.yaw += yaw
        
        self.correctRotation()
    }
}
