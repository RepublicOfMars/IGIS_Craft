import Igis
import Scenes

class Cube {
    var center : Point3d
    var size : Double

    init(center:Point3d, size:Double=1.0) {
        self.center = center
        self.size = size
    }

    func getSquares() -> [Square] { //get squares for sides of the cube
        var sides : [Square] = []

        sides.append(Square(center:Point3d(x:center.x+(size/2),y:center.y,z:center.z), axis:"x", size:size))
        sides.append(Square(center:Point3d(x:center.x-(size/2),y:center.y,z:center.z), axis:"x", size:size))
        sides.append(Square(center:Point3d(x:center.x,y:center.y+(size/2),z:center.z), axis:"y", size:size))
        sides.append(Square(center:Point3d(x:center.x,y:center.y-(size/2),z:center.z), axis:"y", size:size))
        sides.append(Square(center:Point3d(x:center.x,y:center.y,z:center.z+(size/2)), axis:"z", size:size))
        sides.append(Square(center:Point3d(x:center.x,y:center.y,z:center.z-(size/2)), axis:"z", size:size))

        return sides
    }

    func sortByDistance(_ sortingSquares:inout [Square], camera:Camera) {
        var workingArray:[Double] = []

        for square in sortingSquares {
            workingArray.append(square.center.distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z)))
        }

        sortingSquares = mergeSort(sortingSquares, by:workingArray) as! [Square]
    }

    func renderCube(camera:Camera, canvas:Canvas, color:Color, solid:Bool=true) {
        var sides = self.getSquares()
        
        sortByDistance(&sides, camera:camera)
        
        for square in sides {
            square.renderSquare(camera:camera, canvas:canvas, color:color, solid:solid)
        }
    }
}
