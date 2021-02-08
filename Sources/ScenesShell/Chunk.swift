import Igis
import Scenes

class Chunk {
    var Blocks : [[[Block]]]
    var location : BlockPoint3d

    init(location:BlockPoint3d) {
        Blocks = []
        self.location = location
        
        for y in location.y ..< location.y+4 {
            for x in location.x ..< location.x+4 {
                for z in location.z ..< location.z+4 {
                    Blocks[y][x].append(Block(location:BlockPoint3d(x:x, y:y, z:z)))
                }
            }
        }
    }
}
