import Igis
import Scenes

class generatingMap {
    var map : [[Int]]
    let size : (x:Int, z:Int)
    
    init(x:Int, z:Int) {
        size = (x:x, z:z)
        map = []
        for x in 0 ..< size.x {
            map.append([])
            for _ in 0 ..< size.z {
                map[x].append(0)
            }
        }
    }

    func changePixel(x:Int, z:Int, to:Int) {
        map[x][z] = to
    }
}

class SimpleWorld {
    var Blocks : [[[Block]]]
    let worldSize : (horizontal:Int, vertical:Int)
    let seed : Int

    var blocksGenerated = 0
    let blocksToGenerate : Int
    
    var generating = true
    var terrainGenerated = false
    var blockGenerating = (x:0, z:0)
    var blockScanning = (x:0, z:0)
    var frame = 0
    let splashTxt = splashText()
    var renderDistance = 3
    
    init(seed:Int=0) {
        Blocks = []
        self.seed = seed
        self.worldSize = (horizontal:128, vertical:64)

        for y in 0 ..< worldSize.vertical {
            Blocks.append([])
            for _ in 0 ..< worldSize.horizontal {
                Blocks[y].append([])
            }
        }

        blocksToGenerate = worldSize.horizontal * worldSize.horizontal * worldSize.vertical
    }

    private func inBounds(_ point:BlockPoint3d) -> BlockPoint3d {
        let fixedPoint = point
        if fixedPoint.x >= worldSize.horizontal {
            fixedPoint.x = worldSize.horizontal - 1
        }
        if fixedPoint.x < 0 {
            fixedPoint.x = 0
        }
        if fixedPoint.y >= worldSize.vertical {
            fixedPoint.y = worldSize.vertical - 1
        }
        if fixedPoint.y < 0 {
            fixedPoint.y = 0
        }
        if fixedPoint.z >= worldSize.horizontal {
            fixedPoint.z = worldSize.horizontal - 1
        }
        if fixedPoint.z < 0 {
            fixedPoint.z = 0
        }
        return fixedPoint
    }

    private func horizontalInBounds(_ n:Int) -> Int {
        var horizontalPosition = n
        if horizontalPosition >= worldSize.horizontal {
            horizontalPosition = worldSize.horizontal - 1
        }
        if horizontalPosition < 0 {
            horizontalPosition = 0
        }
        return horizontalPosition
    }

    private func verticalInBounds(_ n:Int) -> Int {
        var verticalPosition = n
        if verticalPosition >= worldSize.vertical {
            verticalPosition = worldSize.vertical - 1
        }
        if verticalPosition < 0 {
            verticalPosition = 0
        }
        return verticalPosition
    }

    private func generate(x:Int, z:Int) {
        let terrainHeight = 32 + Int(8.0*(Noise(x:x, z:z, seed:seed)))
        
        for y in 0 ..< worldSize.vertical {
            var type = "air"
                    if y <= terrainHeight-3 {
                        type = "stone"
                        if y <= 8 && Int.random(in:1...128) == 1 {
                            type = "diamond_ore"
                        }
                        if y <= 16 && Int.random(in:1...64) == 1 {
                            type = "iron_ore"
                        }
                        if y <= 24 && Int.random(in:1...32) == 1 {
                            type = "coal_ore"
                        }
                    } else if y <= terrainHeight-1 {
                        type = "dirt"
                    } else if y <= terrainHeight {
                        type = "grass"
                    }
                    
                    if y <= 0 {
                        type = "bedrock"
                    }
                    
                    Blocks[y][x].append(Block(location:BlockPoint3d(x:x, y:y, z:z), type:type))
                    blocksGenerated += 1
        }
    }

