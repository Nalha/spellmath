# SpellMath

**SpellMath** is a World of Warcraft: Classic addon that provides deterministic spell math and makes it easy to inspect how a spell’s average damage, DPS, damage per mana (DPM) and other metrics are calculated. It does this by packaging comprehensive spell data for Mages along with a small engine that applies base damage, coefficients, talents and player statistics. The addon augments tooltips and can optionally display a scrollable spellbook interface with sortable columns.

## Features

- **Deterministic averages** – no simulations, just formulas. SpellMath computes weighted average hits, critical hits, DPS, cast times and total damage using classic era coefficients and game APIs.  
- **Multi-component support** – spells that have direct, damage-over-time, channeled or absorb components (e.g. Flamestrike, Blizzard, Ice Barrier) are handled by separate sub-tables so their contribution can be reported individually.  
- **Talent integration** – passive talents that always modify spell damage, mana cost, cast time or hit chance are folded into the calculation. Many non-deterministic talents are stubbed out so they don’t affect the results.  
- **Extended spellbook UI** – the optional `ui_spellbook.lua` module registers a movable window with sortable columns (Name, Rank, Avg, Total, DPS, DPM, Crit %, Time and Cost). You can open it with `/spellmath ui` and sort by clicking column headers.  
- **Debug slash command** – run `/spellmath <spellID>` to print out the computed averages for a specific spell rank. Without arguments, `/spellmath` defaults to Frostbolt rank 1; `/spellmath ui` toggles the extended spellbook.

## Installation

1. Download this repository and drop the `SpellMath` folder into your `World of Warcraft/_classic_/Interface/AddOns` directory.  
2. Make sure the folder contains `SpellMath.toc`, `bootstrap.lua`, the `core` folder, the `ui_spellbook.lua` file and the `data` directory with spell and talent data files.  
3. Launch WoW Classic and enable **SpellMath** from the addons menu.

## Usage

- Hover over a spell in your spellbook or action bar to see deterministic averages appended to the tooltip.  
- Use `/spellmath` to inspect a specific spell by ID or toggle the extended UI with `/spellmath ui`.  
- The extended UI lists all known spells for which there is data and allows sorting by any column. Spells unknown to your character are filtered out.

## Development

Spell data and passive talents live in the `data/` directory. Each class and school has its own file. Data tables follow simple conventions:

- **Legacy single-component spells**: specify `type`, `baseMin`, `baseMax`, `baseCast`, `mana` and `coeff` fields. The core treats the spell as direct, dot, channeled or absorb based on the `type` field.  
- **Bundled multi-component spells**: define `direct`, `dot`, `channeled` or `absorb` subtables containing their own `baseMin`/`baseMax`/`coeff` values. The engine iterates over these components and computes each one separately.

Talents are defined as a list of tables with a `name`, a `when` predicate and an `apply` function. Only deterministic talents should modify the context; everything else should remain a no-op. See `data/mage_talents_frost.lua` for examples.

If you add new data files, be sure to list them in `SpellMath.toc` so WoW loads them in the correct order. The `bootstrap.lua` script populates the global `SpellMath` table and builds a reverse lookup of spell names and ranks.

## Contributing

SpellMath is a work in progress. Feel free to submit pull requests for additional spells, talent corrections or bug fixes. For issues related to the deterministic math engine, please include the affected spell ID, rank and a description of the problem.
