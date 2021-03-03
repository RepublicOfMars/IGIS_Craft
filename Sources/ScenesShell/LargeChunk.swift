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
        return Point3d(x:Double(location.x*(kiloChunkSize*kiloChunkSize)+kiloChunkSize/2),
                       y:Double(location.y*(kiloChunkSize*kiloChunkSize)+kiloChunkSize/2),
                       z:Double(location.z*(kiloChunkSize*kiloChunkSize)+kiloChunkSize/2))
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
}
