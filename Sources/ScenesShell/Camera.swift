import Igis
import Scenes
import Foundation

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

    func moveWithRotation(x:Double=0, y:Double=0, z:Double=0) {
        self.y += y
        
        var movement = (speed:0.0, rotation:0.0, x:0.0, z:0.0)
        movement.speed = sqrt((x*x)+(z*z))
        if x == 0 {
            if z > 0 {
                movement.rotation = (self.yaw+180.0)
            }
            if z < 0 {
                movement.rotation = (self.yaw+180.0) + 180.0
                if movement.rotation >= 360 {
                    movement.rotation -= 360
                }
            }
        }
        if z == 0 {
            if x > 0 {
                movement.rotation = (self.yaw+180.0) - 90
            }
            if x < 0 {
                movement.rotation = (self.yaw+180.0) + 90
            }
        }

        while movement.rotation >= 360 {
            movement.rotation -= 360
        }
        while movement.rotation < 0 {
            movement.rotation += 360
        }

        assert(movement.rotation >= 0)
        assert(movement.rotation < 360)
        
        if movement.rotation < 90 { //Note: "Forward" is positive z, and "Back" is negative z
            let angleFromForward = movement.rotation
            movement.x = -(movement.speed*sin(degToRad(angleFromForward))) //gets x motion from speed and angle
            movement.z = (movement.speed*cos(degToRad(angleFromForward))) //gets z motion from speed and angle
        }else if movement.rotation < 180 {
            let angleFromBack = 180-movement.rotation
            movement.x = -(movement.speed*sin(degToRad(angleFromBack)))
            movement.z = -(movement.speed*cos(degToRad(angleFromBack)))
        }else if movement.rotation < 270 {
            let angleFromBack = -(180-movement.rotation)
            movement.x = (movement.speed*sin(degToRad(angleFromBack)))
            movement.z = -(movement.speed*cos(degToRad(angleFromBack)))
        }else {
            let angleFromForward = 360-movement.rotation
            movement.x = (movement.speed*sin(degToRad(angleFromForward)))
            movement.z = (movement.speed*cos(degToRad(angleFromForward)))
        }

        self.move(x:-movement.x, z:-movement.z)
    }
    
    func rotate(pitch:Double=0, yaw:Double=0) {
        self.pitch += pitch
        self.yaw += yaw
        
        self.correctRotation()
    }

    func cameraRotateLeft(_ multiplier:Double=1) {
        self.rotate(yaw:-2.0*multiplier)
    }

    func cameraRotateRight(_ multiplier:Double=1) {
        self.rotate(yaw:2.0*multiplier)
    }

    func cameraRotateUp(_ multiplier:Double=1) {
        self.rotate(pitch:2.0*multiplier)
    }

    func cameraRotateDown(_ multiplier:Double=1) {
        self.rotate(pitch:-2.0*multiplier)
    }

    func cameraForward(_ multiplier:Double=1) {
        self.moveWithRotation(z:0.2*multiplier)
    }

    func cameraBackward(_ multiplier:Double=1) {
        self.moveWithRotation(z:-0.2*multiplier)
    }

    func cameraLeft(_ multiplier:Double=1) {
        self.moveWithRotation(x:0.2*multiplier)
    }

    func cameraRight(_ multiplier:Double=1) {
        self.moveWithRotation(x:-0.2*multiplier)
    }

    func cameraUp(_ multiplier:Double=1) {
        self.moveWithRotation(y:0.2*multiplier)
    }

    func cameraDown(_ multiplier:Double=1) {
        self.moveWithRotation(y:-0.2*multiplier)
    }

    func getLocation() -> Point3d {
        return Point3d(x:self.x, y:self.y, z:self.z)
    }
}
