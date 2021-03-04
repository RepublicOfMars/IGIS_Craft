import Igis
import Scenes

class Path3d {
    var Points3d : [Point3d]

    init() {
        Points3d = []
    }

    init(from:Point3d, to:Point3d) {
        Points3d = [from, to]
    }

    func lineTo(_ Point3d:Point3d) {
        Points3d.append(Point3d)
    }

    func flatten(camera:Camera, canvas:Canvas, solid:Bool=true) -> Path { //flattens path to 2d (for rendering)
        var Points2d : [Point] = []
        for index in 0 ..< Points3d.count {
            if let point = Points3d[index].flatten(camera:camera, canvas:canvas) {
                Points2d.append(point)
            }
        }

        var path = Path(fillMode:.fillAndStroke)
        if !solid {
            path = Path(fillMode:.stroke)
        }

        for index in 0 ..< Points2d.count {
            path.lineTo(Points2d[index])
        }

        return path
    }

    func renderPath(camera:Camera, canvas:Canvas, color:Color, solid:Bool=true) {
        var subtraction : (red:UInt8, green:UInt8, blue:UInt8) = (red:0, green:0, blue:0)
        
        if color.red >= 8 {
            subtraction.red = 8
        }
        if color.green >= 8 {
            subtraction.green = 8
        }
        if color.blue >= 8 {
            subtraction.blue = 8
        }
        
        canvas.render(StrokeStyle(color:Color(red:color.red-subtraction.red, green:color.green-subtraction.green, blue:color.blue-subtraction.blue)))
        canvas.render(FillStyle(color:color))
        canvas.render(self.flatten(camera:camera, canvas:canvas, solid:solid))
    }
}
