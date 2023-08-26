class SimpleShotgun : SimpleWeapon replaces Shotgun {
    default {
        Tag "Shotgun";
        SimpleWeapon.TubeLoad true;
        SimpleWeapon.Mag 8;
        SimpleWeapon.Category "SHOTGUN", "COMMON";

        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "Shell";
        SimpleWeapon.AmmoDrop "Shell";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 4;
        Inventory.PickupMessage "Snagged a shotgun!";
    }

    action void FireShotgun() {
        // TODO
        A_FireBullets(3,2,7,random(7,15),flags:FBF_USEAMMO|FBF_NORANDOM);
        A_StartSound("weapons/sshotf");
        invoker.mag--;
    }

    states {
        Spawn:
            SHOT A -1;
            Stop;
        
        Select:
            SHTG B 1 A_Raise(18);
            Loop;
        DeSelect:
            SHTG B 1 A_Lower(18);
            Loop;

        Ready:
            SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            SHTG B 8 A_WeaponOffset(8,20,WOF_ADD);
        ReloadLoop:
            SHTG B 0 A_JumpIf(ReloadEnd(),"ReloadEnd");
            SHTG B 2 A_WeaponOffset(4,16,WOF_ADD);
            SHTG B 0 A_Reload();
            SHTG B 0 A_StartSound("weapons/sshotl");
            SHTG B 6 A_WeaponOffset(-4,-16,WOF_ADD);
            SHTG B 4 A_Refire();
            Goto ReloadLoop;
        ReloadEnd:
            SHTG C 3 A_StartSound("misc/w_pkup");
            SHTG DC 3;
            SHTG B 2 A_WeaponOffset(-8,-20,WOF_ADD);
            Goto Ready;
        
        Fire:
            SHTG A 6 FireShotgun();
        AltFire:
            SHTG B 3 A_StartSound("misc/w_pkup",2);
            SHTG C 4;
            SHTG D 4;
            SHTG CB 3;
            Goto Ready;

    }
}