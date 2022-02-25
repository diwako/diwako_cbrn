# diwako_cbrn

Mission script to add an arcadey CBRN mechanic into an Arma mission. This script is not meant to be realistic, as breathing in 2 seconds of some bad smell air causing death is not fun on a gameplay level. However, you can tune down the max CBRN damage to get this effect if you really wish!\
CBRN threats are abstracted into 4 threat levels which are color coded by green, yellow, orange and red.

Threat level diagram, all threats level requirements stack:

1. Green: No CBRN gear need
2. Yellow: Gas mask needed
3. Orange: Supply of fresh air needed
4. Red: Full CBRN suit needed

This script comes with a custom gasmask overlay, breathing sounds and custom low oxygen warning sounds.

## Custom CBRN damage

This script features custom CBRN damage values, it is just a flat number and when you go over this number, you die. As CBRN damage takes quite some time to decrease hence why it is not simulated and CBRN damage stays until respawn.\
If a unit reaches 50% of the maximum CBRN damage it will be informed that from now on the CBRN damage will go up passively even if full CBRN protection is present. The unit needs to decontaminate at a small decon shower. Walk up to the shower, activate it via ACE interactions and stand in it until you receive a new message!\
Warning: Water is finite, make sure to turn off the shower again!

## Set up and configuration

1. Copy the scripts folder into your mission
2. Adapt your description.ext
   - if you do not have a description.ext, create it next to the mission.sqm in the base folder of your mission
   - Adapt classes CfgFunctions, CfgSounds, and RscTitle like the example description.ext
3. Edit `config.sqf` in `scripts\cbrn`

## Functions for mission makers

There is only one function that is public to use for mission makers. It is the function to create zones, recommended to do so via `initServer.sqf`.

```sqf
/*
 * Arguments:
 * 0: Center of zone, position array
 * 1: Threatlevel between 0 and 4.9, float
 * 2: Radius of full effect, float
 * 3: Radius of partial effect, float
 *
 * Returns trigger/zone object
 */
[getMarkerPos "marker_0", 1.5, 25, 25] call cbrn_fnc_createZone;
```

The returned object is a trigger. With it you can either just leave it as is, attach it to some object, or toggle the zone on or off (it is on by default).

To turn the zone off set the variable `cbrn_active` to false, as such:

```sqf
_trg setVariable ["cbrn_active", false, true];
```

**WARNING**: Deleting the trigger object is not supported. First disable the zone, wait a few seconds for the value to sync in mp and then delete the trigger if you really must!

## Requirements

CBA_A3 and ACE3

## Variables

There are several variables preset for Vanilla and ACE3 gear, those can be overwritten either directly in the files or in your own `postinit` function or `init.sqf` file

### cbrn_maxDamage

Integer how much damage can be absorbed before death.\
If 50% of damage is reached passive contamination starts that needs to be stopped via decontamination showers!\
default: 100

### cbrn_masks

Array of strings, warning: CaSeSeNsItiVe!\
Array of facewear/goggles which are to be considered gasmasks.\
Default: Array of all vanilla Gasmasks and some select mod ones

### cbrn_backpacks

Array of strings, warning: CaSeSeNsItiVe!\
Array of backpacks which are to be considered oxygen tanks.\
Default: Array containing self-contained oxygen tank and combination respirator unit
\[note: combination unit added by this fork]

### cbrn_suits

Array of strings, warning: CaSeSeNsItiVe!\
Array of uniforms which are to be considered cbrn suits.\
Default: Array of all Vanilla CBRN suits

### cbrn_threatMeterItem

String of item name that should be considered as threat meter item.\
Default: "ACE_microDAGR"

### cbrn_maxOxygenTime

Float, value in seconds of how long one oxygen container should last.\
Default: 30 Minutes

### cbrn_allowPassiveDamage

Boolean value if the passive contamination should occur after the 50% damage threshold

### cbrn_deconWaterTime

Float, value in seconds. Maximum total runtime

### cbrn_healingRate

Float, rate how much of the exposure damage is healed each second. **Healing is stopped if value is 0 or below, or player is experiencing passive contamination!**

