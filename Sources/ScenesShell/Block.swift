import Igis
import Scenes
import Foundation

class Block {
    var location : BlockPoint3d //negative corner of the block
    var color : Color
    var type : String
    var selected = false

    init(location:BlockPoint3d, type:String) {
        self.location = location
        self.type = type
        switch type{
        case "bedrock":
            color = Color(red:64, green:64, blue:64)
        case "diamond_ore":
            color = Color(red:196, green:196, blue:255)
        case "iron_ore":
            color = Color(red:164, green:132, blue:128)
        case "stone":
            color = Color(red:128, green:128, blue:128)
        case "dirt":
            color = Color(red:128, green:64, blue:32)
        case "grass":
            color = Color(red:32, green:128, blue:32)
        default:
            color = Color(red:255, green:0, blue:255)
        }
    }

    func isVisible() -> Bool {
        return true
    }

    func renderBlock(camera:Camera, canvas:Canvas) {
        if type != "air" && self.isVisible() {
            Cube(center:location.convertToDouble()).renderCube(camera:camera, canvas:canvas, color:color)
        }
    }
}
