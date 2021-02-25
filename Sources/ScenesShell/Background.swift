import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */


class Background : RenderableEntity {
    static var world = World()

    init() {
        // Using a meaningful name can be helpful for debugging
        let worldSize = (x:8, y:4, z:8)
        let totalChunks = worldSize.x * worldSize.y * worldSize.z
        var chunksGenerated = 0
        
        for y in 0 ... worldSize.y-1 {
            for x in 0 ... worldSize.x-1 {
                for z in 0 ... worldSize.z-1 {
                    Background.world.addChunk(chunk:Chunk(location:BlockPoint3d(x:x, y:y, z:z), chunkSize:4))
                    chunksGenerated += 1
                }
                print("Chunks Generated: \(chunksGenerated)/\(totalChunks), \((chunksGenerated*100)/totalChunks)% loaded.")
            }
        }
        
        super.init(name:"Background")
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        Background.world.renderWorld(camera:camera, canvas:canvas)
    }
}
