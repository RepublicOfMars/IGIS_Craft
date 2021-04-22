import Igis
import Scenes

class Inventory {
    private var blocks : [(name:String, count:Int)]
    private var collectables : [(name:String, count:Int)]
    private var selectedItemIndex = 0
    private var open = false

    private var itemCount = 0
    
    public init() {
        blocks = []
        blocks.append((name:"log", count:0))
        blocks.append((name:"planks", count:0))
        blocks.append((name:"dirt", count:0))
        blocks.append((name:"stone", count:0))
        blocks.append((name:"iron_ore", count:0))
        blocks.append((name:"diamond_ore", count:0))

        collectables = []
        collectables.append((name:"sticks", count:0))
        collectables.append((name:"iron_ingot", count:0))
        collectables.append((name:"diamond", count:0))
    }
    
    public func giveItem(_ item:String) -> Bool {
        for index in 0 ..< blocks.count {
            if blocks[index].name == item || (blocks[index].name == "dirt" && item == "grass") {
                blocks[index].count += 1
                itemCount += 1
                return true
            }
        }
        for index in 0 ..< collectables.count {
            if collectables[index].name == item {
                collectables[index].count += 1
                itemCount += 1
                return true
            }
        }
        return false
    }

    public func removeItem(_ item:String, count:Int=1) -> Bool {
        for index in 0 ..< blocks.count {
            if blocks[index].name == item {
                if blocks[index].count >= count {
                    blocks[index].count -= count
                    return true
                }
            }
        }
        for index in 0 ..< collectables.count {
            if collectables[index].name == item {
                if collectables[index].count >= count {
                    collectables[index].count -= count
                    return true
                }
            }
        }
        return false
    }

    public func craft(_ item:String) -> Bool {
        switch item {
        case "planks":
            if removeItem("log") {
                let _ = giveItem("planks")
                return true
            }
        case "sticks":
            if removeItem("planks", count:2) {
                let _ = giveItem("sticks")
                return true
            }
        default:
            return false
        }
        return false
    }

    public func place() -> Bool {
        if blocks[selectedItemIndex].count > 0 {
            blocks[selectedItemIndex].count -= 1
            return true
        }
        return false
    }

    public func toggle() {
        open = !open
    }

    public func isOpen() -> Bool {
        return open
    }

    public func renderInventory(canvas:Canvas) {
        let inventorySquareSize = canvas.canvasSize!.width/16
        let startingPoint = Point(x:(canvas.canvasSize!.width/2)-((inventorySquareSize/2)+(inventorySquareSize*selectedItemIndex)), y:canvas.canvasSize!.height-inventorySquareSize)
        
        for index in 0 ..< blocks.count {
            canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))
            canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
            if index == selectedItemIndex {
                canvas.render(FillStyle(color:Color(red:192, green:192, blue:192)))
            }
            let topLeft = Point(x:startingPoint.x+(index*inventorySquareSize), y:startingPoint.y)
            canvas.render(Rectangle(rect:Rect(topLeft:topLeft,
                                    size:Size(width:inventorySquareSize, height:inventorySquareSize)),
                                    fillMode:.fillAndStroke))

            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            
            let itemNameText = Text(location:Point(x:topLeft.x+(inventorySquareSize/2), y:topLeft.y+(inventorySquareSize/3)), text:blocks[index].name)
            itemNameText.alignment = .center
            itemNameText.baseline = .middle
            itemNameText.font = "\(inventorySquareSize/12)pt Arial"
            if index == selectedItemIndex {
                itemNameText.font = "\(inventorySquareSize/6)pt Arial"
            }
            
            canvas.render(itemNameText)
            
            let itemCountText = Text(location:Point(x:topLeft.x+(inventorySquareSize/2), y:topLeft.y+((2*inventorySquareSize)/3)), text:"\(blocks[index].count)")
            itemCountText.alignment = .center
            itemCountText.baseline = .middle
            itemCountText.font = "\(inventorySquareSize/12)pt Arial"
            if index == selectedItemIndex {
                itemCountText.font = "\(inventorySquareSize/8)pt Arial"
            }
            
            canvas.render(itemCountText)
        }

        if open {
            //render transparent background
            canvas.render(Alpha(alphaValue:0.75))
            canvas.render(FillStyle(color:Color(red:64, green:64, blue:64)))
            canvas.render(Rectangle(rect:Rect(topLeft:Point(x:0, y:0), size:canvas.canvasSize!), fillMode:.fill))
            canvas.render(Alpha(alphaValue:1.0))

            //render inventory background
            let startingPoint = Point(x:canvas.canvasSize!.width/16, y:canvas.canvasSize!.height/16)
            let inventoryPanelSize = Size(width:(canvas.canvasSize!.width*7)/8, height:(canvas.canvasSize!.height*7)/8)
            let itemBoxSize = canvas.canvasSize!.width/24
            canvas.render(FillStyle(color:Color(red:96, green:96, blue:96)))
            canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(Rectangle(rect:Rect(topLeft:startingPoint, size:inventoryPanelSize), fillMode:.fillAndStroke))

            //render main inventory
            var itemNumber = 0
            let itemsPerRow = inventoryPanelSize.width/itemBoxSize
            for item in blocks + collectables {
                canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))
                canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
                canvas.render(Rectangle(rect:Rect(topLeft:Point(x:startingPoint.x+itemBoxSize*(itemNumber%itemsPerRow),
                                                                y:startingPoint.y+itemBoxSize*(itemNumber/itemsPerRow)),
                                                  size:Size(width:itemBoxSize, height:itemBoxSize)),
                                        fillMode:.fillAndStroke))
                canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))

                let itemNameText = Text(location:Point(x:(startingPoint.x+itemBoxSize*(itemNumber%itemsPerRow))+itemBoxSize/2,
                                                       y:(startingPoint.y+itemBoxSize*(itemNumber/itemsPerRow))+(itemBoxSize/3)), text:item.name)
                itemNameText.alignment = .center
                itemNameText.baseline = .middle
                itemNameText.font = "\(itemBoxSize/8)pt Arial"
                
                canvas.render(itemNameText)
                
                let itemCountText = Text(location:Point(x:(startingPoint.x+itemBoxSize*(itemNumber%itemsPerRow))+itemBoxSize/2,
                                                        y:(startingPoint.y+itemBoxSize*(itemNumber/itemsPerRow)+(2*(itemBoxSize/3)))), text:"\(item.count)")
                itemCountText.alignment = .center
                itemCountText.baseline = .middle
                itemCountText.font = "\(itemBoxSize/8)pt Arial"
                canvas.render(itemCountText)
                
                itemNumber += 1
            }
            
            let craftingText = Text(location:Point(x:(canvas.canvasSize!.width*23)/32, y:(canvas.canvasSize!.height)/2), text:"crafting is a work in progress")
            craftingText.alignment = .center
            craftingText.baseline = .middle
            craftingText.font = "\(itemBoxSize/3)pt Arial"
            canvas.render(craftingText)
        }
    }

    public func scroll(right:Bool=true) {
        if right {
            selectedItemIndex = (selectedItemIndex + 1) % blocks.count
        } else {
            selectedItemIndex -= 1
            if selectedItemIndex < 0 {
                selectedItemIndex = blocks.count - 1
            }
        }
    }

    public func selected() -> String {
        return self.blocks[selectedItemIndex].name
    }
}
