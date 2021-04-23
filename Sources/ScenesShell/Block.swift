import Igis
import Scenes
import Foundation

class Block {
    var location : BlockPoint3d //negative corner of the block
    var color : Color
    var type : String
    var selected = false
    
    var breakValue = 0
    var breaking = false
    var hardness : Int

    func updateBlock() {
        switch type{
        case "bedrock":
            color = Color(red:64, green:64, blue:64)
            hardness = -1
        case "diamond_ore":
            color = Color(red:196, green:196, blue:255)
            hardness = 64
        case "iron_ore":
            color = Color(red:164, green:132, blue:128)
            hardness = 32
        case "coal_ore":
            color = Color(red:32, green:32, blue:32)
            hardness = 32
        case "stone":
            color = Color(red:128, green:128, blue:128)
            hardness = 32
        case "dirt":
            color = Color(red:128, green:64, blue:32)
            hardness = 8
        case "grass":
            color = Color(red:32, green:128, blue:32)
            hardness = 8
        case "log":
            color = Color(red:96, green:64, blue:48)
            hardness = 16
        case "planks":
            color = Color(red:128, green:96, blue:32)
            hardness = 16
        case "leaves":
            color = Color(red:16, green:96, blue:16)
            hardness = 4
        default:
            color = Color(red:255, green:32, blue:255)
            hardness = 0
        }
        if type == "grass" || type == "stone" || type == "dirt" {
            let variation = Int(32*DoubleNoise(x:Double(location.x)+0.1, y:Double(location.y)+0.1, z:Double(location.z)+0.1))
            color = Color(red:UInt8(Int(color.red)+variation),
                          green:UInt8(Int(color.green)+variation),
                          blue:UInt8(Int(color.blue)+variation))
        }
    }

    func mine(_ multiplier:Int=1)  {
        breaking = true
        if hardness > 0 {
            breakValue += multiplier
        }
        if breakValue >= hardness {
            if BackgroundLayer.inventory.miningMultiplier(block:self.type).canMine {
                switch self.type {
                case "diamond_ore":
                    let _ = BackgroundLayer.inventory.giveItem("diamond")
                case "coal_ore":
                    let _ = BackgroundLayer.inventory.giveItem("coal")
                default:
                    let _ = BackgroundLayer.inventory.giveItem(self.type)
                }
            }
            
            self.type = "air"
            self.breaking = false
            self.breakValue = 0
        }
    }

    init(location:BlockPoint3d, type:String) {
        self.location = location
        self.type = type
        
        self.color = Color(red:255, green:32, blue:255)
        self.hardness = 0
        
        updateBlock()
    }

    func isVisible() -> Bool {
        return true
    }

    func renderBlock(camera:Camera, canvas:Canvas) {
        if type != "air" && self.isVisible() {
            var sunAngle = (Double(BackgroundLayer.frame)/1440)*180

            while sunAngle > 360 {
                sunAngle -= 360
            }
            
            var timeOfDayMultiplier = 1.0
            if sunAngle > 170 && sunAngle < 200 {
                timeOfDayMultiplier = (200.0 - sunAngle) / 45 + 1/3
            }
            if sunAngle >= 200 && sunAngle <= 340 {
                timeOfDayMultiplier = 1/3
            }
            if sunAngle > 340 {
                timeOfDayMultiplier = (sunAngle - 340) / 45 + 1/3
            }
            if sunAngle < 10 {
                timeOfDayMultiplier = (sunAngle + 20) / 45 + 1/3
            }
            
            if !breaking {
                breakValue = 0
                let blockColor = Color(red:UInt8(Double(color.red) * timeOfDayMultiplier),
                                       green:UInt8(Double(color.green) * timeOfDayMultiplier),
                                       blue:UInt8(Double(color.blue) * timeOfDayMultiplier))
                Cube(center:location.convertToDouble()).renderCube(camera:camera, canvas:canvas, color:blockColor, outline:selected)
            } else {
                var colorMultiplier = 0.0

                if hardness > breakValue {
                    colorMultiplier = 1.0-(Double(breakValue)/Double(hardness))
                }
                
                let redBreak = UInt8(Double(color.red) * colorMultiplier * timeOfDayMultiplier)
                let greenBreak = UInt8(Double(color.green) * colorMultiplier * timeOfDayMultiplier)
                let blueBreak = UInt8(Double(color.blue) * colorMultiplier * timeOfDayMultiplier)
                Cube(center:location.convertToDouble()).renderCube(camera:camera, canvas:canvas, color:Color(red:redBreak, green:greenBreak, blue:blueBreak), outline:selected)
                self.breaking = false
            }
        }
        self.selected = false
    }
}
