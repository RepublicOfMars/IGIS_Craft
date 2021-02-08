import Igis
import Scenes
import Foundation

func degToRad(_ deg:Double) -> Double {
    return Double(deg) * (Double.pi/180.0)
}

class Point3d {
    var x : Double
    var y : Double
    var z : Double

    init(x:Double, y:Double, z:Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    func distanceFrom(point:Point3d) -> Double { //returns distance from a given point
        return sqrt((self.x-point.x)*(self.x-point.x)+(self.y-point.y)*(self.y-point.y)+(self.z-point.z)*(self.z-point.z))
    }

    func relativeLocation(camera:Camera) -> Point3d { //returns location of the 3d Point relative to a camera
        let relativePos = Point3d(x:(self.x-camera.x), y:(self.y-camera.y), z:(self.z-camera.z)) //relative position, not accounting for rotation

        let relativePos2 = Point3d(x:0, y:relativePos.y, z:0) //relative position, not accounting for pitch
        relativePos2.x = relativePos.x*cos(degToRad(camera.yaw))+relativePos.z*sin(degToRad(camera.yaw))
        relativePos2.z = relativePos.z*cos(degToRad(camera.yaw))-relativePos.x*sin(degToRad(camera.yaw))

        let relativePosFinal = Point3d(x:relativePos2.x, y:0, z:0) //relative position
        relativePosFinal.z = relativePos2.z*cos(degToRad(camera.pitch))+relativePos2.y*sin(degToRad(camera.pitch))
        relativePosFinal.y = relativePos2.y*cos(degToRad(camera.pitch))-relativePos2.z*sin(degToRad(camera.pitch))

        return relativePosFinal
    }

    /*
    func actualLocation(camera:Camera) -> Point3d { //returns location of a 3d Point, from relative location to actual location
        let actualPos = Point3d(x:self.x, y:0, z:0) //relative position, not accounting for pitch
        actualPos.z = self.z
    }
    */

    func flatten(camera:Camera, canvas:Canvas) -> Point? { //converts the 3d Point to an IGIS Point for rendering
        let canvasSize = canvas.canvasSize!
        let relativeLocation = self.relativeLocation(camera:camera)
        if relativeLocation.z > 0.2 {
            let point2d = Point(x:(Int((relativeLocation.x/(-relativeLocation.z)) * Double(canvasSize.height))) + canvasSize.width/2,
                                y:(Int((relativeLocation.y/(-relativeLocation.z)) * Double(canvasSize.height))) + canvasSize.height/2)
            return point2d
        } else {
            return nil
        }
    }
}

class BlockPoint3d { //Used for blocks. when converting to normal Point3d, adds 0.5 to each axis
    var x : Int
    var y : Int
    var z : Int

    init(x:Int, y:Int, z:Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    func convertToDouble() -> Point3d {
        return Point3d(x:Double(x)+0.5, y:Double(y)+0.5, z:Double(z)+0.5)
    }
}
