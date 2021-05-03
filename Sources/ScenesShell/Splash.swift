public func splashText() -> String {
    let text = ["Made with Igis/Scenes!",
                "3D!",
                "Now with Physics!",
                "Now with Trees!",
                "Mr.Ben is cool!",
                "2400+ lines of code!",
                "Swift Edition!",
                "100% guaranteed, almost bug free!",
                "Singleplayer!",
                "No more walking through walls!",
                "The IGIS servers are on fire right now!",
                "Now with better Render Distance!"]
    
    let quotes = ["\"I'm a doctor, not a world-builder!\" -McCoy, early 2300s",
                  "\"Eat any good books lately?\" -Q, late 2300s",
                  "\"Stop playing Minecraft in class\" -All of my teachers, 2021"]

    if Int.random(in:0..<4) != 0 {
        return text[Int.random(in:0..<text.count)]
    } else {
        return quotes[Int.random(in:0..<quotes.count)]
    }
}
