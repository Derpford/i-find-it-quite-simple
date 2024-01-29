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
            wm2 = WeaponMod(spawn(mod.GetClassName(),pos));
            wm2.BecomeItem();
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
            Actor trail = invoker.owner.SpawnMissile(puff,"Tracer");
            if (trail) {
                trail.target = invoker.owner;
                if (invoker.wm1) {invoker.wm1.OnFire(trail);}
                if (invoker.wm2) {invoker.wm2.OnFire(trail);}
            }
        }
    }

    action void Projectile(Name type, vector2 spread = (0,0), int number = 1,bool ammo = true, vector2 offs = (0,0),vector2 aoffs = (0,0)) {
        for (int i = 0; i < number; i++) {
            vector2 angs = (aoffs.x + frandom(-spread.x,spread.x),aoffs.y + frandom(-spread.y,spread.y));
            Actor a, real;
            [a,real] = A_FireProjectile(type,angs.x,ammo,offs.x,offs.y,0,angs.y);
            if (real) {
                if (invoker.wm1) {invoker.wm1.OnFire(real);}
                if (invoker.wm2) {invoker.wm2.OnFire(real);}
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

class Tracer : FastProjectile {
    // A FastProjectile that handles hitscan weapons' on-hit effects,
    // because doing them with the hitscan is hacky.
    mixin ModdableProjectile;

    Array<Actor> hits;

    override int SpecialMissileHit (Actor victim) {
        // If this projectile's been given +RIPPER, trigger its on-hits.
        int res = super.SpecialMissileHit(victim);
        if (bRIPPER && res == -1 && victim != target && hits.find(victim) == hits.size()) {
            CallMods();
            hits.push(victim);
        }
        return res;
    }

    default {
        Speed 200;
        MissileHeight 8;
        MissileType "TracerTrail";
    }
    
    states {
        Spawn:
            TNT1 A -1;
        
        Death:
            TNT1 A 0 CallMods();
            Stop;
    }

}

class TracerTrail : Actor {
    default {
        RenderStyle "Add";
        +NOINTERACTION;
    }

    states {
        Spawn:
            PUFF A 1 A_FadeOut();
            Loop;
    }
}

class SimpleProjectile : Actor {
    mixin ModdableProjectile;

    override int SpecialMissileHit (Actor victim) {
        // If this projectile's been given +RIPPER, trigger its on-hits.
        if (bRIPPER) {
            CallMods();
        }

        return super.SpecialMissileHit(victim);
    }
}

mixin class ModdableProjectile {
    void CallMods() {
        // Iterates through the inventory and calls all ShotMods.
        Inventory i = inv;
        while (i) {
            console.printf("found %s", i.GetTag());
            ShotModifier mod = ShotModifier(i);
            if (mod) {
                console.printf("Called %s",mod.GetTag());
                mod.OwnerDied();
            }
            i = i.inv;
        }
    }
}

class ModdablePuff : BulletPuff replaces BulletPuff {
    // A puff that conveniently always spawns.
    default {
        +PUFFONACTORS;
        +ALWAYSPUFF;
        +HITTRACER;
    }
}