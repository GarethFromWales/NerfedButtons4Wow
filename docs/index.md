# NerfedButtons - Vanilla WoW 1.12 Add-On 

NerfedButtons (NB) lets you define prioritised and conditional ability/item/macro lists for your actionbar buttons. NerfedButtons will automatically ensure that the highest priority ability/item/macro that passes its conditions is bound to the actionbar button slot at any time.

* Too many hotbuttons aggravating your RSI?
* Want to stimulate your brain as well as your reflexes?
* Are you a casual player who wants a chance against those 12 fingered mutants who fluidly play whack-a-mole with 48 buttons 24 hours a day?

if any of the above apply, NerfedButtons may be what you are looking for!

Disclaimer: Understanding NerfedButtons requires a modicum of effort and the exercise of a few brain cells, you have been warned...

## Installation

1. Download the latest version from https://github.com/GarethFromWales/NerfedButtons4Wow/archive/refs/tags/v1.0.zip
1. Open the zip file and drag the folder NerfedButtons4Wow-1.X to your TurtleWow/Interface/Addons folder
1. Rename the folder from NerfedButtons4Wow-1.X to NerfedButtons4Wow
1. Restart Turtle WoW

## Your first few NerfedButtons

### A simple sequence

NBs are written as macros. Unlike the Warhammer Online version of NB, there is no graphical user interface, everything must be done via macros (for now at least).

The simplest NB would be one that simply attempts to cast a sequence of spells if they are off cooldown. NB performs basic checks like cooldown, range and positioning (think rogue's Backstab) automatically for you, so you don't need to specify such checks in your NBs. Here is a simple exmaple of such a sequence:

```
/run if nil then CastSpellByName("Flame Shock") end
/nb Flame Shock
/nb Lightning Bolt
```

this will first attempt to cast `Flame Shock` at your current target, but if for some reason it cannot be cast (it has a 6 second cooldown), then will attempt to cast `Lightning Bolt`. Nice!

The first line of the macro ```/run if nil then CastSpellByName("Flame Shock") end``` is unfortunately reuired for ALL macros to display and update an icon correctly in Vanilla WoW. Replace the spell/item name with whatever you want displayed on the icon.

### Targetting

NB always attempts to cast harmful spells against your current target. Beneficial spells are cast against your current target if it friendly, otherwise will be cast against the player. This behaviour can be enforced by providing a target:

```
/run if nil then CastSpellByName("Flame Shock") end
/nb Flame Shock@target
/nb Lightning Bolt@target
```

Valid targets for your spells/abilities include:

* player(p), target(t), focus(f), pet(pet)
* group(g) and raid(r) - more on these later under Smart Targetting.

Here are some examples:

```/nb Mend Pet@pet``` and ```/nb Rejuvenation@player```.

### NB Checks - Adding some intelligence

So far so good, but Flame Shock is a DoT that lasts 12 seconds; it seems wasteful of mana to cast it every 6 seconds. We fix this by adding a ```debuff``` check to the NB that looks for the Flame Shock debuff on the target:

```
/run if nil then CastSpellByName("Flame Shock") end
/nb Flame Shock@target [debuff@target!Flame Shock]
/nb Lightning Bolt@target
```

*Note: the buff and debuff checks can be used interchangable, both check all buffs and debuffs, but you may want to specify ```debuff``` for debuffs and ```buff``` for buffs to improve clarity of your NBs*

The ```!``` in front of the Flame Shock inverts the check so that it only passes if Flame Shock is NOT on the target (you can use the `=` sign to check for the exitance of a buff/debuff). 

We now have a NB that will Cast ```Flame Shock``` whenever the target does not have the debuff, otherwise it will cast ```Lightning Bolt```.

### NB Shorthand !

Instead of having to type the full name of a spell/item/check/target you can abbreviate it as follows:
1. If the spell is a single word long, then just provide the first 4 letters.
2. If the spell is more than a single word, provide the first letter of each word.

*In addition the targets and checks can also be shortening. 
See the API in the next section that  details each and every check and its long and short forms.*

For example:
```
/run if nil then CastSpellByName("Thorns") end
/nb Thorns@player [buff@target!player]
/nb Mark Of The Wild@player [buff@player!Mark Of The Wild]
```
becomes:
```
/run if nil then CastSpellByName("Thorns") end
/nb thor@player [buff@player!thor]
/nb motw@player [buff@player!motw]
```
In addition the target and checks can also be shortened, making your NBs very compact and very unlikely to have issues with the 255 character limit for macros).
```
/run if nil then CastSpellByName("Thorns") end
/nb thor@p [b@p!thor]
/nb motw@p [b@p!motw]
```
See the cheatsheet at the end of this document for a full list of checks, targets and their shortened forms.

