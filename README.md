# NerfedButtons - Vanilla WoW 1.12 addOn 

NerfedButtons (NB) lets you define prioritised and conditional ability/item/macro lists for your actionbar buttons. NerfedButtons will automatically ensure that the highest priority ability/item/macro that passes its conditions is bound to the actionbar button slot at any time.

* Too many hotbuttons aggravating your RSI?
* Want to stimulate your brain as well as your reflexes?
* Are you a casual player who wants a chance against those 12 fingered mutants who fluidly play whack-a-mole with 48 buttons 24 hours a day?

if any of the above apply, NerfedButtons may be what you are looking for!

Disclaimer: Understanding NerfedButtons requires a modicum of effort and the exercise of a few brain cells, you have been warned...


### History (War, RIFT, Age of Conan)

NerfedButtons (or NB for short) was originally written for Warhammer Online and had a love/hate relashionship with players and developers alike. Some claimed it dumbed down the game too much, whilst others loved the freedom it gave them to simplify overly complex keybindings so they could focus on gameplay. NB only did what was allowable by WAR API and as such was not against the TOS.

The original NB was text only, but  a couple of great developers joined the team who produced a user interface that greatly improved the accessability of NB to those who were scripting adverse.

Much later, versions were written for Rift and Age of Conan which offered similar functionality but only really implemented as a technical challenge. The implimentations however were clearly against the TOS and as such the addons were poorly documentated and maintained.

Warhammer Online: Return of Reckoning brought about a revival of WAR and the controversy of NB. Ultimately the WAR developers found a way to limit the API and make NB unuseable in its current form. The developer of NB decided to adhere to the decision and not work on any workarounds, a death knell for the addon.

### Vanilla WoW (e.g. Turle WoW)

Vanilla WoW provides a powerful API that can be called by macros and addons, much more complete that Classic or Retail. NB for Vanilla WoW makes a lot of sense as like the original WAR implimentation, only does what the API allows, and in fact there are already widely used other addons (Super Macro, Roids Macros) that do something similar, NB levels the playing field for those who are less computer savvy.

## Your first NerfedButton

First off let's have a quick look at the basic syntax of NB. NBs are written as macros, you can use the basic macro window, or the Super Macro window to do this.

All NBs begin with ```/nb start``` on the first line. 
Following this you'll have one or more lines of actions. NB considers each line in turn, if the checks pass for an action, then the action is cast/used/done, if not then the next line is attempted, until the end of the NB is reached (denoted with ```/nb end```).

Here is a simple two-liner casts Purge on the target if they are buffed with Divine Shield, Frost Barrier, or Blessing of Protection; otherwise casts Lightning Bolt on the current target:

```
/nb start
/nb [Purge,target]:[buff,target,Divine Shield|Frost Barrier|Blessing of Protection]
/nb [Lightening Bolt,target]
/nb end
```

And here are examples that use smart ```raid``` targeting to cure conditions on raid members if they are inflicted. The first raid member that matches the checks is Cured/Cleansed. These NBs could be spammed to keep a party/raid clear of conditions:

```
/nb start
/nb [Cure Poison,raid]:[con,party,poison]
/nb [Remove Curse,raid]:[con,party,curse]
/nb end
```
```
/nb start
/nb [Cleanse,raid]:[con,raid,poison]
/nb [Cleanse,raid]:[con,raid,curse]
/nb [Cleanse,raid]:[con,raid,disease]
/nb [Success,raid]:You have been cured by
/nb [Fail,raid]:You have been cured by
/nb end
```

## Basic Syntax
```
/nb start
/nb [<action>,<action_target>]:[<check_type>,<check_target>,<checks_spell>][<check_type>,<check_target>,<checks_spell>]
/nb [<action>,<action_target>]:[<check_type>,<check_target>,<checks_spell>]
/nb [<action>,<action_target>]
/nb end
```

* ```<action>``` is the name or ID of any spell, item, ability or special NB action. Note that spells have different names in differnt languages, therefore you'll need to modify any NBs you copy from the internet if they are not native to your WoW client language.

* ```<action_target>``` is the target for the action. Basic values include:
  * player
  * target
  * focus  

  In addition there are special targets that are calculated at runtime based on a condition
  * party (only targets the 5 party members even in a raid)
  * raid (will target any raid member or party member if not in a raid)
  * tanks
  * dps
  * healers

* ```<checktype>``` is the type of check you want to perform. Valid values include:
  * buff / nobuff (these also check for debuffs)
  * health
  * con (short for condition, can be curse,poison,magic,disease)
  * equip
  * ready (is the spell ready to be used)
  * 





where each spell/ability/item/action you want to use has an associated number of checks that must pass if it can be used, if not then the next spell/ability/item/action is considered until one that passes all it's checks is found, this ability is then used.

# Here a some examples:

Target a group member that is not buffed with Mark of the Wild and cast it upon them. This NB uses the special ongroupmember target that searches for the first group member that matches the check.

```

-- Cast Purge on the target if they are buffed with Divine Shield, Frost Barrier, or Blessing of Protection.
/nb [Purge,target]:[buff,target,Divine Shield|Frost Barrier|Blessing of Protection]

-- Cast Mark of the Wild on the first group member that is not buffed with it.
/nb [Mark of the Wild,group]:[nobuff,group,Mark of the Wild]

-- Cast Healing Touch(Rank 3) on the group member with the lowest health.
/nb [Healing Touch(Rank 3),group]:[health,group,lowest]

-- Cast Rejuvenation on the first group member that is not buffed with it and has health below 90%.
/nb [Rejuvenation,group]:[nobuff,group,Rejuvenation][health,group,<90]

-- Create a custom list and use that in a condition
/nb list add MyArenaPurges Divine Shield|Frost Barrier|Blessing of Protection
/nb [Purge,target]:[buff,target,$MyArenaPurges]
    -- in future you can now edit the list without editing the NB.





```

## Limitations

Unfortunately unlike Classic and Retail WoW, the icon associated with a button is fixed, therefore you should consider which ability icon in your sequence makes sense.





