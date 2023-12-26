class ArmorMod : Inventory {
    // Comes with a bunch of ArmorPoints, and affects the behavior of your armor.
    // Consumes ArmorPoints to function.

    double save; // 0.0 to 1.0 normally; how much of incoming damage the armor absorbs.
    Property Save: save;
    int spawnAP; // How much AP to give the player on pickup.
    Property AP: spawnAP;

    Color col; // What color should the armor text be?
    Property Color : col;

    int tier; // Like with weapons, tier affects which armor spawn spots get this armor.
    int rarity; // Higher rarity means more valuable.
    Property Tier: tier, rarity;

    bool skipcheck; // Should this item be ignored when checking for whether the player has an ArmorMod?
    Property Wimpy : skipcheck;

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        ArmorMod.Save 0.5;
        ArmorMod.AP 0;
        ArmorMod.Tier 1, 0;
        ArmorMod.Color Font.CR_GREEN;
        ArmorMod.Wimpy true;
        RenderStyle "Translucent";
    }

    override bool CanPickup(Actor other) {
        let amod = ArmorMod(other.FindInventory("ArmorMod",true));
        let plr = SimplePlayer(other);
        bool succ = true;
        if (amod && plr) {
            if (amod.skipcheck) {
                succ = true;
            } else {
                let btns = plr.GetPlayerInput(INPUT_BUTTONS);
                if (btns & BT_USE  && droptime <= 0) {
                    succ = true;
                } else {
                    succ = false;
                }
            }
        }

        if (succ) {
            if (amod) {
                other.A_DropInventory(amod.GetClassName());
            }
            other.GiveInventory("ArmorPoints",spawnAP);
            spawnAP = 0; // Only gives AP once.
            alpha = 0.6; // Turns slightly transparent when it's already used.
            return true;
        } else {
            return false;
        }
    }

    int UseAP(int dmg, double save, double multi = 1.0) {
        int effectivedmg = ceil(dmg * multi); // Under certain conditions, armor might absorb more or less of the effective damage.
        int absorbed = min(owner.CountInv("ArmorPoints"),ceil(effectivedmg * save)); // Cannot save more than armorpoints dmg.
        owner.TakeInventory("ArmorPoints",absorbed);
        return max(0,dmg - absorbed);
    }

    override void AbsorbDamage(int dmg, Name mod, out int new, Actor inf, Actor src, int flags) {
        new = UseAP(dmg,save); // Ordinary behavior.
    }
}

class ArmorPoints : Inventory {
    int timer;
    const decaytime = 70;

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 200;
    }

    override bool HandlePickup(Inventory item) {
        if (item is "ArmorPoints") {
            amount += item.amount;
            item.bPICKUPGOOD = true; // Always pick up armor points.
            return true;
        }
        return false;
    }

    override void DoEffect() {
        if (amount > maxamount) {
            timer += 1 + max(0,(amount - 200) / 25); // Every 25 points of overarmor speeds up the rate of decay
            int decay = floor(timer / decaytime);
            if (decay > 0) {
                timer -= decay * decaytime;
                amount -= decay;
            }
        } else {
            timer = 0;
        }
    }
}

// And now, armor types.

class SecurityArmor : ArmorMod {
    default {
        ArmorMod.Save 0.5;
        ArmorMod.AP 75;
        Inventory.PickupMessage "Security Armor! (-5 incoming damage)";
        ArmorMod.Tier 1,0;
        ArmorMod.Wimpy false;
    }

    override void AbsorbDamage(int dmg, Name mod, out int new, Actor inf, Actor src, int flags) {
        super.AbsorbDamage(dmg - 5,mod,new,inf,src,flags);
    }

    states {
        Spawn:
            ARM1 AB 5 Bright;
            Loop;
    }
}

class ReactiveArmor : ArmorMod {
    default {
        ArmorMod.Save 0.9;
        ArmorMod.AP 200;
        Inventory.PickupMessage "Reactive Armor! (high save percent)";
        ArmorMod.Tier 2,1;
        ArmorMod.Color Font.CR_BLUE;
        ArmorMod.Wimpy false;
    }

    states {
        Spawn:
            ARM2 AB 5 Bright;
            Loop;
    }
}