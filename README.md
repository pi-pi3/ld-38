# LD 38 game

# Customization
To customize this repository for your project, you'll have to do the following:
- customize config.mk
- customize this README
- change the copyright holder in LICENSE, src/main.lua and src/menu.lua
- change the name of the game in the following places:
 - release/linux/launch.sh (game title, aka $GAME)
 - release/mac/ld-38.app (the name of this directory)
 - release/mac/ld-38.app/Info.plist (all places marked with #XXX)
 - src/conf.lua (t.identity and t.window.title)

## **SPECIAL NOTE** concerning licenses
The license in both the LICENSE file and the src/main.lua and src/menu.lua files
claims, that you're not allowed to claim you wrote this software. Since, at this
moment - the 21st of April, this repository is just a template, you're allowed to
change modify those 3 mentioned licenses as well the copyright holder. The other
two source files, i.e. src/gui.lua and src/util.lua are pieces of software I wrote
earlier and you may not change the licenses in them or claim you wrote them.
src/conf.lua is not considered a source file, as it's only a configuration file,
hence it doesn't have a license.  
tl;dr: license notices 1., 2. and 3. of the zlib license are allowed to be ignored
for customization purposes of this template, but only in the following files:
`src/main.lua`, `src/menu.lua`, `LICENSE`.
