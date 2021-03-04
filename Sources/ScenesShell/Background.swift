import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */


class Background : RenderableEntity {
    static var world = World()

    init(seed:Int=0) {
        // Using a meaningful name can be helpful for debugging
        let worldSize = (x:8, y:4, z:8)
        let totalRegions = worldSize.x * worldSize.y * worldSize.z
        var regionsGenerated = 0
        
        print("Regions to Generate: \(totalRegions)...")
        for y in 0 ..< worldSize.y {
            for x in -worldSize.x/2 ..< worldSize.x/2 {
                for z in -worldSize.z/2 ..< worldSize.z/2 {
                    Background.world.addRegion(kiloChunk(location:BlockPoint3d(x:x, y:y, z:z), kiloChunkSize:4, seed:seed))
                    regionsGenerated += 1
                    print("\(regionsGenerated)/\(totalRegions): Region Generated at x:\(x*16), y:\(y*16), z:\(z*16)")
                }
            }
        }
        /*
        for x in 0 ..< 16 * worldSize.x {
            for z in 0 ..< 16 * worldSize.z {
                let terrainHeight = 32 + Int(8.0*(+Noise(x:x, z:z, seed:seed)))
                if terrainHeight >= 34 {
                    print("&&", terminator:"")
                } else if terrainHeight >= 32 {
                    print("==", terminator:"")
                } else if terrainHeight >= 30 {
                    print("--", terminator:"")
                } else {
                    print("  ", terminator:"")
                }
            }
            print("")
        }
         */
        print("World Generated. Size: x:\(worldSize.x*16), y:\(worldSize.y*16), z:\(worldSize.z*16)")
        
        super.init(name:"Background")
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        Background.world.renderWorld(camera:camera, canvas:canvas)
    }

    func loadedRegions() -> Int {
        return Background.world.loadedRegions()
    }
}
