class SimpleGrenade : SimpleWeapon {
    default {
        Tag "Grenade Launcher";
        SimpleWeapon.Mag -1;
        SimpleWeapon.Category "HEAVY",0;

        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoUse1 3;
        Weapon.AmmoGive1 3;
        SimpleWeapon.AmmoDrop "Shell";
        
        Inventory.PickupMessage "Grabbed a grenade launcher!";
    }

    action void FireGrenade() {
        A_FireProjectile("GrenadeShot",pitch: -5);
        A_StartSound("Hellstorm/Fire");
    }

    states {
        Spawn:
            HSTM A -1;
            Stop;
        
        Select:
            HSTM B 1 A_Raise(18);
            Loop;
        DeSelect:
            HSTM B 1 A_Lower(18);
            Loop;
        
        Ready:
            HSTM B 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Fire:
            HSTM C 2 Bright FireGrenade();
            HSTM DEF 1 Bright;
        Reload:
            HSTM B 4 A_StartSound("Hellstorm/Reload",3);
            HSTM B 6 A_WeaponOffset(0,40,WOF_INTERPOLATE);
            HSTM B 6 A_WeaponOffset(0,48,WOF_INTERPOLATE);
            HSTM B 8 A_WeaponOffset(16,52,WOF_INTERPOLATE);
            HSTM B 12;
            HSTM B 6 A_WeaponOffset(0,48,WOF_INTERPOLATE);
            HSTM B 4 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            Goto Ready;
    }
}

class GrenadeShot : Actor {
    default {
        PROJECTILE;
        -NOGRAVITY;
        Speed 60;
        DamageFunction (40);
        DeathSound "Hellstorm/Hit";
    }

    states {
        Spawn:
            HSBM A 1;
            Loop;
        
        Death:
            MISL B 0 { bNOGRAVITY = true; }
            MISL B 4 Bright A_Explode(128);
            MISL CD 4 Bright;
            Stop;
    }
}