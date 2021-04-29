class CraftingRecipe {
    let itemsIn : [(name:String, count:Int)]
    let itemOut : (name:String, count:Int)

    init(itemsIn:[(name:String, count:Int)], itemOut:(name:String, count:Int)) {
        self.itemsIn = itemsIn
        self.itemOut = itemOut
    }

    func craft(_ inventory:Inventory) -> Bool {
        let tempInventory = Inventory()
        tempInventory.setBlocks(inventory.getBlocks())
        tempInventory.setCollectables(inventory.getCollectables())
        var success = true
        let toolNames = ["wooden_pickaxe", "wooden_axe", "wooden_shovel",
                         "stone_pickaxe", "stone_axe", "stone_shovel",
                         "iron_pickaxe", "iron_axe", "iron_shovel",
                         "diamond_pickaxe", "diamond_axe", "diamond_shovel"]

        if !toolNames.contains(itemOut.name) {
            for item in itemsIn {
                if !tempInventory.removeItem(item.name, count:item.count) {
                    success = false
                }
            }
            if !tempInventory.giveItem(itemOut.name, count:itemOut.count) {
                success = false
            }

            if !success {
                return false
            } else {
                for item in itemsIn {
                    let _ = inventory.removeItem(item.name, count:item.count)
                }
                let _ = inventory.giveItem(itemOut.name, count:itemOut.count)
                return true
            }
        } else {
            for item in itemsIn {
                if !tempInventory.removeItem(item.name, count:item.count) {
                    success = false
                }
            }

            if !success {
                return false
            } else {
                for item in itemsIn {
                    let _ = inventory.removeItem(item.name, count:item.count)
                }
                let toolArguments = itemOut.name.split(separator:"_")
                let toolMaterial = toolArguments[0]
                let toolType = toolArguments[1]
                
                for tool in inventory.tools {
                    if tool.getType() == toolType {
                        switch toolMaterial {
                        case "diamond":
                            if tool.getMaterial() == "none"
                                 || tool.getMaterial() == "wooden"
                                 || tool.getMaterial() == "stone"
                                 || tool.getMaterial() == "iron" {
                                tool.setMaterial(to:"diamond")
                            }
                        case "iron":
                            if tool.getMaterial() == "none"
                                 || tool.getMaterial() == "wooden"
                                 || tool.getMaterial() == "stone" {
                                tool.setMaterial(to:"iron")
                            }
                        case "stone":
                            if tool.getMaterial() == "none"
                                 || tool.getMaterial() == "wooden" {
                                tool.setMaterial(to:"stone")
                            }
                        case "wooden":
                            if tool.getMaterial() == "none" {
                                tool.setMaterial(to:"wooden")
                            }
                        default:
                            fatalError("invalid tool material \(toolMaterial)")
                        }
                    }
                }
                
                return true
            }
        }
    }
}
