public func splashText() -> String {
    let text = ["Made with Igis/Scenes!",
                "3D!",
                "Now with Physics!",
                "Now with Trees!",
                "Mr.Ben is cool!",
                "1900+ lines of code!",
                "Swift Edition!",
                "100% guaranteed, almost bug free!",
                "Singleplayer!",
                "No more walking through walls!",
                "The IGIS servers are on fire right now!"]

    return text[Int.random(in:0..<text.count)]
}
