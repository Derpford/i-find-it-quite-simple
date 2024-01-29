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

    int hptimer; // Increases every tick. When it's above player's health, subtract player's current health and apply healing.

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
        // Apply health at a rate based on current health.
        hptimer += 40;
        while (hptimer > owner.health) {
            hptimer -= owner.health;
            if (owner.health < owner.GetMaxHealth(true) && hpe >= HPVal) {
                owner.GiveBody(1);
                hpe -= HPVal;
            }
        }

        if (GetAge() % 5 == 0) {
            if (owner.CountInv("ArmorPoints") < 200 && arme >= ArmVal) {
                owner.GiveInventory("ArmorPoints",1);
                arme -= ArmVal;
            }
        }

        if (flaskxp > EssenceCap) {
            flaskxp -= EssenceCap;
            flasklvl += 1;
        }
    }
}

class Essence : VacuumChase {
    Mixin WaggleBob;
    Color col;
    Property Color : col;
    bool waggle;
    Property Waggle: waggle;
    default {
        Inventory.Amount 100;
        Inventory.MaxAmount 10000;
        Essence.Color "Blue";
        Essence.Waggle true;
    }

    override void AttachToOwner(Actor other) {
        return; // Never actually attaches to the player! Only works with techflask.
    }

    override void Tick() {
        super.Tick();
        if (waggle) { WaggleTick(); }
        FSpawnParticleParams p;
        double ang = frandom(0,360);
        vector2 xyvel = RotateVector((0,frandom(0.5,1.5)),ang);
        double zvel = 1.0;
        p.color1 = col;
        if (frandom(0,1) > 0.5) {
            p.Texture = TexMan.CheckForTexture("BAL2A0");
        } else {
            p.Texture = TexMan.CheckForTexture("BAL2B0");
        }
        p.pos = pos;
        p.pos.z += 4;
        p.vel = (xyvel.x,xyvel.y,zvel) * scale.x;
        p.accel.xy = -(2.5 * xyvel * 1./35.) * scale.x;
        p.accel.z = 1./35.;
        p.style = STYLE_Add;
        p.lifetime = 35;
        p.size = 24 * scale.x;
        p.sizestep = -0.5;
        p.startalpha = 1.0;
        p.fadestep = -1;
        p.startroll = frandom(0,90);
        p.rollvel = frandom(-1,1);
        p.rollacc = frandom(-2,2);
        p.flags = SPF_FULLBRIGHT | SPF_NOTIMEFREEZE | SPF_ROLL | SPF_NO_XY_BILLBOARD;
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
        Essence.Color "22 33 FF";
    }
}

class SmallKit : HealthEssence replaces Stimpack {
    default {
        Inventory.Amount 1000;
        Inventory.PickupMessage "Health Kit (Small)";
        Essence.Waggle false;
    }

    states {
        Spawn:
            STIM A -1;
            Stop;
    }
}

class MediumKit : HealthEssence replaces Medikit {
    default {
        Inventory.Amount 2000;
        Inventory.PickupMessage "Health Kit (Medium)";
        Essence.Waggle false;
    }

    states {
        Spawn:
            MEDI A -1;
            Stop;
    }
}

class ArmorEssence : Essence replaces ArmorBonus {
    default {
        Inventory.Amount 150;
        Inventory.PickupMessage "Armor Essence";
        Essence.Color "22 AA 11";
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