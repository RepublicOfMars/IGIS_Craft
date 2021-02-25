import Igis
import Scenes

class Chunk {
    var Blocks : [[[Block]]]
    var location : BlockPoint3d
    let chunkSize : Int

    init(location:BlockPoint3d, chunkSize:Int) {
        Blocks = []
        self.location = location
        self.chunkSize = chunkSize
        
        for y in 0 ..< chunkSize {
            Blocks.append([])
            for x in 0 ..< chunkSize {
                Blocks[y].append([])
                for z in 0 ..< chunkSize {
                    var type = "air"
                    if y + self.location.y*self.chunkSize <= 0 {
                        type = "bedrock"
                    } else if y + self.location.y*self.chunkSize <= 9 + Int.random(in:-1...1) {
                        type = "stone"
                        if y + self.location.y*self.chunkSize <= 4 && Int.random(in:1...128) == 1 {
                            type = "diamond_ore"
                        }
                        if y + self.location.y*self.chunkSize <= 8 && Int.random(in:1...64) == 1 {
                            type = "iron_ore"
                        }
                    } else if y + self.location.y*self.chunkSize <= 11 {
                        type = "dirt"
                    } else if y + self.location.y*self.chunkSize <= 12 {
                        type = "grass"
                    }
                    
                    Blocks[y][x].append(Block(location:BlockPoint3d(x:x+(location.x*chunkSize),
                                                                    y:y+(location.y*chunkSize),
                                                                    z:z+(location.z*chunkSize)),
                                              type:type))
                }
            }
        }
    }

    func getBlockArray() -> [Block] {
        var output : [Block] = []
        for y in 0 ..< self.Blocks.count {
            for x in 0 ..< self.Blocks.count {
                for z in 0 ..< self.Blocks.count {
                    output.append(self.Blocks[y][x][z])
                }
            }
        }
        return output
    }

    func sortedByDistance(camera:Camera) -> [Block] {
        let output : [Block] = self.getBlockArray()

        var workingArray : [Double] = []
        for block in output {
            workingArray.append(block.location.convertToDouble().distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z)))
        }
        
        return mergeSort(output, by:workingArray) as! [Block]
    }
}