## Learn by Example

In this section we provide a bunch of examples to show the versitility of NB.

### What about killing those pesky Turtle WoW Paladins? :)

Turtle WoW has more than its fair share of Paladins, none of whome chose the class due to its PVP dominance. Here is a simple NB to aid the Shaman class purge those shields off of a Paladin and do some damage. 

```
/run if nil then CastSpellByName("Flame Shock") end
/nb Purge@target [buff@target=Divine Shield]
/nb Purge:target [buff@target=Blessing of Protection]
/nb Flame Shock@target [debuff@target!Flame Shock]
/nb Earth Shock@target
/nb Lightning Bolt@target
```

or in its shorthand form:

```
/run if nil then CastSpellByName("Flame Shock") end
/nb purg@t [b@t=ds]
/nb purg@t [b@t=bop]
/nb fs@t [d@r!fs]
/nb es@t
/nb lb@t
```

*Disclaimer: I'm very aware that Shamans can also be considered OP, just some humour, don't shoot me please.*

### Smart Decurse

And here is an example of  ```smart``` targeting cure conditions on party members if they are inflicted. There is no fixed target for this NB, the target is calculated at runtime by whomever passes the checks first. The first party member that matches the checks is Cured/Cleansed. Such NBs can be used to keep the raid relatively clean of debuffs or heal the raid member with the lowest health, there are lots of possibilities.

```
/run if nil then CastSpellByName("Cure Poison") end
/nb Cure Poison@group [condition@smart=poison]
/nb Remove Curse@group [condition@smart=curse]
```

This could be improved to use Abolish Poison that auto cleanses Poisons for 8 seconds. We just need to check for the Abolish Poison buff.

```
/run if nil then CastSpellByName("Abolish Poison") end
/nb Abolish Poison@group [condition@smart=poison,buff@smart!Abolish Poison]
/nb Remove Curse@group [condition@smart=curse]
```

or in its shorthand form:

```
/run if nil then CastSpellByName("Abolish Poison") end
/nb ap@group [con@s=p,b@s!ap]
/nb rc@group [con@s=p]
```

### Powershifting and Special Actions

In addiion to casting spells, and using abilities and items, NB supports a number of special actions, one of which is the ```powershift``` action. This action:
1. simplifies powershifting for druids, will always return you to whatever form you were previously in.
1. makes it easy to use a consumable mid-shift
1. Spam protection to stop you from leaving form again if you spam the button too many times.

You still however need to spam the button twice to complete a full powershift, there is no 1-button solution in Vanilla WoW.

```/nb powershift``` or ```/nb ps``` is the most basic form, but you can combine consumable usage as follows:

```
/run if nil then CastSpellByName("Travel Form") end
/nb powershift@Greater Healing Potion
```

or in shorthand:

```
/run if nil then CastSpellByName("Travel Form") end
/nb ps@ghp
```

### Cat druid prowl and tracking

Here is the NB I use to enter Prowl on my druid. It may seem a little complex...

```
/run if nil then CastSpellByName("Prowl") end
/nb Cat Form [form@player!Cat Form]
/nb Prowl [buff@player!Prowl]
/nb cancel@Prowl [cooldown@player>3Prowl]
/nb Track Humanoids@player [buff@player!Track Humanoids][form@player=Cat Form]
```

This is what it does:
1. Displays and updates the Prowl icon
1. Switches to Cat Form if the player is not in Cat Form
1. Uses Prowl if the player is not Prowling
1. Cancels Prowl if the player last used Prowl more than 3 seconds ago. This allows me to press the button again to exit Prowl if required, but provides spam protection by only allowing this if its over 3 second since I started prowling.
1. Starts tracking humanoids if I'm not already tracking them and I'm already in Cat Form.

