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

        sides.append(Square(center:Point3d(x:center.x+(size/2),y:center.y,z:center.z), axis:"x"))
        sides.append(Square(center:Point3d(x:center.x-(size/2),y:center.y,z:center.z), axis:"x"))
        sides.append(Square(center:Point3d(x:center.x,y:center.y+(size/2),z:center.z), axis:"y"))
        sides.append(Square(center:Point3d(x:center.x,y:center.y-(size/2),z:center.z), axis:"y"))
        sides.append(Square(center:Point3d(x:center.x,y:center.y,z:center.z+(size/2)), axis:"z"))
        sides.append(Square(center:Point3d(x:center.x,y:center.y,z:center.z-(size/2)), axis:"z"))

        return sides
    }

    func sortByDistance(_ sortingSquares:inout [Square], camera:Camera) {
        var sorted = false

        func swap(_ first:Int, _ second:Int, _ arr:inout [Square]) {
            if first != second {
                let temp = arr[second]
                arr[second] = arr[first]
                arr[first] = temp
            }
        }
        
        while !sorted {
            var swaps = 0
            
            for index in 0 ..< sortingSquares.count-1 {
                if sortingSquares[index].center.distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z)) <
                     sortingSquares[index+1].center.distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z)) {
                    swap(index, index+1, &sortingSquares)
                    swaps += 1
                }
            }

            if swaps == 0 {
                sorted = true
            }
        }
    }

    func renderCube(camera:Camera, canvas:Canvas) {
        var sides = self.getSquares()
        
        sortByDistance(&sides, camera:camera)

        //sort sides by distance
        
        for square in sides {
            square.renderSquare(camera:camera, canvas:canvas)
        }
    }
}
