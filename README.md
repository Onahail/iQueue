# iQueue

**This is not yet finished, not all functionalities implemented**

**[Installation](#Installation)**

## To-Do List:
- Custom border color depending on queue type (research, upgrade, unit)
  * Can be disabled
  * Colors can be changed
- On hover tooltip of ability
- Queue stopping when resources run out
- Implement second queue style for units
- Rally point interaction with trees
- Rally point interaction with other units
- Implement population
- Implement resource control
- Implement harvesting system

## Contents

#### Core iQueue Features
- Queue System
- Ability Research
- Unit/Building Upgrades
- Unit Creation

#### Modular additions
In addition to the core features of iQueue you'll also find these modular additions to the system which can be fully disabled in the iQueue settings.
- Population
- Resource Control
- Harvesting


## Content Descriptions
Lua based Queue system with interactive Panorama UI
- Countdown timer on the first slot to indicate build time remaining
- Cancel anything in the queue at any time by clicking on its respective slot
- Image on queue will indicate what is being built

Unit Creation
- Building units on multiple buildings simulatenously as long as resources allow
- Will skip over any buildings without the capability of doing so
- Two seperate queue styles (specified in settings)
  * Type 1: Resources deducted immediately
    - Example: Unit A costs 50 gold, you have 6 buildings and 400 gold.
      ~ First Cast: Unit A queued up on all 6 building
      ~ Second Cast: Unit A only queued on main selected building and 1 other.
  * Type 2: Queue as many units as player wants, resources will be deducted on build start.
    - Queue will pause if resources no longer allow, and restart and deduct resources immediately when available

Rally Points
- Apply a rally point for any building labled with "CanRally"
- Rally point flags hide themselves when the building isn't selected
- Panorama UI button to remove the rally point for every selected building
- Right click on a unit to have new units spawned automatically rally to the location of that unit
  * Rally point follows the unit
  * Three interactions that can be specified by user upon selected rally units death
    ~ Rally point drops to units death location
    ~ Rally point jumps to the nearest friendly unit
    ~ Rally point is removed
- If the Harvesting module is utilized, the following is also available
  * Right click on a tree to automatically send harvesters to rally there
    ~ Only available to buildings labeled as both "ResReturn" and "CanQueue"
    ~ If only labeled as "ResReturn" it will still be tracked for resource returning.

Research
- Removes the ability from every other building owned and created while in queue
- Removes the ability from every other building owned and created after completion
- Replace the disabled version of each ability with the usable ability after completion
- Full interaction with tech trees to determine what needs to be researched to make something available
- Multiple researches can be queued at one building and they will be pushed to other buildings with the ability
- Resources will be deducted immediately upon cast

Upgrades
- Removes the ability from every other building owned and created while in queue
- Removes the ability from every other building owned and created when max rank
- Modifier based upgrades
  * Will apply the upgrade via modifier, and add a stack depending on rank (*Upgrades must be same value each level)
  * For any upgrade that changes something other than stats, the modifier will simply be a check
- Upgrades will be applied to all existing and future created units/structures
- Multiple upgrades can be queued at one building and they will be pushed to other buildings with the ability
- Resources will be deducted immediately upon cast

Population
- Will control population count. User can set max and base population in settings
- Any building labeled "PopSource" will increment the population max up to max value
  * Population value for that building can be specified in units KV as "PopValue"
- Any unit or building labled "PopCost" will increment the players current population up to the current max population
  * Population cost for that building can be specified in units KV as "PopCost"

Resources
- Currently has functionality to handle Gold, Lumber, and Population
  * If custom resources need to be added feel free to either edit the code or put in a suggestion
- Functions to modify lumber, gold, and population are handled by a class each player is part of.
- Queue works with player resouces, incremeating and decrementing as things are added, completed, or cancelled
- Panorama UI layout for Gold, Lumber, and Population
  * Each can individually be disabled depending on what the user wants

Harvesting
- Full functionality to handle harvesting trees. 
- Units labeled as "CanHarvest" will automatically be given the appropriate abilities upon spawn.
  * No need to add those abilities to each unit
- Resource return point tracking. Buildings labeled as "ResReturn" will be utilized for depositing resources.
  * Will return to the nearest resource return structure in terms of pathing distance

## Installation

This is not yet finished. Installing it now would be pointless



Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vel porta magna, in finibus justo. In facilisis erat quis pulvinar interdum. Vestibulum et dignissim justo, sed pellentesque dolor. Nullam dui quam, eleifend non ullamcorper eu, tristique dapibus lorem. In ultrices iaculis ultrices. Vivamus vitae quam sit amet lorem pulvinar tristique sit amet nec enim. Quisque non aliquam sapien. Duis vehicula rutrum gravida. Etiam in dolor urna. Duis eget dapibus magna, quis congue elit. Duis sagittis lacus elit, sit amet feugiat tellus consectetur quis. Ut sagittis ac est lacinia ornare. Morbi a porttitor diam. Mauris elementum libero sem, nec sollicitudin enim luctus in. Aliquam posuere volutpat nibh, vel sodales ante sollicitudin ut. Integer quis commodo nisl.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut blandit erat cursus eros placerat imperdiet. Phasellus facilisis arcu posuere fermentum ultrices. Aenean hendrerit dolor quis ex scelerisque efficitur. Nunc pulvinar leo elit, sed ultricies lorem posuere tincidunt. Interdum et malesuada fames ac ante ipsum primis in faucibus. Mauris id consequat purus. Suspendisse dignissim euismod auctor. Integer aliquam ut velit sed dictum.

In gravida leo nisi, a consectetur ligula pharetra ac. Proin venenatis pulvinar odio, at mattis quam cursus at. Vivamus pellentesque ac est quis euismod. Nulla mattis, risus nec vestibulum consequat, quam quam blandit libero, vitae placerat nunc leo nec velit. Aenean vestibulum arcu eget justo iaculis lobortis. Suspendisse eu porttitor enim. Donec imperdiet, turpis sit amet malesuada vulputate, lectus quam vehicula turpis, non blandit lectus nunc sed nunc. Pellentesque iaculis vulputate metus eu semper. Suspendisse sed congue lectus. Nulla eget orci in lorem facilisis finibus sed quis elit. Proin a est interdum, egestas elit at, bibendum ante. Suspendisse pretium tempor risus, non hendrerit lectus tincidunt non. Fusce in commodo mauris. Quisque sem lorem, dapibus in pulvinar a, hendrerit vel lectus.

Fusce malesuada diam id pellentesque imperdiet. Maecenas eu nibh urna. Nulla lacus enim, viverra ut ante ut, fringilla tincidunt lacus. Nullam dapibus, orci at aliquam convallis, massa libero viverra tellus, et lobortis enim erat quis justo. Integer est turpis, mattis vel porta ac, vehicula et ante. Mauris blandit id augue quis mattis. Sed imperdiet eget velit quis egestas. Aliquam nulla nisi, condimentum id imperdiet ac, vestibulum eget nunc. Donec nec eros odio. Praesent vulputate lectus quis ipsum porta commodo. Phasellus lobortis enim vitae efficitur finibus.

Aliquam erat volutpat. Vivamus quis facilisis diam, sit amet lobortis eros. Mauris pellentesque quam et venenatis viverra. Integer non rhoncus sapien. Nunc ut nibh quis leo interdum hendrerit. Etiam cursus sapien at dolor ornare vehicula. Morbi nec odio at augue aliquam sollicitudin. Morbi pulvinar quam a dui viverra aliquam. Vivamus gravida vehicula mauris, viverra interdum mi porttitor sit amet. Ut viverra mi vitae nibh convallis vulputate. Fusce id pulvinar arcu, eget viverra leo. Aenean at enim sit amet purus vulputate commodo. Morbi eget dolor sit amet nisi maximus commodo. 
