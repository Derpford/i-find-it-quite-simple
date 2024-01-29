class SimplePlasma : SimpleWeapon {
    default {
        Tag "Plasma Gun";
        SimpleWeapon.Mag 80;
        SimpleWeapon.Category "ENERGY",0;

        Weapon.SlotNumber 6;
        Weapon.AmmoType1 "Cell";
        Weapon.AmmoType2 "Cell";
        SimpleWeapon.AmmoDrop "Cell";
        Weapon.AmmoUse1 2;
        Weapon.AmmoGive1 40;
        Weapon.AmmoUse2 2;
        Inventory.PickupMessage "Pulled a Plasma Gun!";
    }

    action void FirePlasma() {
        Projectile("BlueBolt");
        A_StartSound("weapons/plasmaf");
        A_GunFlash();
        invoker.mag--;
    }

    action void FirePlasmaSpread() {
        Projectile("GreenBolt",offs:(-20,0));
        Projectile("GreenBolt",offs:(-8,0));
        Projectile("GreenBolt",offs:(8,0));
        Projectile("GreenBolt",offs:(20,0));
        A_StartSound("weapons/plasmaf");
        A_GunFlash();
        invoker.mag -= 4;
    }

    states {
        Spawn:
            PLAS A -1;
            Stop;
        
        Select:
            PLSG B 1 A_Raise(18);
            Loop;
        DeSelect:
            PLSG B 1 A_Lower(18);
            Loop;
        
        Ready:
            PLSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            PLSG B 20 A_Reload(); // TODO: Better reload anim
            Goto Ready;
        
        Fire:
            PLSG A 4 FirePlasma();
            PLSG B 10 A_Refire();
            Goto Ready;
        
        AltFire:
            PLSG A 10 FirePlasmaSpread();
            PLSG B 15 A_Refire();
            Goto Ready;
    }
}

class BlueBolt : SimpleProjectile {
    // A simple blue burst of plasma.
    default {
        PROJECTILE;
        DamageFunction (32);
        Speed 40;
        +BRIGHT;
        Radius 4;
        Height 6;
        DeathSound "weapons/plasmax";
    }

    states {
        Spawn:
            PLSS AB 3;
            Loop;
        Death:
            PLSE A 0 CallMods();
            PLSE ABCDE 4;
            Stop;
    }
}

class GreenBolt : BlueBolt {
    default {
        DamageFunction (40);
    }

    states {
        Spawn:
            APLS AB 3;
            Loop;
        Death:
            APBX A 0 CallMods();
            APBX ABCDE 4;
            Stop;
    }
}