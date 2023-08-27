class SimplePistol : SimpleWeapon {
    default {
        Tag "Starting Pistol";
        SimpleWeapon.Mag 10;
        SimpleWeapon.Category "PISTOL", 0;
        Weapon.SlotNumber 1;
        Inventory.PickupMessage "Picked a pistol!";
    }

    action void FirePistol() {
        A_FireBullets(2,2,-1,random(8,12),flags:FBF_USEAMMO|FBF_NORANDOM);
        A_StartSound("weapons/pistol");
        invoker.mag--;
    }

    states {
        Spawn:
            PIST A -1;
            Stop;
        
        Select:
            PISG A 1 A_Raise(18);
            Loop;
        DeSelect:
            PISG A 1 A_Lower(18);
            Loop;
        
        Ready:
            PISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            PISG C 0 A_StartSound("misc/w_pkup");
            PISG C 6 A_WeaponOffset(0,20,WOF_ADD);
            PISG C 3 { A_Reload(); A_WeaponOffset(0,10,WOF_ADD); }
            PISG B 4 A_WeaponOffset(0,-30,WOF_ADD);
            PISG A 3;
            Goto Ready;
        
        Fire:
            PISG B 2 FirePistol();
            PISG C 3;
            PISG C 0 A_JumpIf(invoker.mag < 1,"Reload");
            Goto Ready;

    }
}