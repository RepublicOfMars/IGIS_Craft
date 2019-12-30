import Igis
import Scenes

class Director : DirectorBase {

    
    required init() {
    }
    
    override func nextScene() -> Scene? {
        return nil
    }
    
}

print("Starting...")
do {
    let igis = Igis()
    try igis.run(painterType:Director.self)
} catch (let error) {
    print("Error: \(error)")
}

