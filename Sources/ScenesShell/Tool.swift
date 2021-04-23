class Tool {
    private let type : String
    private var material : String

    public init(type:String, material:String) {
        self.type = type
        self.material = material
    }

    private func materialMultiplier() -> Int {
        switch material {
        case "wooden":
            return 1
        case "stone":
            return 2
        case "iron":
            return 4
        case "diamond":
            return 8
        default:
            return 1
        }
    }

    public func getMaterial() -> String {
        return material
    }
    public func setMaterial(to:String) {
        self.material = to
    }
    
    public func getType() -> String {
        return type
    }

    public func miningMultiplier(block:String) -> (multiplier:Int, canMine:Bool) {
        switch block {
        case "grass", "dirt":
            if type == "shovel" && material != "none" {
                return (multiplier:2 * materialMultiplier(), canMine:true)
            }
            return (multiplier:1, canMine:true)
        case "log", "planks":
            if type == "axe" && material != "none" {
                return (multiplier:2 * materialMultiplier(), canMine:true)
            }
            return (multiplier:1, canMine:true)
        case "stone":
            if type == "pickaxe" && material != "none" {
                return (multiplier:2 * materialMultiplier(), canMine:true)
            }
            return (multiplier:1, canMine:false)
        case "coal_ore", "iron_ore":
            if type == "pickaxe" && (material != "none" && material != "wooden") {
                return (multiplier:2 * materialMultiplier(), canMine:true)
            }
            return (multiplier:1, canMine:false)
        case "diamond_ore":
            if type == "pickaxe" && (material == "iron" || material == "diamond") {
                return (multiplier:2 * materialMultiplier(), canMine:true)
            }
            return (multiplier:1, canMine:false)
            //
        case "leaves":
            if type == "axe" && material != "none" {
                return (multiplier:2 * materialMultiplier(), canMine:false)
            }
            return (multiplier:1, canMine:false)
        default:
            return (multiplier:1, canMine:false)
        }
    }
}
