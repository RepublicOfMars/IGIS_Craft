
import Igis
import Scenes

class Settings {
    //settings
    private var maxPolygonsToRender = 1800

    //setting min/max 
    private var maxPolygonsToRenderSetting = (min:900, max:2700)
    
    //other variables
    private var open = false

    private var mouseLocation = Point(x:0, y:0)
    private var mouseClicked = false

    public init() {
    }

    public func getMaxPolygonsToRender() -> Int {
        return maxPolygonsToRender
    }

    public func hoverOver(point:Point) {
        mouseLocation = point
    }

    public func click() {
        mouseClicked = true
    }

    public func isOpen() -> Bool {
        return open
    }

    public func openSettings() {
        open = true
    }

    public func closeSettings() {
        open = false
    }

    private func contains(rect:Rect, point:Point) -> Bool {
        if rect.topLeft.x <= point.x &&
             rect.topLeft.x + rect.size.width >= point.x &&
             rect.topLeft.y <= point.y &&
             rect.topLeft.y + rect.size.height >= point.y {
            return true
        }
        return false
    }

    public func render(canvas:Canvas) {
        let startingPoint = Point(x:canvas.canvasSize!.width/16,
                                  y:canvas.canvasSize!.height/16)
        let panelSize = Size(width:(canvas.canvasSize!.width/8)*7,
                             height:(canvas.canvasSize!.height/8)*7)

        let settingsSliderStartingPoint = Point(x:canvas.canvasSize!.width/8,
                                                y:canvas.canvasSize!.height/4)
        let settingsSliderSize = Size(width:(canvas.canvasSize!.width/4)*3,
                                      height:(canvas.canvasSize!.height/16))
        if open {
            //render transparent background
            canvas.render(Alpha(alphaValue:0.75))
            canvas.render(FillStyle(color:Color(red:64, green:64, blue:64)))
            canvas.render(Rectangle(rect:Rect(topLeft:Point(x:0, y:0),
                                              size:canvas.canvasSize!),
                                    fillMode:.fill))
            canvas.render(Alpha(alphaValue:1.0))

            //render settings panel background
            canvas.render(FillStyle(color:Color(red:96, green:96, blue:64)))
            canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(Rectangle(rect:Rect(topLeft:startingPoint, size:panelSize),
                                    fillMode:.fillAndStroke))

            //render settings
            let mainSettingsText = Text(location:Point(x:canvas.canvasSize!.width/2,
                                                       y:startingPoint.y*2),
                                        text:"Settings")
            mainSettingsText.alignment = .center
            mainSettingsText.baseline = .middle
            mainSettingsText.font = "\(startingPoint.y)pt Arial"
            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(mainSettingsText)

            //maxPolygonsToRender
            let maxPolygonsSliderBackground = Rectangle(rect:Rect(topLeft:settingsSliderStartingPoint,
                                              size:settingsSliderSize),
                                    fillMode:.fillAndStroke)
            if contains(rect:maxPolygonsSliderBackground.rect, point:mouseLocation) {
                canvas.render(FillStyle(color:Color(red:96, green:96, blue:96)))
                if mouseClicked {
                    let sliderPercent = Double(mouseLocation.x - settingsSliderStartingPoint.x) / Double(settingsSliderSize.width)
                    maxPolygonsToRender = Int(Double(maxPolygonsToRenderSetting.max-maxPolygonsToRenderSetting.min)*sliderPercent) + maxPolygonsToRenderSetting.min
                }
            } else {
                canvas.render(FillStyle(color:Color(red:64, green:64, blue:64)))
            }
            canvas.render(maxPolygonsSliderBackground)
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:255)))
            canvas.render(Rectangle(rect:Rect(topLeft:Point(x:(settingsSliderStartingPoint.x-(settingsSliderSize.width/128))+Int((Double(maxPolygonsToRender-maxPolygonsToRenderSetting.min)/Double(maxPolygonsToRenderSetting.max-maxPolygonsToRenderSetting.min))*Double(settingsSliderSize.width)),
                                                            y:settingsSliderStartingPoint.y),
                                              size:Size(width:settingsSliderSize.width/64,
                                                        height:settingsSliderSize.height)),
                                    fillMode:.fillAndStroke))
            let maxPolygonsText = Text(location:maxPolygonsSliderBackground.rect.center, text:"Maximum Polygons To Render: \(maxPolygonsToRender)")
            maxPolygonsText.alignment = .center
            maxPolygonsText.baseline = .middle
            maxPolygonsText.font = "\(settingsSliderSize.height/2)pt Arial"
            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(maxPolygonsText)
        }
        
        mouseClicked = false
    }
}
