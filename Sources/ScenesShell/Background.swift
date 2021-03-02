import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */


class Background : RenderableEntity {
    static var world = World()

    init(seed:Int=0) {
        // Using a meaningful name can be helpful for debugging
        let worldSize = (x:4, y:4, z:4)
        let totalChunks = worldSize.x * worldSize.y * worldSize.z
        var chunksGenerated = 0
        
        print("Chunks to Generate: \(totalChunks)...")
        for y in 0 ... worldSize.y-1 {
            for x in 0 ... worldSize.x-1 {
                for z in 0 ... worldSize.z-1 {
                    Background.world.addChunk(chunk:Chunk(location:BlockPoint3d(x:x, y:y, z:z), chunkSize:4, seed:seed))
                    chunksGenerated += 1
                }
            }
        }
        for x in 0 ..< 4 * worldSize.x {
            for z in 0 ..< 4 * worldSize.z {
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
        print("Chunks Generated.")
        
        super.init(name:"Background")
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        Background.world.renderWorld(camera:camera, canvas:canvas)
    }
}