Ultimately to enter cat form, start prowling, and begin tracking humanoids requires 3 button presses, but it can be spammed quickly and works well for me.

The shorthand version is:

```
/run if nil then CastSpellByName("Prowl") end
/nb cf [f@p!cf]
/nb prow [b@p!prow]
/nb can@prow [cd@p>3prow]
/nb th@p [b@p!th][f@p=cf]
```

### Once button druid self care

Here is a one button macro I use for my druid to simplify buffing and healing whilst levelling:

```
/run if nil then CastSpellByName("Rejuvenation") end
/nb ap@p [b@p!Abolish Poison,con@player=p]
/nb rc@p [con@p=c]
/nb ht@p [h@p<60%]
/nb Regr@p [b@p!Regrowth,h@p<80%]
/nb Reju@p [b@p!Rejuvenation]
/nb thor@p [b@p!Thorns]
/nb motw@p [b@p!mark]
```



### Summary

Hopefully by now you've seen some of the posibilities of NB and are considering how you can use it to improve your play, be it PVE or PVP. Writing this addon has taken me away from levelling my main for at least 8 hours, so please say thank you if you like the addon and see Tempeh my Tauren Druid in-game on the Turtle WoW PVP realm :)

The remainder of the documenation covers the syntax and available options in more detail. Use it as a reference manual when creating your NBs. Good luck!

# NerfedButtons Cheat Sheet

## NerfedButtons Syntax

NB consists of one or more lines of actions, one action per line. NB considers each line in turn, if the checks pass for an action, then the action is cast/used/done. Execution then moves onto the next line. WoW limits only one ability/spell/item per keypress, therefore the first action that passes its checks will get performed. 

```
/run if nil then CastSpellByName("ACTION") end
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>]
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>]
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>]
```

Everything after the action_name is optional.

If you have multiple checks for a single action, seperate them with a comma```,```:

```
/run if nil then CastSpellByName("ACTION_NAME") end
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>,<check_name>@<check_target><operator><check_value>]
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>]
/nb <action_name>@<action_target> [<check_name>@<check_target><operator><check_value>]
```


## Actions

### <Action_Name>

#### Spells, abilities and items

* ```<action_name>``` is the name of any spell, item, ability or special NB action. Note that spells have different names in differnt languages, therefore you'll need to modify any NBs you copy from the internet if they are not native to your WoW client language.

Actions are either spelled out in full or abbreviated:

* Mark of the Wild => motw
* Thorns => thor

1. If the spell is a single word long, then just provide the first 34 letters.
2. If the spell is more than a single word, provide the first letter of each word.

#### Special Actions

  There are also a number of ```special``` NB actions. These include (shorthand in brackets):

  * `cancel` (`c`) - cancels a buff on the player. ```/nb cancel@Enrage```
  * `target` (`t`) - targets a unit. ```/nb target@raid10```
  * `targetenemy` (`te`) - targets nearest enemy. ```/nb targetenemy```
  * `targetenemyplayer` (`tep`) - targets nearest enemy player. ```/nb targetenemyplayer```
  * `targetfriend` (`tf`) - targets nearest friendly. ```/nb targetfriend```
  * `targetlasttarget` (`tlt`) - targets your last target. ```/nb targetlasttarget```
  * `stop` (`s`) - stops attacking and casting. ```/nb stop```
  * `stopcast` (`sc`) - stops attacking and casting. ```/nb stopcast```    
  * `stopattack` (`sa`) - stops attacking and casting. ```/nb stopattack```
  * `powershift` (`ps`) - powershift and optionally use consumable. ```/nb powershift``` or ```/nb powershift@Healing Potion``` 

    Each of the special actions can be combined with checks. For example:

    ```
    /run if nil then CastSpellByName("Healing Touch") end
    /nb stop [health@player<20%]
    /nb Healing Touch@player
    ```

    Will cast Enrage and then cancel it so you get the initial benefit but remove it so as not to suffer the detrimental after effects.

### <Action_Target>

#### Simple action targets

* ```<action_target>``` is the target for the action. Basic values include:
  * `player` (`p`) - cast on yourself
  * `target` (`t`) - cast on your target
  * `focus`  (`f`) - cast on your focus target

  ```
  /nb [Rejuvenation:focus][health:focus:<90]
  /nb [Wrath:target]
  ```

