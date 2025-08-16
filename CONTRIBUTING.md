# Contributing guidelines

- [Roadmap](#Roadmap)
- [How to contribute](#how-to-contribute)
- [Requirements to contribute](#requirements-to-contribute)
- [Setting up the development environment](#setting-up-the-development-environment)
- [Coding guidelines](#coding-guidelines)

## Roadmap
### Phase 1: One island to rules them all
#### v0.01
- load a map with only one island like : development, singularity-40 or test-map-tiny.
- Handle autotile
- Put a warehouse on it
- Generate trees
- Ticks based game. Instead of simulating each worker or transporter, the game will follow a clock. Each tick something can happen, like producing resources. Also, the game has “cycles”, which represent X numbers of ticks.
- Magic merchant : you can buy or sell goods to a magic merchants (the merchant boat will come in the next version). Each cycle, buy/sell happens.
- Player interactions :
  - construct a building
  - select a building
  - destroy a building
  - move a building (like in anno 1800)
  - create new order (buy/sell resources, it works like in anno 1800) in the market
  - move the camera with keys or cursor on window borders
  - open an ingame menu with buttons save, return to the menu, or quit
  - When save open a popup menu to ask the save name
  - When quit open a confirmation popup to ask if save and quit or quit without save
- The player can build :
  - lumberjack, produce wood, cost  (1 wood, 1 textile)
  - tent, residential level 1, increase population, cost  (1 wood, 1 textile)
  - If player construct on tree he loses money but wins wood
  - For now, there is no roads, it will come in next version
  - For now, residential are constructed with the max people in it
  - For now, you cannot set the number of workers in producing buildings. They hire as many people as they can.
  - For now, lumberjack produce wood magically
- Give some resources at the beginning (wood, tissu, money)
- HUD :
  - the player can see the productions of resources each cycle (here log and meat but another will come). With the production score (by example if I have 4 tons of logs in stock, produce 5 tons and use 3, it display 4(+2) )
  - population amount with unemployed or required people (same like for main resources. If you have a population of 5 people and production buildings need 2: 5(-2)).
  - money with statistics (sells, buys)
  - the building menu when select a building, with info and a button to destroy it
  - a menu to construct buildings
  - a menu for the market, where the player can create new order
  - an icon on a building when it does not have enough workers
- Menus :
  - Main menu with buttons play, load and quit
  - A loading screen

#### v0.02
- Give some planks at the start
- The player can build:
  - Hut, residential level 2, increase population of pioneers, (cost planks)
  - Lumberjack barracks, produce planks from wood, resource level 2, (cost planks)
  - Now tent increase the population of sailors
  - Sailors cannot do task of pioneers, and vice-versa
  - Sailors are used to gather resources, for example wood
  - Pioneers are used to produce resource level 2, for example wood to planks.
  - Lumberjack cannot be constructed too close to each other. Avoid too many lumberjack. 2/3 per island can be great.
- HUD:
  - The player can see the different population amounts with unemployed or required people.

#### v0.03
- The player can build :
  - Farm, to connect farm component to it
  - Pigsty, produce pig, is a farm component
  - Potato field, produce potato, is a farm component
  - Butchery, produce meat from pig, resource level 2
  - A farm component can be constructed only if it collides with a farm or another farm component.
- Now, each cycle tent consumes 4 of the most available resources. It takes it each one by one.
- Now, each cycle hut consumes 1 meat + 1 potato + 2 of the most available food resources.
- When residential (tent or hut) consumes food resources, they pay taxes based on the food resource cost.
- If a residential cannot consume all resources it needs, the people in it leave waiting for the next cycle. During this time the population decreased.
- Now, producing buildings consume X money each tick.
- HUD :
  - The player can see when a residential is abandoned

#### v0.04
- Generate stone deposit
- The player can build:
  - Stone pit, produce stone from stone pit, resource level 1
  - Pasture, produce wool, is a farm component, resource level 1
  - (Storage tent), produce wool ball from wool, resource level 2
  - Weaver, produce tissue from wool ball, resource level 3
  - House, resident level 3, increase population of settlers
  - Corn field, produce corn, is a farm component
  - Windmill, produce flour from corn, resource level 2
  - Bakery, produce bread from flour, resource level 3
  - Settlers are used to produce resource level 3
  - Each cycle house consumes 1 meat + 1 potato + 1 bread + 1 of the most available food resources.

#### v0.05
- procedural generation of an island (in tetris shape)
- with money the player can buy another island within 3 proposals. He can sees the minimap of each islands
- Player interactions :
  - Buy a new island. Select the amount of resource to send for the beginning of the new island.
  - Create trade route between his islands
- HUD :
  - A button or a combo box to change island (use the loading screen when change island)
  - A button to show a summary screen (with all stats by islands, gains, resources, …)
  - the island scene can be keeped in memory as it is, or unloaded and just save the trade route rate.

#### vX (not commited)
- Animated buildings
- Balancing. Decide tick and cycle duration. Production rate of each producing building. Resources costs. Do the excel things…
- Generate resource deposit fish
- Sounds (musics, and bip bip boop)
- Generate wildlife with sounds for the ambiance
- Idea: Each island can have only one type of field and pasture. This encourages the player to buy multiple islands.
- Camera zoom in / zoom out
- The player can build :
  - fisherman, produce fish (wait 0.04 / 0.05 to have rules to construct building with special placement rules)
  - road
  - storage
  - mainsquare
  - brewery / distillery (produce alcohol for tavern)
  - tavern (consume alcohol, increase happiness, happiness affects taxes)
  - toolmaker (tools increase production rate of the producing building who consume it)
  - boat_builder (fishing ship, ship for trade)
- HUD :
  - an icon on a building when it is not connected to a road
  - the player can select the amount of people working in a production building
  - update the icon on a building when it does not have enough workers, it only appears when the amount is equal to 0.
- Entities :
  - Carriers (the player see them carrying resources between production buildings and/or storage) (They follow roads)
  - Fishermans (the player sees them moving and fishing on fish deposit near the coast)
  - Fisherboat
  - Merchant boat
  - Trade boat
  - Wildlife (the player sees them moving inside the woods, or flying in the sky)
  - Lumberjacks (the player sees them moving to cutting wood)
  - Citizens (the player sees them walking from their house to the mainsquare to bring back goods or to producing building)

#### v0.1 Polishing
- Handle languages
- Add an options menus to mainmenu to set :
  - languages
  - scroll at map edges
  - cursor centered zoom
  - middle mouse button pan
  - mouse sensitivity
  - autosave interval and number of it
  - number of quicksaves
- Add the option menu in the ingame menu
- At this version we obtain the essentials of a game like anno in the solo version. We can play it a lot and it is a good base for next phases.

### Phase 2 : Big Tetris Map
#### v0.2
- Remove the feature to buy generated islands
- Generate a map with islands (different tetris shape, different climate)
- Generate a special island for the magic merchant
- The player can build :
  - warehouse (from the a boat who can colonize)
  - boat_builder (ships to colonize)
- HUD:
  - An information bubble when a colonization ship arrived to an another island

### Phase 3 : Disasters

## How to contribute

To contribute to the project, get started by checking the [current issues](https://github.com/unknown-horizons/godot-port/issues) or [add a new one](https://github.com/unknown-horizons/godot-port/issues/new/choose) for bug reports and suggestions. Also, as this is a complete rewrite, it is basically possible to apply improvements on certain aspects of the game from the start on whenever it makes sense. That said, if you know and love the original title and are well familiar with its in and outs, we'd appreciate your opinion on the current gameplay mechanics and economic balances. To discuss more directly with other contributors, visit our [Discord server](https://discord.gg/VX6m2ZX).

At the point of this writing, the Godot port is in an early experimental state with no playable content and therefore no release date set in stone.

For that reason, please check out the [original project](https://github.com/unknown-horizons/unknown-horizons) which bears a decade long active development history with tons of implemented features and will provide you a better insight on the desired look and feel than any textual explanation could do (even more so if being unfamiliar with RTS games). Besides you should be able to grab existing logic and convert it appropriately for the Godot/GDScript style.

## Requirements to contribute

This project is based on the [Godot Engine](https://godotengine.org/) using a [Python-like scripting language](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html). To learn more about it, get started at [the official docs](https://docs.godotengine.org/en/stable/).

For further learning resources made by individual creators, you can find a rich overview of qualitative material enlisted [here](https://docs.godotengine.org/en/stable/community/tutorials.html).

A valuable source of information specifically for this project would be RTS-specific Godot material.

## Setting up the development environment

1. Fork <https://github.com/unknown-horizons/godot-port>.
1. Clone the fork locally.
1. Download [Godot 4.x.x](https://godotengine.org/download/), at least the standard version required.
1. Launch the Godot executable.
1. Import project, search the Unknown Horizons directory, select `project.godot`.
1. Open the project from the project manager overview.

## Coding guidelines

For the most part, the code style follows the [official GDScript style guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html).

Rules different from the official style and additional remarks:

### [Static typing](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html)

When needed, for secure. Use [explicit types](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html#declared-types) or [infer the type](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html#inferred-types). In most cases, inferring with `:=` should be fine unless the exact type is indeterminable at compile-time. Make [type casts](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html#variable-casting) whenever useful. This will make the code overall [less prone to errors](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html#safe-lines). We cannot specied type on custom signals, so at least add comment to help other developers:

```gdscript
signal notification(message_type, message_text) # int, String
```

### Warnings
- Some methods return values that may be irrelevant depending on your use case, like `SceneTree.change_scene_to()` or `Object.connect()`. To suppress the warning dispatched by those, hit the `[Ignore]` button next to the warning message in Godot's warnings overview. This generates a specific line to explicitly acknowledge this circumstance. Indent it above the involved method call. That should look like this:

```gdscript
#warning-ignore:return_value_discarded
get_tree().change_scene_to(_scenes[scene])
```

- For warnings about unused method parameters however, prepend the parameter(s) in question with an underscore like this:

```gdscript
func _process(_delta: float) -> void:
    pass
```

- Generally, **one** line break is to be placed where it says **two** in the official guide.

As always, there may be an exception from the rule, but those should be kept to a minimum and be reasonable.
