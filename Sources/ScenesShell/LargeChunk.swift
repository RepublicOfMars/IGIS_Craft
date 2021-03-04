import Igis
import Scenes

class kiloChunk {
    var Chunks : [[[Chunk]]]
    var location : BlockPoint3d
    let kiloChunkSize : Int

    init(location:BlockPoint3d, kiloChunkSize:Int, seed:Int=0) {
        Chunks = []
        self.location = location
        self.kiloChunkSize = kiloChunkSize

        for y in 0 ..< kiloChunkSize {
            Chunks.append([])
            for x in 0 ..< kiloChunkSize {
                Chunks[y].append([])
                for z in 0 ..< kiloChunkSize {
                    Chunks[y][x].append(Chunk(location:BlockPoint3d(x:(x)+(location.x*kiloChunkSize),
                                                                    y:(y)+(location.y*kiloChunkSize),
                                                                    z:(z)+(location.z*kiloChunkSize)),
                                              chunkSize:kiloChunkSize,
                                              seed:seed))
                }
            }
        }
    }

    func center() -> Point3d {
        return Point3d(x:Double(location.x*(16)+8),
                       y:Double(location.y*(16)+8),
                       z:Double(location.z*(16)+8))
    }

    func getChunkArray() -> [Chunk] {
        var output : [Chunk] = []
        for y in 0 ..< self.Chunks.count {
            for x in 0 ..< self.Chunks.count {
                for z in 0 ..< self.Chunks.count {
                    output.append(self.Chunks[y][x][z])
                }
            }
        }
        return output
    }

    func sortedByDistance(camera:Camera) -> [Chunk] {
        let output : [Chunk] = self.getChunkArray()

        var workingArray : [Double] = []
        for chunk in output {
            workingArray.append(chunk.distanceToCenter(camera:camera))
        }

        return mergeSort(output, by:workingArray) as! [Chunk]
    }

    func renderBounds(canvas:Canvas, camera:Camera) {
        Cube(center:self.center(), size:16).renderCube(camera:camera, canvas:canvas, color:Color(red:0, green:0, blue:0), solid:false)
    }
}
