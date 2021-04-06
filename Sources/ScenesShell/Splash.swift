public func splashText() -> String {
    let text = ["Made with Igis/Scenes!",
                "3D!",
                "Now with Physics!",
                "Mr.Ben is cool!",
                "1400+ lines of code!",
                "Swift Edition!",
                "\"100%\" bug free!"]

    return text[Int.random(in:0..<text.count)]
}
