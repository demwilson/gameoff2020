# SAAN: Lunar Flares
SAAN: Lunar Flares is a 2D rogue-lite dungeon crawler with a time-based combat system. It was developed for
[Game Off 2020](https://itch.io/jam/game-off-2020). It is also our first attempt at developing a game using the Godot
engine.

## Game Details
SAAN: Lunar Flares is a 2D rogue-lite dungeon crawler with an extremely light story. It has three major gameplay aspects:
1. the Overworld, where you move through the randomly generated facility floors looking for lootable chests; 
2. Combat, which uses a time-based combat system, and a simple selection menu for choosing the player abilities; and
3. SAAN Ground Control, which allows the user to upgrade the equipment and stats of the next astronauts sent out.   

The rogue-lite aspect allows the player to upgrade the next astronaut before the next mission to allow them to get further 
through the game and eventually escape the facility.

## Story
In the near future, the nations of the world come together in peace. Among other things, a common goal is set: sending a
man to Mars. After a few short years, the Space Administration Across Nations (SAAN), successfully launches the first 
manned space expedition to Mars. The world rejoices, but the victory is quickly forgotten.

Years later, after severe budget cuts and conflicting agendas, SAAN decides it needs to fund itself rather than depend on
the world nations. SAAN's internal reports show there has been a sudden increase in 
[lunar flares](https://en.wikipedia.org/wiki/Transient_lunar_phenomenon). Curious and hopeful, SAAN outfits a single 
astronaut with enough equipment to survive, and launches him to the moon.

Upon landing the astronaut notices metallic doors. He approaches the doors and they open of their own accord. The 
astronaut knows this place wasn't created by SAAN. In fact, no one has been here in years. Consumed by curiosity, 
and with a tight hold on his trusty crowbar, he enters the gravity encased structure. Once inside, the doors close,
and he cannot open them. He will need to explore the facility and escape before he runs out of oxygen!

## Gameplay
### How to Play
Here are some basic instructions on how to play or interact with the game on the various screens.
#### General
* Press **Esc** to bring up settings (does not work during combat).  
* Press **P** to pause the game.
* Press **H** to open the controls page.
#### Overworld
When in the overworld:
* Move the astronaut using the **arrow keys** or **WASD**.
* Move into doors, and chests to open them.
* Move onto ladders to go to the next floor.
* Press **C** or **I** to view the astronaut's stats. 
* You may be attacked while walking around on the Overworld, which will take you to the combat screen.
#### Loot
When on the loot screen:
* Press **space bar** or **enter** to close the screen. You can also **left click** the button as well.
#### Astronaut Stats
When on the Astronaut Stats screen the following stats will be displayed.
* Name of the Astronaut
* Current HP/Max HP
* Current Oxygen/Max Oxygen

Then a section of the stats used for combat in the combat screen. A plus sign (+) next to the stat number indicates a bonus from an item.
* Attack - How much damage you deal to a target.
* Accuracy - The capacity of your attacks to be able to hit your target.
* Speed - How fast your time bar fills in combat.
* Defense - How much damage you resist from a target.
* Evade - The potential of dodging an attack from a target.

Next are abilities that the astronaut learns and acquires from items picked up throughout the game. 
The last section is equipment which provide a list of items you have picked up throughout the game.

**NOTE**: You may hover over each item with your mouse to provide information on what the item is.

#### Combat
When in combat, you must wait for the astronaut's action bar to fill before you can choose an action.

Once the action bar is filled:
* Move the arrow selector using the **arrow keys** or **WASD**.
* Press **space bar** or **enter** to select an ability and/or an enemy pointed at by the arrow selector.

The action selected is placed in a queue, and the player will take that action without any further inputs.

**NOTE**: Once the action is complete, the action bar will begin to fill and, once it is filled again, you'll need to 
make selections again.

### Tips
Here are some basic tips to follow while playing the game:
* The currency of this game is **Moon Rocks**. Collect them to purchase upgrades for the next astronaut sent to the moon.
* Each step costs oxygen on the Overworld, so be wary of wasted steps and dead ends.
* Open chests to get helpful equipment. Each chest will contain one of the following: currency, oxygen, or items.
* Combat doesn't wait for you to take an action, so be quick making your selections.
* Each monster has a combat pattern. Learn the patterns to help you make the right decisions during combat.
* Open the Character Screen (using **C** or **I**) to see what abilities and items you have available. 
* Your allies, if you have picked any up, will always aid you each fight, even if they died in a previous battle.