#### Smart action targets

  In addition there are special ```smart``` targets that are calculated at runtime based on the conditions associated with a NB. These smart targets include:
  
  * `group` (`g`) - cast on the first member of your group that matches your checks
  * `raid` (`r`) - cast on the first member of your raid that matches your checks

  Note: group and raid will cause NB to scan all the members and perform checks again everyone with a single button press. It's a  bit like magic!

  always use the word smart (or 's') for the target of your checks when using smart targetting:

  ```
  /nb [Cure Poison:group][con:smart:poison]
  /nb [Remove Curse:group][con:smart:curse]
  ```

## Checks

NB comes with a variety of useful checks but more will be developed over time. Here is the current list:

### <Check_Type>

Note that many of the checks require a check_target, this can be same or different to the arction_target.

 * `buff` (`b`) - check for a buff or debuff on the check_target.
 * `debuff` (`d`) - same as buff, check for a buff or debuff on the check_target.
 * `class` (`cl`) - checks the class of the check_target.
 * `health`(`h`) - checks the health of the check_target. Append % to the value to check percentage of health.
 * `power`(`p`) - checks the power (mana/rage/energy) of the check_target. Append % to the value to check percentage of power.
 * `form`(`f`) - checks the form of the check_target (cat,bear,moonkin,travel,aquatic,none).
 * `combo`(`cp`) - checks the combo points of the check_target. Unlike Classic, in Vanilla you lose combo points on your target if you switch target, therefore the check_target should always be `target` for this check and nothing else makes sense.
 * `combat`(`com`) - checks whether the check_target is in combat.
 * `cooldown`(`cd`) - checks whether the spell was last cast more than X seconds ago. This is a fake cooldown check and has nothing to do with the actual spell cooldown. Useful to protect against spamming or to add a fake cooldown to spells so that you can cycle through them on one button.
 * `power`(`p`) - checks the power (mana/rage/energy) of the check_target.
 * `condition`(`con`) - checks if the check_target is suffering from any conditions (poison/curse/magic/disease).

### <Check_Target>

  * `player` (`p`) - you the player.
  * `target` (`t`) - your current target.
  * `smart` (`s`) - a smart target (used when the action target is set to group or raid).

### <Check_Value>

The value associated with the check to test against. This is check specific in most cases.


# History of NerfedButtons (War, RIFT, Age of Conan)

NerfedButtons (or NB for short) was originally written for Warhammer Online and had a love/hate relashionship with players and developers alike. Some claimed it dumbed down the game too much, whilst others loved the freedom it gave them to simplify overly complex keybindings so they could focus on gameplay. NB only did what was allowable by WAR API and as such was not against the TOS.

The original NB was text only, but  a couple of great developers joined the team who produced a user interface that greatly improved the accessability of NB to those who were scripting adverse.

Much later, versions were written for Rift and Age of Conan which offered similar functionality but only really implemented as a technical challenge. The implimentations however were clearly against the TOS and as such the addons were poorly documentated and maintained.

Warhammer Online: Return of Reckoning brought about a revival of WAR and the controversy of NB. Ultimately the WAR developers found a way to limit the API and make NB unuseable in its current form. The developer of NB decided to adhere to the decision and not work on any workarounds, a death knell for the addon.

### Vanilla WoW (e.g. Turle WoW)
Vanilla WoW provides a powerful API that can be called by macros and addons, much more complete that Classic or Retail. NB for Vanilla WoW makes a lot of sense as like the original WAR implimentation, only does what the API allows, and in fact there are already widely used other addons (e.g. Super Macros) that provide very similar capabilities to NB but require knowledge knowledge of LUA. NB will never be as powerful as writing your own LUA code, but does level the playing field somewhat for those who don't.

## Known Limitations

Unfortunately unlike Classic and Retail WoW, the icon associated with a button is fixed, therefore you need to prefix all your NB with the following:

```/run if nil then CastSpellByName("SPELL NAME") end```

You should consider which ability icon in your NB makes sense to you as it is this ability that will be shown on the button and will be updated to show out of range etc...

I haven't found a workaround this this limitation as yet, maybe there isn't one...


# Lots of Examples :)

## General

## Druid

## Mage

## Paladin

## Priest

## Rogue

## Shaman

## Warlock

## Warrior


