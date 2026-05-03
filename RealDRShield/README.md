# Real DR Shield

World of Warcraft addon that displays:

- Physical damage reduction from armor, versatility, and recognized defensive buffs.
- Magic damage reduction from versatility and recognized magic/global defensive buffs.
- AoE damage reduction from Avoidance, versatility, and recognized defensive buffs.
- Global damage reduction from versatility and recognized global defensive buffs.
- Current total absorb shields from `UnitGetTotalAbsorbs("player")`.
- Estimated physical, magic, and generic shield buckets when a recognized shield aura exposes its current amount.
- Optional heal absorb amount from `UnitGetTotalHealAbsorbs("player")`.

## Install

Copy the `RealDRShield` folder into:

```text
World of Warcraft/_retail_/Interface/AddOns/
```

Restart the game or run `/reload`, then enable **Real DR Shield** in the addon list.

## Commands

```text
/rds unlock      unlock and drag the frame
/rds lock        lock the frame
/rds reset       reset saved position
/rds hide        hide the frame
/rds show        show the frame
/rds healabsorb  toggle heal absorb display
/rds scan        print active player aura spell IDs
```

Chinese slash alias:

```text
/减伤
```

## Notes

WoW does not expose one universal "all incoming damage reduction right now" API. This addon therefore combines direct character stats with a maintained whitelist of recognized defensive buffs.

Shield splitting has an API limitation: `UnitGetTotalAbsorbs("player")` returns the accurate total absorb amount, but Blizzard does not provide a reliable direct physical/magic split for every shield. The addon only splits shields when a recognized aura exposes its current amount; the rest is shown as unclassified.

To add or tune defensive buffs and shields, edit the `auraRules` table in `Core.lua` with a spell ID and a decimal damage reduction value, for example `0.20` for 20%.
