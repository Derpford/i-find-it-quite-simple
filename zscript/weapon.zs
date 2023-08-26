class SimpleWeapon : Weapon {
    // I find it quite simple, actually.
    int magcap, mag; // How many shots between reloads? Duke-style reloading.
    Property Mag : magcap;
    bool tubeload; // Load like a shotgun.
    Property TubeLoad: tubeload;
    name ammodrop;
    Property AmmoDrop: ammodrop;

    string category; // What kind of weapon is this?
    string rarity; // How cool is it?
    Property Category: category, rarity;

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

    override bool CheckAmmo(int firemode, bool autoswitch, bool required, int count) {
        int reserve = magcap;
        if (firemode == PrimaryFire && AmmoType1) {
            reserve = owner.CountInv(AmmoType1);
        } else if (firemode == AltFire && AmmoType2) {
            reserve = owner.CountInv(AmmoType2);
        }
        if (magcap > 0) {
            return mag > 0 && reserve > 0;
        } else {
            return super.CheckAmmo(firemode,autoswitch,required,count);
        }
    }

    action void Hitscan(vector2 spread, int number, int damage) {
        A_FireBullets(spread.x,spread.y,number,damage,flags:FBF_USEAMMO|FBF_NORANDOM);
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