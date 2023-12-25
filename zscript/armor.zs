class ArmorMod : Inventory {
    // Comes with a bunch of ArmorPoints, and affects the behavior of your armor.
    // Consumes ArmorPoints to function.

    double save; // 0.0 to 1.0 normally; how much of incoming damage the armor absorbs.
    Property Save: save;
    int spawnAP; // How much AP to give the player on pickup.
    Property AP: spawnAP;

    int tier; // Like with weapons, tier affects which armor spawn spots get this armor.
    Property Tier: tier;

    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        ArmorMod.Save 0.5;
        ArmorMod.AP 0;
        ArmorMod.Tier 1;
    }

    override void AttachToOwner(Actor other) {
        super.AttachToOwner(other);
        other.GiveInventory("ArmorPoints",spawnAP);
        spawnAP = 0; // Only gives AP once.
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

    states {
        Spawn:
            ARM1 AB 5;
            Loop;
    }
}

class ArmorPoints : Inventory {
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
        if (GetAge() % 35 == 0 && amount > maxamount) {
            // Tick down over-armor.
            amount--;
        }
    }
}

// And now, armor types.

class SecurityArmor : ArmorMod {
    default {
        ArmorMod.Save 0.5;
        ArmorMod.AP 75;
        Inventory.PickupMessage "Security Armor! (-5 incoming damage)";
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
    }

    states {
        Spawn:
            ARM2 AB 5 Bright;
            Loop;
    }
}