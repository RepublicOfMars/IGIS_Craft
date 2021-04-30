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

    func flatten(camera:Camera, canvas:Canvas, solid:Bool=true, outline:Bool=false) -> Path { //flattens path to 2d (for rendering)
        var Points2d : [Point] = []
        for index in 0 ..< Points3d.count {
            if let point = Points3d[index].flatten(camera:camera, canvas:canvas) {
                Points2d.append(point)
            }
        }

        var path = Path()
        if solid && outline {
            path = Path(fillMode:.fillAndStroke)
        } else if solid {
            path = Path(fillMode:.fillAndStroke)
        } else if outline {
            path = Path(fillMode:.stroke)
        }

        for index in 0 ..< Points2d.count {
            path.lineTo(Points2d[index])
        }

        return path
    }

    func renderPath(camera:Camera, canvas:Canvas, color:Color, solid:Bool=true, outline:Bool=false) {

        if outline {
            canvas.render(StrokeStyle(color:Color(red:64, green:64, blue:64)))
        } else {
            var colorOutline = (red:color.red, green:color.green, blue:color.blue)
            if color.red >= 4 {
                colorOutline.red -= 4
            }
            if color.green >= 4 {
                colorOutline.green -= 4
            }
            if color.blue >= 4 {
                colorOutline.blue -= 4
            }
            canvas.render(StrokeStyle(color:Color(red:colorOutline.red, green:colorOutline.green, blue:colorOutline.blue)))
        }
        canvas.render(FillStyle(color:color))
        canvas.render(self.flatten(camera:camera, canvas:canvas, solid:solid, outline:outline))
    }
}
