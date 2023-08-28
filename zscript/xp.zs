class StatBlock : Inventory {
    // This mysterious block of green crystal shows you how powerful you are!

    const statbase = 1000.0; // Reaching this number in a stat doubles your effectiveness.

    double atk;
    double aim;
    double def;
    double startingstats, statgrow; // How much you start with, and how much it grows by.
    int statminbonus, statmaxbonus; // The minimum/maximum number of stat boosts a character can get per level. 
    Property Stats: startingstats, statgrow;
    Property StatBonus: statminbonus,statmaxbonus;
    int targetlvl, lvl; // targetlvl is where we want to level up to; lvl is how many levels we've applied
    int skillpoints;
    int xp; // You gain +1 level per every 100 XP, and 1 XP per point of health that a thing had when it died. Yes, this means that you level up REALLY FUCKING FAST.
    double aniatk, aniaim, anidef; // For the HUD to animate these three flashing.
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1; // You shouldn't have more than one statblock.
        StatBlock.Stats 0, 1;
        StatBlock.StatBonus 1, 2;
    }

    override void PostBeginPlay() {
        atk = startingstats;
        aim = startingstats;
        def = startingstats;
        super.PostBeginPlay();
    }

    double AnimateStat(double anistat) {
        double decay = max(2./35.,anistat / 3.);
        return max(0,anistat - decay);
    }

    override void DoEffect() {
        // Tick animations.
        aniatk = AnimateStat(aniatk);
        aniaim = AnimateStat(aniaim);
        anidef = AnimateStat(anidef);

        // Check if it's time to level up.
        if (xp >= 100) {
            int levels = floor(xp / 100);
            targetlvl += levels;
            xp -= levels * 100;
        }

        // Actually handle stat increases!
        while (targetlvl > lvl) {
            skillpoints += random(statminbonus,statmaxbonus);
            lvl++;
        }

        if (skillpoints > 0) {
            // Do these one tick at a time to avoid having to do a billion random calls in one tick.
            double kick = 2;
            switch(random(0,2)) {
                case 0:
                    atk += statgrow;
                    aniatk+=kick;
                    break;
                case 1:
                    aim += statgrow;
                    aniaim+=kick;
                    break;
                case 2:
                    def += statgrow;
                    anidef+=kick;
                    break;
            }
            skillpoints--;
        }
    }

    override bool HandlePickup(Inventory item) {
        if (item is "XPOrb") {
            // XP orbs do not get picked up the normal way.
            xp += item.amount;
            item.GoAwayAndDie();
            return true;
        } else {
            return super.HandlePickup(item);
        }
    }

    override void ModifyDamage(int dmg, name type, out int new, bool passive, Actor inf, Actor src, int flags) {
        double ddmg = dmg;
        if (passive) {
            // Modify incoming damage based on defense. At 100 def, damage taken is normal.
            double mult = statbase / (statbase + def);
            new = floor(ddmg * mult);

        } else {
            // Outgoing damage is increased based on both ATK and AIM. 
            // ATK is a straight multiplier. AIM adds a randomized exponent(!).
            double expo = max(1,(frandom(statbase,statbase+aim) / statbase));
            double dmult = max(1,(statbase+atk) / statbase);
            new = floor((ddmg * dmult) ** expo);
        }
    }
}

class XPOrb : VacuumChase {
    // Picking these up is handled by the StatBlock.
    mixin WaggleBob;
    default {
        +BRIGHT;
        +ROLLSPRITE;
        +Inventory.ALWAYSPICKUP;
        Inventory.Amount 1; 
        Inventory.MaxAmount 999999; // Just in case.
    }

    override string PickupMessage() {
        return String.Format("XP +%d",amount);
    }
    
    states {
        Spawn:
            XGEM AB 5;
            Loop;
    }
}

class XPDropHandler : EventHandler {
    override void WorldThingDied(WorldEvent e) {
        // When a thing dies, if it's a monster, spawn an appropriate amount of XP Orbs.
        int val = e.Thing.SpawnHealth();
        int orbspawns = val % 4;
        if (orbspawns == 0) { orbspawns = 4; }
        int valperorb = val / orbspawns;

        for (int i = 0; i < orbspawns; i++) {
            let orb = Inventory(e.Thing.Spawn("XPOrb",e.Thing.pos));
            orb.amount = valperorb;
            orb.Vel3DFromAngle(frandom(4,12),frandom(0,360),frandom(-20,-60));
        }
        // Do it again, but for cash, this time selecting a random coin each time.
        for (int i = 0; i < orbspawns; i++) {
            Name ctype = "CopperCoin";
            Name stype = "SilverCoin";
            Name gtype = "GoldCoin";
            switch(random(0,2)) {
                default:
                case 0:
                    ctype = "CopperCoin";
                    break;
                case 1:
                    ctype = "SilverCoin";
                    break;
                case 2:
                    ctype = "GoldCoin";
                    break;
            }

            let orb = Inventory(e.Thing.Spawn(ctype,e.Thing.pos));
            orb.amount = valperorb;
            orb.Vel3DFromAngle(frandom(4,12),frandom(0,360),frandom(-20,-60));
        }
    }
}

class VacuumChase : Inventory {
    // For items that are supposed to vacuum to the player.
    vector3 MixVec(vector3 a, double arate, vector3 b, double brate, double len) {
        vector3 mix = (a.unit() * arate) + (b.unit() * brate);
        return mix * len;
    }

    override void Tick() {
        // If this thing has a target, that's the player who's picking this item up.
        super.Tick();
        if (target) {
            VelIntercept(target,min(vel.length()+1,70));
            vector3 center = Vec3To(target) + (0,0,target.height/2);
            vel = MixVec(vel, 0.25, center, 0.75, vel.length());
        }
    }

}

mixin class WaggleBob {
    // Wigl wigl.
    double rollrate;

    clearscope double SmoothCap(double base, double cap) {
        // Diminishing returns on base, such that base never reaches cap.
        // In other words, as base approaches infinity,
        // the return value approaches cap.
        return (atan(base / cap) / 180.) * 2 * cap;
    }

    override void Tick() {
        Super.Tick();
        if (rollrate == 0) { rollrate = frandom(18,24); }
        roll = sin(GetAge() * rollrate) * 15;

        double scalebob = (1.0 - abs(cos(GetAge() * rollrate))) * 0.1;
        double cappedscale = scalebob + SmoothCap(0.5 + double(amount) / 100.,3);
        scale = (cappedscale,cappedscale);
    }
}