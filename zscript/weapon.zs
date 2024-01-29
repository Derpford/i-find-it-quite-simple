class SimpleWeapon : Weapon abstract {
    // I find it quite simple, actually.
    int magcap, mag; // How many shots between reloads? Duke-style reloading.
    Property Mag : magcap;
    bool tubeload; // Load like a shotgun.
    Property TubeLoad: tubeload;
    name ammodrop;
    Property AmmoDrop: ammodrop;

    string category; // What kind of weapon is this?
    int rarity; // How cool is it? 0 is base content.
    Property Category: category, rarity;

    WeaponMod wm1, wm2; // TODO

    default {
        SimpleWeapon.Mag -1;
        SimpleWeapon.TubeLoad false;
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();
        mag = magcap;
        if (!owner && ammodrop) {
            vector3 offs = (frandom(-12,12),frandom(-12,12),frandom(-12,12));
            Spawn(ammodrop,pos + offs);
        }
    }

    override void DetachFromOwner() {
        super.DetachFromOwner();
        mag = magcap; 
        // You can repeatedly new york reload guns you've dropped.
        // Don't ask how this would work physically, just roll with it.
    }

    override bool HandlePickup(Inventory item) {
        if (item is "SimpleWeapon") {
            SimpleWeapon s = SimpleWeapon(item);
            if (s.category == category) {
                return true; // Don't pick this thing up!
            }
        }

        return super.HandlePickup(item);
    }

    bool AttachMod(WeaponMod mod) {
        if (!wm1) {
            wm1 = WeaponMod(spawn(mod.GetClassName(),pos));
            wm1.BecomeItem();
            console.printf("WM1 set");
            return true;
        } else if (!wm2) {
            wm2 = mod;
            console.printf("WM2 set");
            return true;
        }
        return false;
    }

    override bool CheckAmmo(int firemode, bool autoswitch, bool required, int count) {
        int reserve = mag;
        int a1 = owner.CountInv(AmmoType1);
        int a2 = owner.CountInv(AmmoType2);
        if (firemode == PrimaryFire && AmmoType1) {
            reserve = a1;
        } else if (firemode == AltFire && AmmoType2) {
            reserve = a2;
        } else {
            // firemode == EitherFire 
            // This is for switching, probably.
            if (AmmoType1 || AmmoType2) {
                // This weapon cares about ammo.
                return a1 > 0 || a2 > 0;
            } else {
                return true; // This is an infinite-ammo weapon like a pistol.
            }
        }
        if (magcap > 0 && firemode == PrimaryFire) { // Only the primary fire uses the mag.
            return mag > 0 && reserve > 0;
        } else {
            return super.CheckAmmo(firemode,autoswitch,required,count);
        }
    }

    action void Hitscan(vector2 spread, int number, int damage, bool ammo = true, Name mod = "None") {
        if (ammo) {
            invoker.owner.TakeInventory(invoker.AmmoType1,invoker.AmmoUse1);
        }
        for (int i = 0; i < number; i++) {
            vector2 angs = (invoker.owner.angle + frandom(-spread.x,spread.x),invoker.owner.pitch + frandom(-spread.y,spread.y));
            Actor puff = LineAttack(angs.x,8192,angs.y,damage,mod,"ModdablePuff");
            if (puff) {
                if (invoker.wm1) {invoker.wm1.OnFire(puff);}
                if (invoker.wm2) {invoker.wm2.OnFire(puff);}
            }
        }
    }

    action void A_Reload(bool altammo = false) {
        name loading;
        if (altammo && invoker.ammotype2) {
            loading = invoker.ammotype2.GetClassName();
        } else if (invoker.ammotype1) {
            loading = invoker.ammotype1.GetClassName();
        }

        int amt;
        if (loading) {
            amt = min(invoker.magcap,invoker.owner.CountInv(loading));
        } else {
            // This weapon does not use ammo.
            amt = invoker.magcap;
        }
        if (invoker.tubeload) {
            invoker.mag = min(invoker.mag+1,amt);
        } else {
            invoker.mag = amt;
        }
    }

    action bool ReloadEnd() {
        int cap = min(invoker.owner.CountInv(invoker.ammotype1),invoker.magcap);
        return invoker.mag >= cap;
    }
}

class ModdablePuff : BulletPuff replaces BulletPuff {
    // A puff that conveniently always spawns.
    default {
        +PUFFONACTORS;
        +ALWAYSPUFF;
        +HITTRACER;
    }

    void CallMods() {
        // Iterates through the inventory and calls all ShotMods.
        Inventory i = inv;
        while (i) {
            ShotModifier mod = ShotModifier(i);
            if (mod) {
                mod.OwnerDied();
            }
            i = i.inv;
        }
    }
    
    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 CallMods();
        Goto Super::Spawn;
    }
}

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