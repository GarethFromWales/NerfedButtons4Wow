# NerfedButtons - Vanilla WoW 1.12 Add-On 

NerfedButtons (NB) lets you define prioritised and conditional ability/item/macro lists for your actionbar buttons. NerfedButtons will automatically ensure that the highest priority ability/item/macro that passes its conditions is bound to the actionbar button slot at any time.

* Too many hotbuttons aggravating your RSI?
* Want to stimulate your brain as well as your reflexes?
* Are you a casual player who wants a chance against those 12 fingered mutants who fluidly play whack-a-mole with 48 buttons 24 hours a day?

if any of the above apply, NerfedButtons may be what you are looking for!

Disclaimer: Understanding NerfedButtons requires a modicum of effort and the exercise of a few brain cells, you have been warned...

## Your first few NerfedButtons

### A simple sequence

NBs are written as macros, you can use the basic macro window, or the Super Macro window if you need more space for long macros. Unlike the Warhammer Online version of NB, there is no graphical user interface, everything must be done via macros (for now at least).

The simplest NB would be one that simply attempts to cast a sequence of spells if they are off cooldown. NB performs basic checks like cooldown, range and positioning (think rogue's Backstab) automatically for you, so you don't need to specify such checks in your NBs. Here is a simple exmaple of such a sequence:

```
/nb [Flame Shock:target]
/nb [Lightning Bolt:target]
```

Flame Shock will be cast when it is off cooldown (every 6 seconds), Lightening Bold will be cast at all other times (as it doesn't have a cooldown). Nice!

### Adding some conditional intelligence

So far so good, but Flame Shock is a DoT that lasts 12 seconds; it seems wasteful of mana to cast it every 6 seconds. TO fix this by adding a check to the NB that looks for the Flame Shock debuff on the target:

```
/nb [Flame Shock:target][buff:target:!Flame Shock]
/nb [Lightning Bolt:target]
```

*Note: the buff check also checks for debuffs.*

The ! in front of the Flame Shock buff check inverts the check so that it only passes if Flame Shock is NOT on the target. We now have a NB that will Cast Flame Shock whenever it is not on the target and is available to cast (not on cooldown, in range, you have enough mana, etc.).

### NB Shorthand !

Instead of having to type the full name of a spell/item you can abbreviate it as follows:
1. If the spell is a single word long, then just provide the first 3 letters.
2. If the spell is more than a single word, provide the first letter of each word.

For example:
```
/nb [Thorns:target][buff:target:!Thorns]
/nb [Mark Of The Wild:target][buff:target:!Mark Of The Wild]
```
becomes:
```
/nb [tho:target][buff:target:!Thorns]
/nb [motw:target][buff:target:!Mark Of The Wild]
```
In addition the target and checks can also be shortened, making your NBs very compact and very unlikely to go over th 255 character limit (which you can obviously do anyway if you use the SuperMacros addon).
```
/nb [tho:t][b:t:!Thorns]
/nb [motw:t][b:t:!Mark Of The Wild]
```
See the cheatsheet at the end of this document for a full list of abbreviations.
Finally we can shorten the name of the buff/debuff we are looking for. 
```
/nb [tho:t][b:t:!tho]
/nb [motw:t][b:t:!motw]
```

### What about killing those pesky Turtle WoW Paladins? :)

Turtle WoW has more than its fair share of Paladins, none of whome chose the class due to its PVP dominance. Here is a simple NB to aid the Shaman class purge those shields off of a Paladin and do some damage. 

```
/nb [Purge:target]:[buff:target:Divine Shield]
/nb [Purge:target]:[buff:target:Blessing of Protection]
/nb [Flame Shock:target][buff:target:!Flame Shock]
/nb [Earth Shock:target]
/nb [Lightening Bolt:target]
```

or in its shortened form:

```
/nb [pur:t]:[b:t:ds]
/nb [pur:t]:[b:t:bop]
/nb [fs:t][b:t:!fs]
/nb [es:t]
/nb [lb:t]
```

*Disclaimer: I'm very aware that Shamans can also be considered OP, just some humour, don't shoot me please.*

### Targetting

In addition to ```target```, other valid targets include: ```player, focus, targetoftarget```. For example:

```
/nb [Rejuvenation:player][buff:player:!Rejuvenation]
/nb [Regrowth:player][buff:player:!Regrowth][health:player:<80]
/nb [Healing Touch:player][health:player:<70]
```

### Smart Targetting

And here is an example of  ```smart``` targeting to cure conditions on party members if they are inflicted. There is no fixed target for this NB, the target is calculated at runtime by whomever passes the checks first. The first party member that matches the checks is Cured/Cleansed. Such NBs can be used to keep the raid relatively clean of debuffs or heal the raid member with the lowest health, there are lots of possibilities.

```
/nb [Cure Poison:group][con:smart:poison]
/nb [Remove Curse:group][con:smart:curse]
```

This could be improved to use Abolish Poison that auto cleanses Poisons for 8 seconds. We just need to check for the Abolish Poison buff.

```
/nb [Abolish Poison:party]:[con:party:poison][buff:party:!Abolish Poison]
/nb [Remove Curse:party]:[con:party:curse]
```

### Summary

Hopefully by now you've seen some of the posibilities of NB and are considering how you can use it to improve your play, be it PVE or PVP. Writing this addon has taken me away from levelling my main for at least 8 hours, so please say thank you if you like the addon and see Tempeh my Tauren Druid in-game on the Turtle WoW PVP realm :)

The remainder of the documenation covers the syntax and available options in more detail. Use it as a reference manual when creating your NBs. Good luck!

# NerfedButtons Cheat Sheet

## NerfedButtons Syntax

NB consists of one or more lines of actions, one action per line. NB considers each line in turn, if the checks pass for an action, then the action is cast/used/done. Execution then moves onto the next line. WoW limits only one ability/spell/item per keypress, therefore the first action that passes its checks will get performed. 

`/nb [action][check1][check2][check3]...`

The action consists of 2 parts, the name of the action and the target for the action. An action can be the name of a spell, item or a special NB action ( more on this later):

`/nb [action_name:action_target][check1][check2][check3]...`

A check consists for 3 parts; the type of check to perform, the target the check is made against, and any supporting value required by the specific check: 

`/nb [action_name:action_target][check1_type:check1_target:check1_value][check2][check3]...`

You can have a NB without any checks at all, this is useful if you just want to use internal WoW checks like cooldown  and not have any additional custom checks:

`/nb [action_name:action_target]`

## Actions

### Action_Name

* ```<action_name>``` is the name or ID of any spell, item, ability or special NB action. Note that spells have different names in differnt languages, therefore you'll need to modify any NBs you copy from the internet if they are not native to your WoW client language.

Actions are either spelled out in full or abbreviated:

* Mark of the Wild => motw
* Thorns => tho

1. If the spell is a single word long, then just provide the first 3 letters.
2. If the spell is more than a single word, provide the first letter of each word.

  There are also a number of special NB actions. These include:
  * TODO: `Attack` (stop auto attack, be it melee, ranged or bow)
  * TODO: `Stop` (Stop attacking and casting)  
  * TODO: `StopAttack` (Stop attacking)  
  * TODO: `StopCast` (Stop casting)  
  * TODO: `StopCast` (Stop casting)  


### Action_Target

* ```<action_target>``` is the target for the action. Basic values include:
  * `player`
  * `target`
  * TODO: `focus`  
  * TODO: `targetoftarget`

  ```
  /nb [Rejuvenation:focus][health:focus:<90]
  /nb [Wrath:target]
  ```

  In addition there are special ```smart``` targets that are calculated at runtime based on the conditions associated with a NB. These smart targets include:
  * `group` (only targets the 5 party members even in a raid)
  * `raid` (will target any raid member or party member if not in a raid)
  * TODO: `tanks`
  * TODO: `dps`
  * TODO: `healers`

  always use the word smart (or 's') for the target of your checks when using smart targetting:

  ```
  /nb [Cure Poison:group][con:smart:poison]
  /nb [Remove Curse:group][con:smart:curse]
  ```

## Checks

NB comes with a variety of useful checks but more will be developed over time. Here is the current list:

#### Check_Type

* ```<check_type>``` is the type of check you want to perform. Valid values include:
  * `b` or `buff` (this also checks for debuffs)
    * ```[buff:player:!Mark Of The Wild]``` 
  * `h` or `health` (checks if the health is above, below, equal to a percentage of the maximum)
    * ```[health:player:<80]```   
  * TODO: `rh` or `rawhealth` (checks if the health is above, below, equal to a specific value)
    * ```[rawhealth:player:<520]```    
  * `p` or `power` 
    * ```[power:player:>15]```  
  * TODO: `rp` or `rpower` (checks if the power is above, below, equal to a specific value)
    * ```[rawpower:player:<750]```    
  * TODO: `m` or `mana` (druid specific check that can be used in forms to check mana percentage)
      * ```[mana:player:>130]```    
  * TODO: `rm` or `rawmana` (druid specific check that can be used in forms to check mana value)
      * ```[rawmana:player:>150]```    
  * `con` or `condition` (short for condition, can be (c)curse, (p)poison, (m)magic, (d)disease)
    * ```[con:player:poison]```
  * `cla` or `class` (checks class of target)
  * TODO: `role` (checks role of target)
  * TODO: `equip` (checks if a piece of equipment is equipped)
  * TODO: `bag` (checks if an item is in a bag)

  There are also a number of special ```<checktype>``` that are only valid with ```smart``` targets. These include:
  * TODO: `lhealth` (lowest health)
  * TODO: `lmana` (lowest mana)

#### Check_Target

  * `player`
  * `target`
  * TODO: `focus`  
  * TODO: `targetoftarget`

#### Check_Value

The value associated with the check to test against.


### History (War, RIFT, Age of Conan)

NerfedButtons (or NB for short) was originally written for Warhammer Online and had a love/hate relashionship with players and developers alike. Some claimed it dumbed down the game too much, whilst others loved the freedom it gave them to simplify overly complex keybindings so they could focus on gameplay. NB only did what was allowable by WAR API and as such was not against the TOS.

The original NB was text only, but  a couple of great developers joined the team who produced a user interface that greatly improved the accessability of NB to those who were scripting adverse.

Much later, versions were written for Rift and Age of Conan which offered similar functionality but only really implemented as a technical challenge. The implimentations however were clearly against the TOS and as such the addons were poorly documentated and maintained.

Warhammer Online: Return of Reckoning brought about a revival of WAR and the controversy of NB. Ultimately the WAR developers found a way to limit the API and make NB unuseable in its current form. The developer of NB decided to adhere to the decision and not work on any workarounds, a death knell for the addon.

### Vanilla WoW (e.g. Turle WoW)

Vanilla WoW provides a powerful API that can be called by macros and addons, much more complete that Classic or Retail. NB for Vanilla WoW makes a lot of sense as like the original WAR implimentation, only does what the API allows, and in fact there are already widely used other addons (e.g. Super Macros) that provide very similar capabilities to NB but can require knowledge knowledge of LUA. NB is aimed at everyone, no need to understand the LUA scripting language to make complex macros.

## Known Limitations

Unfortunately unlike Classic and Retail WoW, the icon associated with a button is fixed, therefore you should consider which ability icon in your sequence makes sense.


## Lots of Examples :)

### General

### Druid

### Mage

### Paladin

### Priest

### Rogue

### Shaman

### Warlock

### Warrior



