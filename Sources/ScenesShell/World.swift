import Igis
import Scenes

class World {
    var regions : [kiloChunk]
    var unloadedRegions : [kiloChunk]
    var renderDistance : Int
    let regionSize = 4

    init() {
        regions = []
        unloadedRegions = []
        renderDistance = 96
    }

    func addRegion(_ region:kiloChunk) {
        regions.append(region)
    }

    func blocksSortedByDistance(camera:Camera) -> [Block] {
        var sortingArray: [Block] = []
        var workingArray: [Double] = []

        for region in regions {
            for chunk in region.getChunkArray() {
                for block in chunk.getBlockArray() {
                    sortingArray.append(block)
                    workingArray.append((block.location.convertToDouble().distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z))))
                }
            }
        }

        return mergeSort(sortingArray, by:workingArray) as! [Block]
    }

    func getKiloChunk(at:BlockPoint3d) -> kiloChunk? {
        var output : kiloChunk? = nil
        for kiloChunk in regions {
            if kiloChunk.location.isEqual(to:at) {
                output = kiloChunk
            }
        }

        return output
    }

    func getChunk(at:BlockPoint3d) -> Chunk? {
        var output : Chunk? = nil
        if let kiloChunk = getKiloChunk(at:BlockPoint3d(x:at.x/regionSize,
                                                        y:at.y/regionSize,
                                                        z:at.z/regionSize)) {
            for chunk in kiloChunk.getChunkArray() {
                if chunk.location.isEqual(to:at) {
                    output = chunk
                }
            }
        }

        return output
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        var output : Block? = nil
        if let chunk = getChunk(at:BlockPoint3d(x:at.x/regionSize,
                                                y:at.y/regionSize,
                                                z:at.z/regionSize)) {
            for block in chunk.getBlockArray() {
                if block.location.isEqual(to:at) {
                    output = block
                }
            }
        }
        return output
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        updateLoadedRegions(camera:camera)
        if regions.count > 0 {
            var sorted = self.blocksSortedByDistance(camera:camera)
            sorted = sorted.reversed()
            var nearest: [Block] = []
            var blocksRendered = 0
            var index = 0
            
            while blocksRendered < renderDistance && index < renderDistance*4 {
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
        /*
        regions.forEach {
            $0.renderBounds(canvas:canvas, camera:camera)
        }
        */
    }

    func loadedRegions() -> Int {
        return regions.count
    }

    private func unloadAll() {
        regions.forEach {
            unloadedRegions.append($0)
        }

        regions = []
    }
    
    func updateLoadedRegions(camera:Camera) {
        unloadAll()
        let unsortedRegions : [kiloChunk] = unloadedRegions

        var workingArray : [Double] = []
        unsortedRegions.forEach {
            workingArray.append($0.center().distanceFrom(point:Point3d(x:camera.x, y:camera.y, z:camera.z)))
        }

        var sortedRegions = mergeSort(unsortedRegions, by:workingArray) as! [kiloChunk]
        sortedRegions = sortedRegions.reversed()
        let maxLoad = 2

        for _ in 0 ..< maxLoad {
            regions.append(sortedRegions[0])
            sortedRegions.remove(at:0)
        }

        unloadedRegions = sortedRegions
    }
}
