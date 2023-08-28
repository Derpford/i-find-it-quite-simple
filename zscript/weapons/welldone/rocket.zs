class RawketLawnchair : SimpleWeapon {
    default {
        Tag "Rawket Lawnchair";
        SimpleWeapon.Mag -1;
        SimpleWeapon.Category "EXPLOSIVE",0;

        Weapon.SlotNumber 5;
        Weapon.AmmoType1 "RocketAmmo";
        SimpleWeapon.AmmoDrop "RocketAmmo";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 2;
        Inventory.PickupMessage "RAWKET LAWNCHAIR!";
    }

    action void FireRocket() {
        A_FireProjectile("SimpleRocket");
        A_StartSound("weapons/rocklf");
        A_GunFlash();
    }

    states {
        Spawn:
            LAUN A -1;
            Stop;
        
        Select:
            MISG A 1 A_Raise(18);
            Loop;
        DeSelect:
            MISG A 1 A_Lower(18);
            Loop;
        
        Ready:
            MISG A 1 A_WeaponReady();
            Loop;
        
        Fire:
            MISG B 8 FireRocket();
            MISG B 8;
            MISG A 4;
            Goto Ready;
        
        Flash:
            MISF AB 2 Bright;
            MISF CD 3 Bright;
            Goto LightDone;
    }
}

class SimpleRocket : Actor {
    default {
        PROJECTILE;
        Speed 80;
        DamageFunction (40);
        DeathSound "weapons/rocklx";
    }

    states {
        Spawn:
            MISL A 5 A_SpawnItemEX("SimpleRocketTrail",-24);
            Loop;
        
        Death:
            MISL B 4 Bright A_Explode(128);
            MISL CD 4 Bright;
            Stop;
    }
}

class SimpleRocketTrail : Actor {
    default {
        +NOINTERACTION;
        Scale 0.5;
    }

    states {
        Spawn:
            MISL BC 1 Bright;
            MISL D 0 A_SetScale(0.25);
            SMOK ABC 1;
            Stop;
    }
}