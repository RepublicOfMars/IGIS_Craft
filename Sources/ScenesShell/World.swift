import Igis
import Scenes

class World {
    var chunks : [Chunk]
    var unloadedChunks : [Chunk]
    var renderDistance : Int
    let chunkSize = 4

    init() {
        chunks = []
        unloadedChunks = []
        renderDistance = 96
    }

    func addChunk(chunk: Chunk) {
        chunks.append(chunk)
    }

    func blocksSortedByDistance(camera:Camera) -> [Block] {
        var sortingArray: [Block] = []
        var workingArray: [Double] = []

        for chunk in chunks {
            for block in chunk.getBlockArray() {
                sortingArray.append(block)
                workingArray.append((block.location.convertToDouble().distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z))))
            }
        }

        return mergeSort(sortingArray, by:workingArray) as! [Block]
    }

    func getChunk(at:BlockPoint3d) -> Chunk? {
        var output : Chunk? = nil
        for chunk in chunks {
            if chunk.location.isEqual(to:at) {
                output = chunk
            }
        }

        return output
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        var output : Block? = nil
        if let chunk = getChunk(at:BlockPoint3d(x:at.x/chunkSize,
                                                y:at.y/chunkSize,
                                                z:at.z/chunkSize)) {
            for block in chunk.getBlockArray() {
                if block.location.isEqual(to:at) {
                    output = block
                }
            }
        }
        return output
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        updateLoadedChunks(camera:camera)
        
        var sorted = self.blocksSortedByDistance(camera:camera)
        sorted = sorted.reversed()
        var nearest: [Block] = []
        var blocksRendered = 0
        var index = 0
        
        while blocksRendered < renderDistance && index < sorted.count {
            if sorted[index].type != "air" {
                nearest.append(sorted[index])
                blocksRendered += 1
            }
            index += 1
        }
        nearest = nearest.reversed()
        for block in nearest {
            block.renderBlock(camera:camera, canvas:canvas)
        }
    }

    func updateLoadedChunks(camera:Camera) {
        
        let cameraLocation = BlockPoint3d(x:Int(camera.x), y:Int(camera.y), z:Int(camera.z))

        var chunksToLoad:[Int] = []
        var chunksToUnload:[Int] = []
        
        for index in 0 ..< chunks.count {
            if chunks[index].location.x*chunkSize >= cameraLocation.x+(3*chunkSize) ||
                 chunks[index].location.x*chunkSize <= cameraLocation.x-(3*chunkSize) ||
                 chunks[index].location.y*chunkSize >= cameraLocation.y+(3*chunkSize) ||
                 chunks[index].location.y*chunkSize <= cameraLocation.y-(3*chunkSize) ||
                 chunks[index].location.z*chunkSize >= cameraLocation.z+(3*chunkSize) ||
                 chunks[index].location.z*chunkSize <= cameraLocation.z-(3*chunkSize) {
                //if a chunk is out of loading range (+/- 3 chunks) it will unload
                chunksToUnload.append(index)
            }
        }

        var chunksUnloaded = 0
        for unloadingIndex in chunksToUnload {
            unloadedChunks.append(chunks[unloadingIndex-chunksUnloaded])
            chunks.remove(at:unloadingIndex-chunksUnloaded)
            chunksUnloaded += 1
        }

        for index in 0 ..< unloadedChunks.count {
            if unloadedChunks[index].location.x*chunkSize+chunkSize >= cameraLocation.x-(3*chunkSize) &&
                 unloadedChunks[index].location.x*chunkSize <= cameraLocation.x+(3*chunkSize) &&
                 unloadedChunks[index].location.y*chunkSize+chunkSize >= cameraLocation.y-(3*chunkSize) &&
                 unloadedChunks[index].location.y*chunkSize <= cameraLocation.y+(3*chunkSize) &&
                 unloadedChunks[index].location.z*chunkSize+chunkSize >= cameraLocation.z-(3*chunkSize) &&
                 unloadedChunks[index].location.z*chunkSize <= cameraLocation.z+(3*chunkSize) {
                //if an unloaded chunk is within loading range (+/- 3 chunks) it will load
                chunksToLoad.append(index)
            }
        }

        var chunksLoaded = 0
        for loadingIndex in chunksToLoad {
            chunks.append(unloadedChunks[loadingIndex-chunksLoaded])
            unloadedChunks.remove(at:loadingIndex-chunksLoaded)
            chunksLoaded += 1
        }
    }
}
