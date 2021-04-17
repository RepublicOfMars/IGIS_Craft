import Igis
import Scenes
import Foundation

//in Igis, the turtle can be rendered, however, in Igis_Craft, the turtle is simply a moving point
//useful for tracking moving things that aren't cameras

class Turtle3d {
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
    
    func rotate(pitch:Double=0, yaw:Double=0) {
        self.pitch += pitch
        self.yaw += yaw
    }
    
    func absVal(_ n: Double) -> Double {
        if n < 0 {
            return -1 * n
        }
        return n
    }
    
    func forward(steps:Double) {
        //steps is a 3d vector
        //need to find x, y, z movement
        //know angle to z axis (yaw), and angle to horizontal plane (pitch)

        correctRotation()
        
        //break up vertical & horizontal movement
        let verticalAngle = absVal(pitch)
        let horizontal = steps * cos(degToRad(verticalAngle))
        var yMovement = steps * sin(degToRad(verticalAngle))
        if pitch < 0 {
            yMovement *= -1
        }
        y += yMovement
        
        //break up horizontal movement to x & z movement
        var rotation = yaw + 360

        while rotation >= 360 {
            rotation -= 360
        }

        assert(rotation >= 0)
        assert(rotation < 360)
        
        if rotation < 90 {
            let angleFromForward = rotation
            x += -(horizontal*sin(degToRad(angleFromForward)))
            z += (horizontal*cos(degToRad(angleFromForward)))
        } else if rotation < 180 {
            let angleFromForward = 180-rotation
            x += -(horizontal*sin(degToRad(angleFromForward)))
            z += -(horizontal*cos(degToRad(angleFromForward)))
        } else if rotation < 270 {
            let angleFromBack = -(180-rotation)
            x += (horizontal*sin(degToRad(angleFromBack)))
            z += -(horizontal*cos(degToRad(angleFromBack)))
        } else {
            let angleFromForward = 360-rotation
            x += (horizontal*sin(degToRad(angleFromForward)))
            z += (horizontal*cos(degToRad(angleFromForward)))
        }
    }
}
