/*
ScenesShell provides a minimal framework for starting Scenes projects.
Copyright (C) 2020 Tango Golf Digital, LLC
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Igis
import Scenes

/*
 This class is primarily responsible for transitioning between Scenes.
 At a minimum, it must enqueue the first Scene.
*/
class ShellDirector : Director {
    required init() {
        super.init()
        enqueueScene(scene:MainScene())
    }

    override func framesPerSecond() -> Int {
        return 30
    }

}

