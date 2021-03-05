import Igis
import Scenes

class Chunk {
    var Blocks : [[[Block]]]
    var location : BlockPoint3d
    let chunkSize : Int

    init(location:BlockPoint3d, chunkSize:Int, seed:Int=0) {
        Blocks = []
        self.location = location
        self.chunkSize = chunkSize
        
        for y in 0 ..< chunkSize {
            Blocks.append([])
            for _ in 0 ..< chunkSize {
                Blocks[y].append([])
            }
        }
        
        for x in 0 ..< chunkSize {
            for z in 0 ..< chunkSize {
                let terrainHeight = 32 + Int(8.0*(Noise(x:x+(self.location.x*self.chunkSize), z:z+(self.location.z*self.chunkSize), seed:seed)))
                for y in 0 ..< chunkSize {
                    let cave = Int(8.0*Noise3d(x:x+(self.location.x*self.chunkSize),
                                               y:y+(self.location.y*self.chunkSize),
                                               z:z+(self.location.z*self.chunkSize)))
                    var type = "air"
                    if cave > -4 {
                        if y + self.location.y*self.chunkSize <= 0 {
                            type = "bedrock"
                        } else if y + self.location.y*self.chunkSize <= terrainHeight-3 {
                            type = "stone"
                            if y + self.location.y*self.chunkSize <= 8 && Int.random(in:1...128) == 1 {
                                type = "diamond_ore"
                            }
                            if y + self.location.y*self.chunkSize <= 16 && Int.random(in:1...64) == 1 {
                                type = "iron_ore"
                            }
                        } else if y + self.location.y*self.chunkSize <= terrainHeight-1 {
                            type = "dirt"
                        } else if y + self.location.y*self.chunkSize <= terrainHeight {
                            type = "grass"
                        }
                    }
                    
                    Blocks[y][x].append(Block(location:BlockPoint3d(x:x+(location.x*chunkSize),
                                                                    y:y+(location.y*chunkSize),
                                                                    z:z+(location.z*chunkSize)),
                                              type:type))
                }
            }
        }
    }

    func distanceToCenter(camera:Camera) -> Double {
        return Point3d(x:Double(self.location.x+(chunkSize/2)),
                       y:Double(self.location.y+(chunkSize/2)),
                       z:Double(self.location.z+(chunkSize/2))).distanceFrom(point:Point3d(x:camera.x,
                                                                                            y:camera.y,
                                                                                            z:camera.z))
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

    func blockCount() -> Int {
        return self.getBlockArray().count
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        var output : Block? = nil
        getBlockArray().forEach {
            if $0.location.isEqual(to:at) {
                output = $0
            }
        }
        return output
    }
}
