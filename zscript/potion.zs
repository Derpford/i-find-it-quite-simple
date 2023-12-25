class TechFlask : Inventory {
    // Holds health, armor, and ammo essence.

    int hpe, arme, clipe; // Health Essence, Armor Essence, Ammo Essence.
    int flasklvl; // maximums for each type of essence are this * 1000
    const EssenceCap = 10000;
    int flaskxp; // when this is > EssenceCap, increase flask level
    static const int AmmoVals[] = { // Ammo worth per unit.
        100, // Clip
        150, // Shell
        250, // Rocket
        250  // Cell
    };
    const HPVal = 100;
    const ArmVal = 100; // How much health and armor are worth per unit.

    int AddEssence(int essence, int amt) {
        let block = StatBlock(owner.FindInventory("StatBlock"));
        if (block) {
            double mult = block.StatMultiplier(block.end);
            amt = amt * mult;
            console.printf("Essence amount: %d",amt);
        }
        int cap = (flasklvl+1) * EssenceCap;
        int total = essence + amt;
        int actual = min(cap, essence + amt);
        console.printf("Total: %d + %d = %d",essence,amt,actual);
        int xpgain = max(0,total - actual);
        flaskxp += xpgain;
        return actual;
    }

    override bool HandlePickup(Inventory item) {
        bool handled = false;
        if (item is "HealthEssence") {
            hpe = AddEssence(hpe,item.amount);
            handled = true;
        }
        if (item is "ArmorEssence") {
            arme = AddEssence(arme,item.amount);
            handled = true;
        }
        if (item is "AmmoEssence") {
            clipe = AddEssence(clipe,item.amount);
            handled = true;
        }

        if (handled) {
            item.GoAwayAndDie();
            return true;
        } else {
            return false;
        }
    }

    override void DoEffect() {
        if (GetAge() % 5 == 0) {
            // Every 5 tics, apply 1 point of health and armor.
            if (owner.health < owner.GetMaxHealth(true) && hpe >= HPVal) {
                owner.GiveBody(1);
                hpe -= HPVal;
            }

            if (owner.CountInv("ArmorPoints") < 200 && arme >= ArmVal) {
                owner.GiveInventory("ArmorPoints",1);
                arme -= ArmVal;
            }
            // TODO: Armor calculations.
        }
    }
}

class HealthEssence : Inventory replaces HealthBonus {
    default {
        Inventory.Amount 100;
        Inventory.MaxAmount 10000;
        Inventory.PickupMessage "Health Essence";
    }

    states {
        Spawn:
            BON1 ABCDCB 3 Bright;
            Loop;
    }
}

class ArmorEssence : Inventory replaces ArmorBonus {
    default {
        Inventory.Amount 150;
        Inventory.MaxAmount 10000;
        Inventory.PickupMessage "Armor Essence";
    }

    states {
        Spawn:
            BON2 ABCDCB 3 Bright;
            Loop;
    }
}

class AmmoEssence : Inventory {
    // Need to find sprites for this...
    default {
        Inventory.Amount 100;
        Inventory.MaxAmount 10000;
        Inventory.PickupMessage "Ammo Essence";
    }
}