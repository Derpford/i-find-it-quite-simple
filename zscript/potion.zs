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
        }
        int cap = (flasklvl+1) * EssenceCap;
        int total = essence + amt;
        int actual = min(cap, essence + amt);
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
            // item.GoAwayAndDie();
            item.bPICKUPGOOD = true;
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

class Essence : VacuumChase {
    Color col;
    Property Color : col;
    default {
        Inventory.Amount 100;
        Inventory.MaxAmount 10000;
        Essence.Color "Blue";
    }

    override void AttachToOwner(Actor other) {
        return; // Never actually attaches to the player! Only works with techflask.
    }

    override void Tick() {
        super.Tick();
        FSpawnParticleParams p;
        double ang = frandom(0,360);
        vector2 xyvel = RotateVector((0,frandom(0.5,1.5)),ang);
        double zvel = 1.0;
        p.color1 = col;
        p.pos = pos;
        p.vel = (xyvel.x,xyvel.y,zvel);
        p.accel.xy = -(2.5 * xyvel * 1./35.);
        p.accel.z = 1./35.;
        p.style = STYLE_Normal;
        p.lifetime = 35;
        p.size = 24;
        p.sizestep = -0.5;
        p.startalpha = 1.0;
        p.fadestep = -1;
        p.flags = SPF_FULLBRIGHT | SPF_NOTIMEFREEZE;
        LevelLocals.SpawnParticle(p);
    }

    states {
        Spawn:
            TNT1 A -1;
            Stop;
    }
}

class HealthEssence : Essence replaces HealthBonus {
    default {
        Inventory.Amount 100;
        Inventory.PickupMessage "Health Essence";
        Essence.Color "Blue";
    }
}

class ArmorEssence : Essence replaces ArmorBonus {
    default {
        Inventory.Amount 150;
        Inventory.PickupMessage "Armor Essence";
        Essence.Color "Green";
    }

    override void AttachToOwner(Actor other) {
        return; // Never actually attaches to the player! Only works with techflask.
    }
}

class AmmoEssence : Essence {
    // Need to find sprites for this...
    default {
        Inventory.Amount 100;
        Inventory.PickupMessage "Ammo Essence";
        Essence.Color "Red";
    }
}