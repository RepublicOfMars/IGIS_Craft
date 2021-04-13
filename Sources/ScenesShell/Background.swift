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
    let splashTxt = splashText()

    public static var generated = false
    var generatingRegion = (x:0, y:0, z:0)
    var map : generatingMap

    let pixelsPerRegion = 1
    var frame = 0

    init(seed:Int=0) {
        regionsToGenerate = worldSize.x * worldSize.y * worldSize.z
        map = generatingMap(x:worldSize.x*pixelsPerRegion, z:worldSize.z*pixelsPerRegion)
        // Using a meaningful name can be helpful for debugging
        Background.seed = seed
        super.init(name:"Background")
    }

    func stepGeneration(canvas:Canvas) {
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
            Background.generated = true
        }
        
    }

    

    func renderWorld(camera:Camera, canvas:Canvas) {
        
        if !Background.generated {
            stepGeneration(canvas:canvas)

            renderNoise(canvas:canvas, quality:64, multiplier:64, frame:frame)

            let regionMapSize = pixelsPerRegion
            for x in 0 ..< map.map.count {
                for z in 0 ..< map.map[x].count {
                    if map.map[x][z] > 0 {
                        canvas.render(FillStyle(color:Color(red:0, green:UInt8((map.map[x][z])*6), blue:128-UInt8((map.map[x][z])*2))))
                    } else {
                        canvas.render(FillStyle(color:Color(.black)))
                    }
                    let center = Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2)
                    let offset = Point(x:(16/pixelsPerRegion)*((map.size.x/2)-x-1), y:(16/pixelsPerRegion)*((map.size.z/2)-z-1))
                    canvas.render(Rectangle(rect:Rect(topLeft:Point(x:center.x+offset.x, y:center.y+offset.y), size:Size(width:16/regionMapSize, height:16/regionMapSize)), fillMode:.fill))
                }
            }
            
            let text = Text(location:Point(x:canvas.canvasSize!.width/2, y:3*(canvas.canvasSize!.height/4)), text:"Generating World: \((Background.regionsGenerated*100)/regionsToGenerate)%")
            text.font = "\(canvas.canvasSize!.height/64)pt Arial"
            text.baseline = .middle
            text.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(text)
            
            let generated = Text(location:Point(x:canvas.canvasSize!.width/2, y:25*(canvas.canvasSize!.height/32)), text:"(\(Background.regionsGenerated)/\(regionsToGenerate))")
            generated.font = "\(canvas.canvasSize!.height/96)pt Arial"
            generated.baseline = .middle
            generated.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(generated)
            
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

            let version = Text(location:Point(x:0, y:(canvas.canvasSize!.height)), text:" v0.0.9")
            version.font = "\((canvas.canvasSize!.height/64))pt Arial"
            version.baseline = .bottom
            version.alignment = .left
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:255)))
            canvas.render(version)
        } else {
            renderNoise(canvas:canvas, quality:32, multiplier:8, frame:frame)
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
}
