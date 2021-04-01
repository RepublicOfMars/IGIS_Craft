import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */

class generatingMap {
    var map : [[Int]]
    let size : (x:Int, z:Int)

    init(x:Int, z:Int) {
        size = (x:x, z:z)
        map = []
        for x in 0 ..< size.x {
            map.append([])
            for _ in 0 ..< size.z {
                map[x].append(0)
            }
        }
    }

    func changePixel(x:Int, z:Int, to:Int) {
        map[x][z] = to
    }
}

class Background : RenderableEntity {
    static var world = World()
    static var seed : Int = 0
    public let worldSize = (x:16, y:4, z:16)
    let regionsToGenerate : Int
    static var regionsGenerated = 0

    public static var generated = false
    var generatingRegion = (x:0, y:0, z:0)
    var map : generatingMap

    init(seed:Int=0) {
        regionsToGenerate = worldSize.x * worldSize.y * worldSize.z
        map = generatingMap(x:worldSize.x*4, z:worldSize.z*4)
        // Using a meaningful name can be helpful for debugging
        Background.seed = seed
        /*
        let totalRegions = worldSize.x * worldSize.y * worldSize.z
        var regionsGenerated = 0
        
        //let loading = generatingMap(x:worldSize.x, z:worldSize.z)
        
        print("Regions to Generate: \(totalRegions)...")
        for x in 0 ..< worldSize.x {
            for z in 0 ..< worldSize.z {
                for y in 0 ..< worldSize.y {
                    Background.world.addRegion(kiloChunk(location:BlockPoint3d(x:x, y:y, z:z), kiloChunkSize:4, seed:seed))
                    regionsGenerated += 1
                }
                print("generated region at: \(x), \(z)")
                print("\((regionsGenerated*100)/totalRegions)%")
            }
        }
        print("World Generated. Size: x:\(worldSize.x*16), y:\(worldSize.y*16), z:\(worldSize.z*16)")
        print("World Bounds: ")
        print("x: \(0), \(worldSize.x*16)")
        print("y: \(0), \((worldSize.y*16))")
        print("z: \(0), \(worldSize.z*16)")
         */
        super.init(name:"Background")
    }

    func stepGeneration(canvas:Canvas) {
        for y in 0 ..< worldSize.y {
            Background.world.addRegion(kiloChunk(location:BlockPoint3d(x:generatingRegion.x, y:y, z:generatingRegion.z), kiloChunkSize:4, seed:Background.seed))
            Background.regionsGenerated += 1

            for x in 0 ..< 4 {
                for z in 0 ..< 4 {
                    let height = Noise(x:(generatingRegion.x*16)+(x*4), z:(generatingRegion.z*16)+(z*4), seed:Background.seed)
                    map.changePixel(x:(generatingRegion.x*4)+x, z:(generatingRegion.z*4)+z, to:32+Int(8*height))
                }
            }
        }
        generatingRegion.x += 1
        if generatingRegion.x >= worldSize.x {
            generatingRegion.x = 0
            generatingRegion.z += 1
        }
        if generatingRegion.z >= worldSize.z {
            Background.generated = true
        }

        let regionMapSize = 4
        
        for x in 0 ..< map.map.count {
            for z in 0 ..< map.map[x].count {
                canvas.render(FillStyle(color:Color(.black)))
                if map.map[x][z] > 34 {
                    canvas.render(FillStyle(color:Color(red:0, green:196, blue:0)))
                } else if map.map[x][z] > 32 {
                    canvas.render(FillStyle(color:Color(red:0, green:180, blue:0)))
                } else if map.map[x][z] > 30 {
                    canvas.render(FillStyle(color:Color(red:0, green:164, blue:0)))
                } else if map.map[x][z] > 0 {
                    canvas.render(FillStyle(color:Color(red:0, green:148, blue:0)))
                }
                let center = Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2)
                let offset = Point(x:4*((map.size.x/2)-x-1), y:4*((map.size.z/2)-z-1))
                canvas.render(Rectangle(rect:Rect(topLeft:Point(x:center.x+offset.x, y:center.y+offset.y), size:Size(width:regionMapSize, height:regionMapSize)), fillMode:.fill))
            }
        }
        
    }

    func renderWorld(camera:Camera, canvas:Canvas) {
        if !Background.generated {
            stepGeneration(canvas:canvas)
            let text = Text(location:Point(x:canvas.canvasSize!.width/2, y:3*(canvas.canvasSize!.height/4)), text:"Generating World: \((Background.regionsGenerated*100)/regionsToGenerate)%")
            text.font = "\(canvas.canvasSize!.height/64)pt Arial"
            text.baseline = .middle
            text.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(text)
            
            let title = Text(location:Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height/4)), text:"IGIS_Craft")
            title.font = "\(canvas.canvasSize!.height/16)pt Arial"
            title.baseline = .middle
            title.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(title)
        } else {
            Background.world.renderWorld(camera:camera, canvas:canvas)
        }
    }

    func loadedRegions() -> Int {
        return Background.world.loadedRegions()
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        return Background.world.getBlock(at:at)
    }
}
