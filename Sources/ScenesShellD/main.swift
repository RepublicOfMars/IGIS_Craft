import Igis

print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:Director.self)
} catch (let error) {
    print("Error: \(error)")
}

