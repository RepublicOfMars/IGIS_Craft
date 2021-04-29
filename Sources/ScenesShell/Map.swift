import Igis
import Scenes

class Map {
    var map : [[Color]]
    let pixelSize : Int
    
    init(xSize:Int, ySize:Int, pixelSize:Int) {
        map = []
        for y in 0 ..< ySize {
            map.append([])
            for _ in 0 ..< xSize {
                map[y].append(Color(red:0, green:0, blue:0))
            }
        }
        self.pixelSize = pixelSize
    }

    func changePixel(x:Int, y:Int, to:Color) {
        precondition(y < map.count, "Map.swift, function changePixel(x:\(x), y:\(y)): Unexpected y value \(y), value must be less than \(map.count)")
        precondition(x < map[0].count, "Map.swift, function changePixel(x:\(x), y:\(y)): Unexpected x value \(x), value must be less than \(map[0].count)")

        map[y][x] = to
    }

    func getPixel(x:Int, y:Int) -> Color {
        precondition(y < map.count, "Map.swift, function getPixel(x:\(x), y:\(y)): Unexpected y value \(y), value must be less than \(map.count)")
        precondition(x < map[0].count, "Map.swift, function getPixel(x:\(x), y:\(y)): Unexpected x value \(x), value must be less than \(map[0].count)")

        return map[y][x]
    }

    func render(canvas:Canvas) {
        let center = Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/2)
        let startingPoint = Point(x:center.x-((map[0].count*pixelSize)/2), y:center.y-((map.count*pixelSize)/2))

        for y in 0 ..< map.count {
            for x in 0 ..< map[y].count {
                canvas.render(FillStyle(color:map[y][x]))
                canvas.render(Rectangle(rect:Rect(topLeft:Point(x:startingPoint.x+(x*pixelSize), y:startingPoint.y+(y*pixelSize)), size:Size(width:pixelSize, height:pixelSize)), fillMode:.fill))
            }
        }
    }
}