    private func nearbyBlocks(cameraPosition:Point3d) -> [Block] {
        var output : [Block] = []
        var workingArray : [Double] = []
        
        for y in verticalInBounds(Int(cameraPosition.y)-renderDistance) ... verticalInBounds(Int(cameraPosition.y)+renderDistance) {
            for x in horizontalInBounds(Int(cameraPosition.x)-renderDistance) ... horizontalInBounds(Int(cameraPosition.x)+renderDistance) {
                for z in horizontalInBounds(Int(cameraPosition.z)-renderDistance) ... horizontalInBounds(Int(cameraPosition.z)+renderDistance) {
                    let block = Blocks[y][x][z]
                    if block.isVisible && block.type != "air" {
                        output.append(block)
                        workingArray.append(block.location.convertToDouble().distanceFrom(point:cameraPosition))
                    }
                }
            }
        }

        if output.count > 256 && renderDistance > 2 {
            renderDistance -= 1
        }
        if output.count < 128 && renderDistance < 12 {
            renderDistance += 1
        }
        
        return mergeSort(output, by:workingArray) as! [Block]
    }
    
    public func getBlock(at:BlockPoint3d) -> Block {
        print("getBlock(at:BlockPoint3d(x:\(verticalInBounds(at.x)), y:\(verticalInBounds(at.y)), z:\(verticalInBounds(at.z))))")
        return Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)]
    }
    
    public func setBlock(at:BlockPoint3d, to:String) {
        print("setBlock(at:BlockPoint3d(x:\(verticalInBounds(at.x)), y:\(verticalInBounds(at.y)), z:\(verticalInBounds(at.z))), to:\(to))")
        if to == "selected" {
            Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].selected = true
        } else if to == "visible" {
            Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].isVisible = true
        } else if to == "invisible" {
            Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].isVisible = false
        } else if to.first == "m" {
            var multiplier = to
            multiplier = String(multiplier.dropFirst())
            Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].mine(Int(multiplier)!)
        } else {
            Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].type = to
        }
        Blocks[verticalInBounds(at.y)][horizontalInBounds(at.x)][horizontalInBounds(at.z)].updateBlock()
        updateNeighborVisibility(at:at)
    }
    
    private func createTree(at:BlockPoint3d) {
        let trunkHeight = Int.random(in:3...5)
        //create leaves
        for x in -2 ... 2 {
            for z in -2 ... 2 {
                for y in -2 ... -1 {
                    setBlock(at:BlockPoint3d(x:at.x+x, y:at.y+y+trunkHeight, z:at.z+z), to:"leaves")
                }
            }
        }
        for x in -1 ... 1 {
            for z in -1 ... 1 {
                for y in 0 ... 1 {
                    setBlock(at:BlockPoint3d(x:at.x+x, y:at.y+y+trunkHeight, z:at.z+z), to:"leaves")
                }
            }
        }
        
        //create trunk
        for y in 0 ..< trunkHeight {
            setBlock(at:BlockPoint3d(x:at.x, y:at.y+y, z:at.z), to:"log")
        }
    }

    public func updateBlockVisibility(at:BlockPoint3d) {
        print("updateBlockVisibility(at:BlockPoint3d(x:\(at.x), y:\(at.y), z:\(at.z)))")
        var visible = false
        if getBlock(at:BlockPoint3d(x:at.x+1, y:at.y, z:at.z)).type == "air" {visible = true}
        if getBlock(at:BlockPoint3d(x:at.x-1, y:at.y, z:at.z)).type == "air" {visible = true}
        if getBlock(at:BlockPoint3d(x:at.x, y:at.y+1, z:at.z)).type == "air" {visible = true}
        if getBlock(at:BlockPoint3d(x:at.x, y:at.y-1, z:at.z)).type == "air" {visible = true}
        if getBlock(at:BlockPoint3d(x:at.x, y:at.y, z:at.z+1)).type == "air" {visible = true}
        if getBlock(at:BlockPoint3d(x:at.x, y:at.y, z:at.z-1)).type == "air" {visible = true}
        
        if visible {
            setBlock(at:BlockPoint3d(x:at.x, y:at.y, z:at.z), to:"visible")
        } else {
            setBlock(at:BlockPoint3d(x:at.x, y:at.y, z:at.z), to:"invisible")
        }
    }

    public func updateNeighborVisibility(at:BlockPoint3d) {
        updateBlockVisibility(at:at)
        updateBlockVisibility(at:BlockPoint3d(x:at.x+1, y:at.y, z:at.z))
        updateBlockVisibility(at:BlockPoint3d(x:at.x-1, y:at.y, z:at.z))
        updateBlockVisibility(at:BlockPoint3d(x:at.x, y:at.y+1, z:at.z))
        updateBlockVisibility(at:BlockPoint3d(x:at.x, y:at.y-1, z:at.z))
        updateBlockVisibility(at:BlockPoint3d(x:at.x, y:at.y, z:at.z+1))
        updateBlockVisibility(at:BlockPoint3d(x:at.x, y:at.y, z:at.z-1))
    }
    
    public func render(camera:Camera, canvas:Canvas) {
        if generating {
            //generation
            let blocksPerFrame = 256
            if !terrainGenerated {
                for _ in 0 ..< blocksPerFrame {
                    generate(x:blockGenerating.x, z:blockGenerating.z)

                    print("\(blockGenerating.x), \(blockGenerating.z)")
                    
                    blockGenerating.z += 1
                    if blockGenerating.z >= worldSize.horizontal {
                        blockGenerating.z = 0
                        blockGenerating.x += 1
                    }
                    if blockGenerating.x >= worldSize.horizontal {
                        for _ in 0 ..< 128 {
                            //let treeLocation = (x:Int.random(in:0..<worldSize.horizontal), z:Int.random(in:0..<worldSize.horizontal))
                            //createTree(at:BlockPoint3d(x:treeLocation.x, y:32 + Int(8.0*(Noise(x:treeLocation.x, z:treeLocation.z, seed:seed))), z:treeLocation.z))
                        }
                        terrainGenerated = true
                    }
                }
            } else {
                for _ in 0 ..< blocksPerFrame {
                    print("    scanning blocks at \(blockScanning.x), \(blockScanning.z)")
                    for scanY in 0 ..< worldSize.vertical {
                        print("    scanning block at \(blockScanning.x), \(scanY), \(blockScanning.z)")
                        updateBlockVisibility(at:BlockPoint3d(x:blockScanning.x, y:scanY, z:blockScanning.z))
                    }
                    
                    blocksGenerated += 1
                    blockScanning.z += 1
                    if blockScanning.z >= worldSize.horizontal {
                        blockScanning.z = 0
                        blockScanning.x += 1
                    }
                    if blockScanning.x >= worldSize.horizontal {
                        generating = false
                    }
                }
            }
            frame += 1

            //render loading screen
            renderNoise(canvas:canvas, quality:64, multiplier:64, frame:frame)
            let text = Text(location:Point(x:canvas.canvasSize!.width/2, y:3*(canvas.canvasSize!.height/4)), text:"Generating World: \((50*blocksGenerated)/blocksToGenerate)%")
            text.font = "\(canvas.canvasSize!.height/64)pt Arial"
            text.baseline = .middle
            text.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(text)
            
            let generating = Text(location:Point(x:canvas.canvasSize!.width/2, y:4*(canvas.canvasSize!.height/5)), text:"Generating Terrain...")
            generating.font = "\(canvas.canvasSize!.height/128)pt Arial"
            generating.baseline = .middle
            generating.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(generating)
            
            let title = Text(location:Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height/4)), text:"IGIS_Craft")
            title.font = "\(canvas.canvasSize!.height/16)pt Arial"
            title.baseline = .middle
            title.alignment = .center
            canvas.render(FillStyle(color:Color(.black)))
            canvas.render(title)
            
            let splash = Text(location:Point(x:canvas.canvasSize!.width/2, y:(canvas.canvasSize!.height/4)+canvas.canvasSize!.height/16), text:splashTxt)
            splash.font = "\((canvas.canvasSize!.height/64))pt Arial"
            splash.baseline = .middle
            splash.alignment = .center
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:0)))
            canvas.render(splash)

            let version = Text(location:Point(x:0, y:(canvas.canvasSize!.height)), text:" v0.3.1")
            version.font = "\((canvas.canvasSize!.height/64))pt Arial"
            version.baseline = .bottom
            version.alignment = .left
            canvas.render(FillStyle(color:Color(red:255, green:255, blue:255)))
            canvas.render(version)
        } else {
            for block in nearbyBlocks(cameraPosition:Point3d(x:camera.x, y:camera.y, z:camera.z)) {
                block.renderBlock(camera:camera, canvas:canvas)
            }
        }
    }
}
