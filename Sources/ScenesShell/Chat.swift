import Igis
import Scenes

class Chat {
    private var text : [String]
    private let maxLines = 12
    init() {
        text = []
        for _ in 0 ..< maxLines {
            text.append("")
        }
    }

    func input(_ string:String) {
        text.remove(at:0)
        text.append(string)
    }

    func render(canvas:Canvas) {
        let lowerBound = canvas.canvasSize!.height-20
        for line in 0 ..< text.count {
            let currentText = Text(location:Point(x:20, y:lowerBound-(10*(text.count-line))), text:text[line], fillMode:.fill)
            currentText.font = "8pt Arial"
            currentText.alignment = .left
            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(currentText)
        }
    }
}
