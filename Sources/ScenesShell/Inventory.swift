import Igis
import Scenes

class Inventory {
    private var items : [(name:String, count:Int)]
    private var selectedItemIndex = 0

    private var itemCount = 0
    
    public init() {
        items = []
        items.append((name:"log", count:0))
        items.append((name:"dirt", count:0))
        items.append((name:"stone", count:0))
        items.append((name:"iron_ore", count:0))
        items.append((name:"diamond_ore", count:0))
    }
    
    public func giveItem(_ item:String) -> Bool {
        for index in 0 ..< items.count {
            if items[index].name == item || (items[index].name == "dirt" && item == "grass") {
                items[index].count += 1
                itemCount += 1
                return true
            }
        }
        return false
    }

    public func removeItem(_ item:String) -> Bool {
        for index in 0 ..< items.count {
            if items[index].name == item {
                if items[index].count > 0 {
                    items[index].count -= 1
                    return true
                }
            }
        }
        return false
    }

    public func place() -> Bool {
        if items[selectedItemIndex].count > 0 {
            items[selectedItemIndex].count -= 1
            return true
        }
        return false
    }

    public func renderInventory(canvas:Canvas) {
        let inventorySquareSize = canvas.canvasSize!.width/16
        let startingPoint = Point(x:(canvas.canvasSize!.width/2)-((inventorySquareSize/2)+(inventorySquareSize*selectedItemIndex)), y:canvas.canvasSize!.height-inventorySquareSize)
        
        for index in 0 ..< items.count {
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
            
            let itemNameText = Text(location:Point(x:topLeft.x+(inventorySquareSize/2), y:topLeft.y+(inventorySquareSize/3)), text:items[index].name)
            itemNameText.alignment = .center
            itemNameText.baseline = .middle
            itemNameText.font = "\(inventorySquareSize/12)pt Arial"
            if index == selectedItemIndex {
                itemNameText.font = "\(inventorySquareSize/6)pt Arial"
            }
            
            canvas.render(itemNameText)
            
            let itemCountText = Text(location:Point(x:topLeft.x+(inventorySquareSize/2), y:topLeft.y+((2*inventorySquareSize)/3)), text:"\(items[index].count)")
            itemCountText.alignment = .center
            itemCountText.baseline = .middle
            itemCountText.font = "\(inventorySquareSize/12)pt Arial"
            if index == selectedItemIndex {
                itemCountText.font = "\(inventorySquareSize/8)pt Arial"
            }
            
            canvas.render(itemCountText)
        }
    }

    public func scroll(right:Bool=true) {
        if right {
            selectedItemIndex = (selectedItemIndex + 1) % items.count
        } else {
            selectedItemIndex -= 1
            if selectedItemIndex < 0 {
                selectedItemIndex = items.count - 1
            }
        }
    }

    public func selected() -> String {
        return self.items[selectedItemIndex].name
    }
}
