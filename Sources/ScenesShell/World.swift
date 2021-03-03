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
        renderDistance = 64
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
            
            while blocksRendered < renderDistance && index < renderDistance*3 {
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
    }

    func updateLoadedRegions(camera:Camera) {
        let cameraLocation = BlockPoint3d(x:Int(camera.x), y:Int(camera.y), z:Int(camera.z))

        var regionsToLoad:[Int] = []
        var regionsToUnload:[Int] = []

        let loadingRange = 12
        
        for index in 0 ..< regions.count {
            if regions[index].location.x*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.x+loadingRange ||
                 regions[index].location.x*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.x-loadingRange ||
                 regions[index].location.y*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.y+loadingRange ||
                 regions[index].location.y*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.y-loadingRange ||
                 regions[index].location.z*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.z+loadingRange ||
                 regions[index].location.z*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.z-loadingRange {
                //if a chunk is out of loading range it will unload
                regionsToUnload.append(index)
            }
        }

        var regionsUnloaded = 0
        for unloadingIndex in regionsToUnload {
            unloadedRegions.append(regions[unloadingIndex-regionsUnloaded])
            regions.remove(at:unloadingIndex-regionsUnloaded)
            regionsUnloaded += 1
        }

        for index in 0 ..< unloadedRegions.count {
            if unloadedRegions[index].location.x*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.x-loadingRange &&
                 unloadedRegions[index].location.x*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.x+loadingRange &&
                 unloadedRegions[index].location.y*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.y-loadingRange &&
                 unloadedRegions[index].location.y*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.y+loadingRange &&
                 unloadedRegions[index].location.z*(regionSize*regionSize)+(regionSize*regionSize)/2 >= cameraLocation.z-loadingRange &&
                 unloadedRegions[index].location.z*(regionSize*regionSize)+(regionSize*regionSize)/2 <= cameraLocation.z+loadingRange {
                //if an unloaded chunk is within loading range it will load
                regionsToLoad.append(index)
            }
        }

        var regionsLoaded = 0
        for loadingIndex in regionsToLoad {
            regions.append(unloadedRegions[loadingIndex-regionsLoaded])
            unloadedRegions.remove(at:loadingIndex-regionsLoaded)
            regionsLoaded += 1
        }
    }

    func loadedRegions() -> Int {
        return regions.count
    }

    private func unloadAll() {
        for region in regions {
            unloadedRegions.append(region)
        }

        regions = []
    }

    /*
    func sortByDistance(camera:Camera) -> [kiloChunk] {
        unloadAll()
        var output : kiloChunk = unloadedRegions
    }
    
     */
}
