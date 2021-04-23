import Igis
import Scenes

class Inventory {
    private var blocks : [(name:String, count:Int)]
    private var collectables : [(name:String, count:Int)]
    private var selectedItemIndex = 0
    private var open = false
    private var recipes : [CraftingRecipe]
    private var itemCount = 0

    private var mouseLocation = Point(x:0, y:0)
    private var mouseClicked = false

    public var tools : [Tool]
    
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
        collectables.append((name:"coal", count:0))
        collectables.append((name:"iron_ingot", count:0))
        collectables.append((name:"diamond", count:0))

        recipes = []
        recipes.append(CraftingRecipe(itemsIn:[("log", 1)],
                                      itemOut:("planks", 4)))
        recipes.append(CraftingRecipe(itemsIn:[("planks", 2)],
                                      itemOut:("sticks", 4)))
        recipes.append(CraftingRecipe(itemsIn:[("iron_ore", 2), ("coal", 1)],
                                      itemOut:("iron_ingot", 2)))

        //tool recipes
        recipes.append(CraftingRecipe(itemsIn:[("planks", 3), ("sticks", 2)],
                                      itemOut:("wooden_pickaxe", 1)))
        recipes.append(CraftingRecipe(itemsIn:[("planks", 3), ("sticks", 2)],
                                      itemOut:("wooden_axe", 1)))
        recipes.append(CraftingRecipe(itemsIn:[("planks", 1), ("sticks", 2)],
                                      itemOut:("wooden_shovel", 1)))

        tools = []
        tools.append(Tool(type:"pickaxe", material:"none"))
        tools.append(Tool(type:"axe", material:"none"))
        tools.append(Tool(type:"shovel", material:"none"))
    }

    public func miningMultiplier(block:String) -> (multiplier:Int, canMine:Bool) {
        var multiplier = (multiplier:1, canMine:false)
        for tool in tools {
            let toolMultiplier = tool.miningMultiplier(block:block)
            if toolMultiplier.multiplier > multiplier.multiplier || (!multiplier.canMine && toolMultiplier.canMine) {
                multiplier = toolMultiplier
            }
        }
        return multiplier
    }

    public func getBlocks() -> [(name:String, count:Int)] {
        return blocks
    }
    public func getCollectables() -> [(name:String, count:Int)] {
        return collectables
    }

    public func setBlocks(_ blocks:[(name:String, count:Int)]) {
        self.blocks = blocks
    }
    public func setCollectables(_ collectables:[(name:String, count:Int)]) {
        self.collectables = collectables
    }
    
    public func giveItem(_ item:String, count:Int=1) -> Bool {
        for index in 0 ..< blocks.count {
            if blocks[index].name == item || (blocks[index].name == "dirt" && item == "grass") {
                for _ in 0 ..< count {
                    blocks[index].count += 1
                    itemCount += 1
                } 
                return true
            }
        }
        for index in 0 ..< collectables.count {
            if collectables[index].name == item {
                for _ in 0 ..< count {
                    collectables[index].count += 1
                    itemCount += 1
                }
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

    public func copy() -> Inventory {
        return self
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

    public func hoverOver(point:Point) {
        mouseLocation = point
    }

    public func click() {
        mouseClicked = true
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

        //render tool info
        for index in 0 ..< tools.count {
            let toolTextLocation = Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height-inventorySquareSize)-((1+index)*canvas.canvasSize!.height/58))
            var toolTextString = "\(tools[index].getMaterial()) \(tools[index].getType())"
            if tools[index].getMaterial() == "none" {
                toolTextString = "no \(tools[index].getType())"
            }
            let toolText = Text(location:toolTextLocation, text:toolTextString)
            toolText.alignment = .center
            toolText.baseline = .middle
            toolText.font = "\(canvas.canvasSize!.height/64)pt Arial"

            canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
            canvas.render(toolText)
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

            func contains(rect:Rect, point:Point) -> Bool {
                if rect.topLeft.x <= point.x &&
                     rect.topLeft.x + rect.size.width >= point.x &&
                     rect.topLeft.y <= point.y &&
                     rect.topLeft.y + rect.size.height >= point.y {
                    return true
                }
                return false
            }

            //render crafting panel
            let craftingStartingPoint = Point(x:canvas.canvasSize!.width/2, y:canvas.canvasSize!.height/16)
            let craftingRecipePanelSize = Size(width:(canvas.canvasSize!.width*7)/32, height:canvas.canvasSize!.height/16)
            var recipeNumber = 0
            
            for recipe in recipes {
                canvas.render(FillStyle(color:Color(red:128, green:128, blue:128)))
                canvas.render(StrokeStyle(color:Color(red:0, green:0, blue:0)))
                var topLeft = Point(x:craftingStartingPoint.x, y:craftingStartingPoint.y+(craftingRecipePanelSize.height*(recipeNumber/2)))
                if recipeNumber % 2 != 0 {
                    topLeft = Point(x:craftingStartingPoint.x+(craftingRecipePanelSize.width), y:craftingStartingPoint.y+(craftingRecipePanelSize.height*(recipeNumber/2)))
                }
                let panelRect = Rect(topLeft:topLeft, size:craftingRecipePanelSize)
                if contains(rect:panelRect, point:mouseLocation) {
                    if mouseClicked {
                        if recipe.craft(self) {
                            canvas.render(FillStyle(color:Color(red:196, green:196, blue:255)))
                        } else {
                            canvas.render(FillStyle(color:Color(red:255, green:0, blue:0)))
                        }
                        mouseClicked = false
                    } else {
                        canvas.render(FillStyle(color:Color(red:192, green:192, blue:192)))
                    }
                }
                canvas.render(Rectangle(rect:panelRect, fillMode:.fillAndStroke))
                let center = Point(x:topLeft.x+(craftingRecipePanelSize.width/2), y:topLeft.y+(craftingRecipePanelSize.height/2))

                let arrowText = Text(location:center, text:"->")
                var itemsInString = ""
                for itemIn in recipe.itemsIn {
                    itemsInString += ", \(itemIn.count) \(itemIn.name)"
                }
                let _ = itemsInString.dropFirst()
                let _ = itemsInString.dropFirst()
                let itemsInText = Text(location:Point(x:center.x-(craftingRecipePanelSize.width/4), y:center.y), text:itemsInString)
                let itemOutText = Text(location:Point(x:center.x+(craftingRecipePanelSize.width/4), y:center.y), text:"\(recipe.itemOut.count) \(recipe.itemOut.name)")

                arrowText.font = "\(craftingRecipePanelSize.height/6)pt Arial"
                itemsInText.font = "\(craftingRecipePanelSize.height/6)pt Arial"
                itemOutText.font = "\(craftingRecipePanelSize.height/6)pt Arial"
                
                canvas.render(FillStyle(color:Color(red:0, green:0, blue:0)))
                
                canvas.render(arrowText)
                canvas.render(itemsInText)
                canvas.render(itemOutText)
                recipeNumber += 1
            }
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
