# iQueue

**This is not yet finished, not all functionalities implemented**

**[Installation Instructions](https://github.com/Onahail/iQueue/blob/master/Installation_Instructions.md)**

## To-Do List:
- Custom border color depending on queue type (research, upgrade, unit)
  * Can be disabled
  * Colors can be changed
- Queue stopping when resources run out
- Implement second queue style for units
- Rally point interaction with trees
- Rally point interaction with other units
- Implement population
- Implement resource control
- Implement harvesting system

## Content

#### Core iQueue Features
The following functions will be handled by iQueue baseline.
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
##### Lua based Queue system with interactive Panorama UI
- Countdown timer on the first slot to indicate build time remaining
- Cancel anything in the queue at any time by clicking on its respective slot
- Image on queue will indicate what is being built
- Hovering over the queue slot when something is being built displays a cancel symbol

##### Unit Creation
- Building units on multiple buildings simulatenously as long as resources allow
- Will skip over any buildings without the capability of doing so
- Two seperate queue styles (specified in settings)
  * Type 1: Resources deducted immediately
    - Example: Unit A costs 50 gold, you have 6 buildings and 400 gold.
      ~ First Cast: Unit A queued up on all 6 building
      ~ Second Cast: Unit A only queued on main selected building and 1 other.
  * Type 2: Queue as many units as player wants, resources will be deducted on build start.
    - Queue will pause if resources no longer allow, and restart and deduct resources immediately when available

##### Rally Points
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

##### Research
- Removes the ability from every other building owned and created while in queue
- Removes the ability from every other building owned and created after completion
- Replace the disabled version of each ability with the usable ability after completion
- Full interaction with tech trees to determine what needs to be researched to make something available
- Multiple researches can be queued at one building and they will be pushed to other buildings with the ability
- Resources will be deducted immediately upon cast

##### Upgrades
- Removes the ability from every other building owned and created while in queue
- Removes the ability from every other building owned and created when max rank
- Modifier based upgrades
  * Will apply the upgrade via modifier, and add a stack depending on rank (*Upgrades must be same value each level)
  * For any upgrade that changes something other than stats, the modifier will simply be a check
- Upgrades will be applied to all existing and future created units/structures
- Multiple upgrades can be queued at one building and they will be pushed to other buildings with the ability
- Resources will be deducted immediately upon cast

##### Population
- Will control population count. User can set max and base population in settings
- Any building labeled "PopSource" will increment the population max up to max value
  * Population value for that building can be specified in units KV as "PopValue"
- Any unit or building labled "PopCost" will increment the players current population up to the current max population
  * Population cost for that building can be specified in units KV as "PopCost"

##### Resources
- Currently has functionality to handle Gold, Lumber, and Population
  * If custom resources need to be added feel free to either edit the code or put in a suggestion
- Functions to modify lumber, gold, and population are handled by a class each player is part of.
- Queue works with player resouces, incremeating and decrementing as things are added, completed, or cancelled
- Panorama UI layout for Gold, Lumber, and Population
  * Each can individually be disabled depending on what the user wants

##### Harvesting
- Full functionality to handle harvesting trees. 
- Units labeled as "CanHarvest" will automatically be given the appropriate abilities upon spawn.
  * No need to add those abilities to each unit
- Resource return point tracking. Buildings labeled as "ResReturn" will be utilized for depositing resources.
  * Will return to the nearest resource return structure in terms of pathing distance
