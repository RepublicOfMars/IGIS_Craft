import Scenes
import Igis

/*
 This class is responsible for rendering the background.
 */

class Background : RenderableEntity {
    static var world = World()
    static var seed : Int = 0
    public let worldSize = (x:8, y:4, z:8)
    let regionsToGenerate : Int
    static var regionsGenerated = 0
    let splashTxt = splashText()

    public static var generated = false
    static var terrainGenerated = false
    var generatingRegion = (x:0, y:0, z:0)
    var treesGenerated = 0
    var treesToGenerate : Int
    var map : generatingMap
    var trees : [Point] = []
    
    let pixelsPerRegion = 1
    var frame = 0

    init(seed:Int=0) {
        regionsToGenerate = worldSize.x * worldSize.y * worldSize.z
        treesToGenerate = worldSize.x * worldSize.z * 2
        map = generatingMap(x:worldSize.x*pixelsPerRegion, z:worldSize.z*pixelsPerRegion)
        // Using a meaningful name can be helpful for debugging
        Background.seed = seed
        super.init(name:"Background")
    }

    func stepGeneration(canvas:Canvas) {
        if !Background.terrainGenerated {
            for y in 0 ..< worldSize.y {
                Background.world.addRegion(kiloChunk(location:BlockPoint3d(x:generatingRegion.x, y:y, z:generatingRegion.z), kiloChunkSize:4, seed:Background.seed))
                Background.regionsGenerated += 1

                for x in 0 ..< pixelsPerRegion {
                    for z in 0 ..< pixelsPerRegion {
                        let height = Noise(x:(generatingRegion.x*16)+(x*(16/pixelsPerRegion)), z:(generatingRegion.z*16)+(z*(16/pixelsPerRegion)), seed:Background.seed)
                        map.changePixel(x:(generatingRegion.x*(pixelsPerRegion))+x, z:(generatingRegion.z*(pixelsPerRegion))+z, to:32+Int(8*height))
                    }
                }
            }
            generatingRegion.x += 1
            if generatingRegion.x >= worldSize.x {
                generatingRegion.x = 0
                generatingRegion.z += 1
            }
            
            if generatingRegion.z >= worldSize.z {
                Background.terrainGenerated = true
            }
        } else {
            for _ in 0 ..< 4 {
                createTree()
            }
        }

        if treesGenerated >= treesToGenerate {
            Background.generated = true
        }
    }
    
    
    
    func renderWorld(camera:Camera, canvas:Canvas) {
        
        if !Background.generated {
            stepGeneration(canvas:canvas)
            
            renderNoise(canvas:canvas, quality:64, multiplier:64, frame:frame)
            
            let regionMapSize = pixelsPerRegion
            let treeAmount = Double(treesGenerated)/Double(treesToGenerate)
            for x in 0 ..< map.map.count {
                for z in 0 ..< map.map[x].count {
                    if map.map[x][z] > 0 {
                        canvas.render(FillStyle(color:Color(red:UInt8((map.map[x][z])*6)-UInt8(Double(map.map[x][z])*treeAmount*6.0), green:UInt8((map.map[x][z])*3)+UInt8(Double(map.map[x][z])*treeAmount*3.0), blue:0)))
                    } else {
                        canvas.render(FillStyle(color:Color(.black)))
                    }
                    let center = Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2)
                    let offset = Point(x:(16/pixelsPerRegion)*((map.size.x/2)-x-1), y:(16/pixelsPerRegion)*((map.size.z/2)-z-1))
                    canvas.render(Rectangle(rect:Rect(topLeft:Point(x:center.x+offset.x, y:center.y+offset.y), size:Size(width:16/regionMapSize, height:16/regionMapSize)), fillMode:.fill))
                }
            }

            canvas.render(FillStyle(color:Color(.darkgreen)))
            for tree in trees {
                canvas.render(Rectangle(rect:Rect(topLeft:Point(x:(canvas.canvasSize!.width/2)+((tree.x-(8*worldSize.x))), y:(canvas.canvasSize!.height/2)+(tree.y-(8*worldSize.z))), size:Size(width:2, height:2)), fillMode:.fill))
            }
            
            let text = Text(location:Point(x:canvas.canvasSize!.width/2, y:3*(canvas.canvasSize!.height/4)), text:"Generating World: \(((Background.regionsGenerated+(treesGenerated/4))*100)/(regionsToGenerate+(treesToGenerate/4)))%")
            text.font = "\(canvas.canvasSize!.height/64)pt Arial"
            text.baseline = .middle
            text.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(text)
            
            let generating = Text(location:Point(x:canvas.canvasSize!.width/2, y:4*(canvas.canvasSize!.height/5)), text:"Generating Terrain...")
            if Background.regionsGenerated >= regionsToGenerate {
                generating.text = "Adding Trees..."
            }
            generating.font = "\(canvas.canvasSize!.height/128)pt Arial"
            generating.baseline = .middle
            generating.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(generating)
            
            let title = Text(location:Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height/4)), text:"IGIS_Craft")
            title.font = "\(canvas.canvasSize!.height/16)pt Arial"
            title.baseline = .middle
            title.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(title)

            let splash = Text(location:Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height/4)+canvas.canvasSize!.height/16), text:splashTxt)
            splash.font = "\((canvas.canvasSize!.height/64))pt Arial"
            splash.baseline = .middle
            splash.alignment = .center
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:0)))
            canvas.render(splash)

            let version = Text(location:Point(x:0, y:(canvas.canvasSize!.height)), text:" v0.3.0")
            version.font = "\((canvas.canvasSize!.height/64))pt Arial"
            version.baseline = .bottom
            version.alignment = .left
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:255)))
            canvas.render(version)
        } else {
            Background.world.renderWorld(camera:camera, canvas:canvas)
        }
        frame += 1
    }

    func loadedRegions() -> Int {
        return Background.world.loadedRegions()
    }

    func getBlock(at:BlockPoint3d) -> Block? {
        return Background.world.getBlock(at:at)
    }

    func setBlock(at:BlockPoint3d, to:String) {
        Background.world.setBlock(at:at, to:to)
    }

    func createTree() {
        let location = (x:Int.random(in:0...worldSize.x*16), z:Int.random(in:0...worldSize.z*16))
        let initialBlock = BlockPoint3d(x:location.x,
                                        y:33+Int(8*Noise(x:(location.x), z:location.z, seed:Background.seed)),
                                        z:location.z)
        trees.append(Point(x:initialBlock.x, y:initialBlock.z))
        treesGenerated += 1
        //create leaves
        for x in -2 ... 2 {
            for y in 2 ... 4 {
                for z in -2 ... 2 {
                    if y < 3 || (x > -2 && x < 2 && z > -2 && z < 2) {
                        setBlock(at:BlockPoint3d(x:initialBlock.x+x, y:initialBlock.y+y, z:initialBlock.z+z), to:"leaves")
                    }
                }
            }
        }
        
        //create log
        for height in 0 ..< 4 {
            setBlock(at:BlockPoint3d(x:initialBlock.x, y:initialBlock.y+height, z:initialBlock.z), to:"log")
        }
    }
}