### cbrn_vehicles

List of vehicle and proofing value pairs. First entry of a pair is the vehicle class or 3den object name as string, second entry is the proofing values, same measurements as threatlevel.

# Changelog over default

This fork contains a few changes over the base version.
All of these can be toggled off and much of it is customizable in the `config.sqf`.

Quick overview of the additions:
1. Mask fogging  \
1.2 Air conditioning & fatigue
2. Geiger counters


## Mask fogging

The first and biggest change is the ability for masks to fog up. While wearing a mask, the framework tracks the time a player has worn a gas mask for.
After five minutes, the mask will start visibly fogging up until the uptime reaches ten minutes, at which the overlay will have reached full opacity.

![Demonstration of the fogging overlay at full opacity.](https://media.discordapp.net/attachments/945121539676856420/945773090296700968/unknown.png?width=1280&height=720)

Taking the gas mask off causes the fog to fade over time. By default the mask airs out five times as quickly as it fogs up.

The values for this are fully configurable in `config.sqf`. See the section below for a quick rundown of what they do!

Related to this there are two other features, air conditioning and fatigue-related modifying of fogging speed.

### Air conditioning & fatigue

You can now define items as air conditioners - these items, when worn, can modify the accumulation of the fogging. By default, wearing such an item *halves* the accumulation of fog. By default the combination respirator is considered an air conditioner, in addition to it being considered a source of oxygen.

If enabled, short term fatigue loss will cause masks to fog up far quicker. Depending on your settings, either the short term stamina of `ACE Advanced Fatigue` or the default ArmA 3 stamina bar will be used.
The rate fatigue increases this accumulation is also customizable; by default fatigue can add up to a whole second per tick. This value however is also affected by the AC effect.

## Geiger counters

Also added was the ability to designate items as geiger counters. By default this behavior is added to the Micro DAGR, which now acts as a combination threatmeter and geiger counter, but as with the default framework, this is customizable by the user.

Unlike the vanilla chemical detector, these play their sounds in 3D space and, of course, produce clicks instead of beeping.

## New variables

### template
Datatype and what it does\
short descriptor\
default: true

### cbrn_conditioning
Array of strings, warning: CaSeSeNsItiVe!\
Array of backpacks which are to be considered air conditioning units.\
default: Combination Respirator Unit

### cbrn_threatGeiger
String of item name that should be considered as a geiger counter.\
Default: "ACE_microDAGR"

### cbrn_foggingEnabled
Boolean, whether fogging should be enabled or not.\
Disabling this disabled the whole fogging routine.\
default: true

### cbrn_fogStartTime
Float, value after which the mask overlay starts being shown.\
Once the mask uptime of a unit reaches this value, the fogging overlay will be created and slowly increase in opacity until the uptime reaches `cbrn_fogMaxTime`.\
default: 5 minutes

### cbrn_fogMaxTime
Float, value after which the mask overlay is fully opaque.\
Once the mask uptime of a unit reaches this value, the fogging overlay is shown in full opacity. The mask overlay has transparent areas and is **not** meant to completely block vision.\
default: 5 minutes

### cbrn_fogAccumulationCoef
Float, value that modifies the fog accumulation when the unit is wearing a backpack considered to be an air conditioner.\
Lower is better, values over 1 impact performance negatively and cause faster fog build up.\
default: 0.5

### cbrn_fogFadeCoef
Float, value that modifies the fog fading when the unit has previously worn, but is no longer, wearing a gas mask.
Higher is better.\
default: 5

### cbrn_fogFatigueEnabled
Boolean, whether fatigue should contribute to fogging or not. Checks either against the ACE advanced fatigue system (if enabled) or the vanilla stamina system.\
default: true

### cbrn_fogFatigueCoef
Float, value that modifies how much fatigue will cause the mask to fog up more.\
Fatigue is returned in the range of 0 - 1; therefore a fatigue value of 1 and coefficient of 1 can add up to another second of uptime per second.\
Higher makes fatigue build up far more fog, lower makes fatigue matter less in terms of fogging.\
default: 1
