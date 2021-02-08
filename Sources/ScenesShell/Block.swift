import Igis
import Scenes

class Block {
    var location : BlockPoint3d //negative corner of the block

    init(location:BlockPoint3d) {
        self.location = location
    }

    func renderBlock(camera:Camera, canvas:Canvas) {
        Cube(center:location.convertToDouble()).renderCube(camera:camera, canvas:canvas)
    }
}
