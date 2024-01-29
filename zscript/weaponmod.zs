class WeaponMod : Inventory {
    // Alters projectiles fired by the weapon it's attached to.

    Name smod;
    Property ShotMod : smod; // By default, sticks this on the weapon's projectiles.

    default {
        Inventory.MaxAmount 5; // You should probably use them, though.
        Inventory.Amount 1;
        +Inventory.INVBAR;
        -Inventory.AUTOACTIVATE;
    }

    override bool Use(bool pick) {
        SimpleWeapon wep = SimpleWeapon(owner.player.readyweapon);
        if (wep) {
            if (wep.AttachMod(self)) {
                return true;
            }
        }
        return false;
    }

    virtual void OnFire(Actor proj) {
        // Do stuff with the projectile here.
        // This usually means adding a ShotModifier, so...
        if (smod) {
            console.printf("Applied a shot mod: %s",smod);
            proj.GiveInventory(smod,1);
        }
    }
}

class ShotModifier : Inventory abstract {
    // Remember to modify OwnerDied to trigger effects.
}

class ExplosiveMod : WeaponMod {
    double timer;

    default {
        WeaponMod.ShotMod "ExplosiveShots";
    }

    override void Tick() {
        super.Tick();
        timer = max(0,timer - (1./35.));
    }

    override void OnFire(Actor proj) {
        if (timer <= 0) {
            super.OnFire(proj);
            timer = 1.0;
        }
    }

    states {
        Spawn:
            ROCK A -1;
            Stop;
    }
}

class ExplosiveShots : ShotModifier {
    // Explodes!

    override void OwnerDied() {
        let it = owner.Spawn("EShotExplosion",owner.pos);
        if (it) {
            it.target = owner.target;
        }
    }
}

class EShotExplosion: Actor {
    default {
        +NOGRAVITY;
    }
    states {
        Spawn:
            MISL B 0;
            MISL B 3 Bright A_StartSound("weapons/rocklx");
            MISL C 3 Bright A_Explode(128);
            MISL D 3 Bright;
            Stop;
    }
}

class RipperMod : WeaponMod {
    override void OnFire(Actor proj) {
        console.printf("Appled RIPPER");
        proj.bRIPPER = true;
        if (proj.DamageMultiply >= 1) {
            proj.DamageMultiply = 0.2;
        } else {
            proj.DamageMultiply *= 1.5;
        }
    }

    states {
        Spawn:
            CELP A -1;
            Stop;
    }
}


class BleedMod : WeaponMod {
    default {
        WeaponMod.ShotMod "BleedShots";
    }

    states {
        Spawn:
            PSTR A -1;
    }
}

class BleedShots : ShotModifier {
    override void OwnerDied() {
        if (owner.tracer) {
            owner.tracer.GiveInventory("Bleed",1);
        }
    }
}

class Bleed : Inventory {
    // Permanent bleed stack.
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 500;
        Obituary "%o bled to death.";
    }

    override void DoEffect() {
        if (owner.GetAge() % 7 == 0) { // 5/s
            owner.DamageMobj(self,self,amount,"Bleed",DMG_NO_PAIN|DMG_THRUSTLESS);
        }
    }
}