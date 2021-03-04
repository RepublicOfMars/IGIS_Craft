import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */

class generatingMap {
    var map : [[String]]
    let size : (x:Int, z:Int)

    init(x:Int, z:Int) {
        size = (x:x, z:z)
        map = []
        for x in 0 ..< size.x*2 {
            map.append([])
            for _ in 0 ..< size.z*2 {
                map[x].append("  ")
            }
        }
    }

    func changePixel(x:Int, z:Int, to:String) {
        map[x][z] = to
    }

    func render() {
        for _ in 0 ..< 64 {
            print("")
        }
        for x in 0 ..< size.x*2 {
            for z in 0 ..< size.z*2 {
                print(map[x][z], terminator:"")
            }
            print("")
        }
    }
}

class Background : RenderableEntity {
    static var world = World()

    init(seed:Int=0) {
        // Using a meaningful name can be helpful for debugging
        let worldSize = (x:16, y:4, z:16)
        let totalRegions = worldSize.x * worldSize.y * worldSize.z
        var regionsGenerated = 0

        let loading = generatingMap(x:worldSize.x, z:worldSize.z)
        
        print("Regions to Generate: \(totalRegions)...")
        for x in -worldSize.x/2 ..< worldSize.x/2 {
            for z in -worldSize.z/2 ..< worldSize.z/2 {
                for y in 0 ..< worldSize.y {
                    Background.world.addRegion(kiloChunk(location:BlockPoint3d(x:x, y:y, z:z), kiloChunkSize:4, seed:seed))
                    regionsGenerated += 1
                }
                
                for subRegionX in 0 ... 1 {
                    for subRegionZ in 0 ... 1 {
                        let terrainHeight = Int(8.0*(+Noise(x:x*16+subRegionX*2, z:z*16+subRegionZ*2, seed:seed)))
                        var mapString = "  "
                        if terrainHeight >= 4 {
                            mapString = "██"
                        } else if terrainHeight >= 2 {
                            mapString = "▓▓"
                        } else if terrainHeight >= 0 {
                            mapString = "▒▒"
                        } else if terrainHeight >= -2 {
                            mapString = "░░"
                        }
                        loading.changePixel(x:(x+worldSize.x/2)*2+(subRegionX), z:(z+worldSize.z/2)*2+(subRegionZ), to:mapString)
                    }
                }
                loading.render()
                print("\((regionsGenerated*100)/totalRegions)%")
            }
        }
        print("World Generated. Size: x:\(worldSize.x*16), y:\(worldSize.y*16), z:\(worldSize.z*16)")
        print("World Bounds: ")
        print("x: \(-(worldSize.x/2)*16), \((worldSize.x/2)*16)")
        print("y: 0, \((worldSize.y*16))")
        print("z: \(-(worldSize.z/2)*16), \((worldSize.z/2)*16)")
        
        super.init(name:"Background")
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        Background.world.renderWorld(camera:camera, canvas:canvas)
    }

    func loadedRegions() -> Int {
        return Background.world.loadedRegions()
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        return Background.world.getBlock(at:at)
    }
}
