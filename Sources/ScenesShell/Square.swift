import Igis
import Scenes

class Square {
    var center : Point3d
    var axis : String //face of square is along this axis (x, y, z)
    var size : Double
    
    init(center:Point3d, axis:String, size:Double=1) {
        self.center = center
        self.axis = axis
        self.size = size
    }

    func getPath() -> Path3d {
        let square : Path3d = Path3d()
        if axis == "x" {
            square.lineTo(Point3d(x:center.x,y:center.y-(size/2),z:center.z-(size/2)))
            square.lineTo(Point3d(x:center.x,y:center.y-(size/2),z:center.z+(size/2)))
            square.lineTo(Point3d(x:center.x,y:center.y+(size/2),z:center.z+(size/2)))
            square.lineTo(Point3d(x:center.x,y:center.y+(size/2),z:center.z-(size/2)))
            square.lineTo(Point3d(x:center.x,y:center.y-(size/2),z:center.z-(size/2)))
        } else if axis == "y" {
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y, z:center.z-(size/2)))
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y, z:center.z+(size/2)))
            square.lineTo(Point3d(x:center.x+(size/2), y:center.y, z:center.z+(size/2)))
            square.lineTo(Point3d(x:center.x+(size/2), y:center.y, z:center.z-(size/2)))
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y, z:center.z-(size/2)))
        } else if axis == "z" {
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y-(size/2), z:center.z))
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y+(size/2), z:center.z))
            square.lineTo(Point3d(x:center.x+(size/2), y:center.y+(size/2), z:center.z))
            square.lineTo(Point3d(x:center.x+(size/2), y:center.y-(size/2), z:center.z))
            square.lineTo(Point3d(x:center.x-(size/2), y:center.y-(size/2), z:center.z))
        } else {
            fatalError("Square.swift: Unexpected axis '\(axis)'")
        }
        return square
    }

    func renderSquare(camera:Camera, canvas:Canvas, color:Color, solid:Bool=true) {
        self.getPath().renderPath(camera:camera, canvas:canvas, color:color, solid:solid)
    }
}
