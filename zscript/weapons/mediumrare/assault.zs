class AssaultCannon : SimpleWeapon {
    int shots; // increments each shot. This weapon consumes ammo every 4th shot.
    default {
        Tag "Assault Cannon";
        SimpleWeapon.Mag 50;
        SimpleWeapon.Category "HEAVY",1;

        Weapon.SlotNumber 4;
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoType2 "Shell";
        SimpleWeapon.AmmoDrop "ShellBox";
        Weapon.AmmoUse1 1;
        Weapon.AmmoUse2 1;
        Weapon.AmmoGive1 30;
        Inventory.PickupMessage "Acquired the Assault Cannon!";
    }

        action void FireAC() {
            A_GunFlash();
            A_StartSound("weapons/pistol");
            bool ammo = false;
            if (invoker.shots == 0) {
                ammo = true;
            }
            Hitscan((3,4.5),3,random(10,15),ammo);
            if (ammo) {
                invoker.mag--;
            }
            invoker.shots = (invoker.shots + 1) % 4;
            console.printf("Shot count: %d",invoker.shots);
        }

    states {
        Spawn:
            MGUN A -1;
            Stop;
        
        Select:
            ASGG AAAABBBBCCCCDDDD 1 A_Raise(18);
            Loop;
        DeSelect:
            ASGG DDDDCCCCBBBBAAAA 1 A_Lower(18);
            Loop;

        Ready:
            ASGG ABCD 6 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            ASGG A 12 A_WeaponOffset(16,48,WOF_INTERPOLATE);
            ASGG A 0 A_StartSound("weapons/sshotc");
            ASGG B 16 A_WeaponOffset(0,52,WOF_INTERPOLATE);
            ASGG C 0 A_StartSound("weapons/sshotl");
            ASGG C 4 A_WeaponOffset(-24,48,WOF_INTERPOLATE);
            ASGG D 0 A_StartSound("weapons/sshoto");
            ASGG D 0 A_Reload();
            ASGG D 6 A_WeaponOffset(0,48,WOF_INTERPOLATE);
            ASGG A 12 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            Goto Ready;
        
        Fire:
            ASGF A 1 Bright FireAC();
            ASGG BCD 1 A_WeaponReady(WRF_NOPRIMARY|WRF_NOBOB);
            ASGF B 1 Bright FireAC();
            ASGG BCD 1 A_WeaponReady(WRF_NOPRIMARY|WRF_NOBOB);
            ASGF A 1 Bright FireAC();
            ASGG BCD 1 A_WeaponReady(WRF_NOPRIMARY|WRF_NOBOB);
            ASGF B 1 Bright FireAC();
            ASGG BCD 1 A_WeaponReady(WRF_NOPRIMARY|WRF_NOBOB);
            ASGG ABCD 2 A_Refire();
            Goto Ready;
        
        AltFire:
            ASGF A 1 Bright FireAC();
            ASGG B 1;
            ASGF B 1 Bright FireAC();
            ASGG C 1;
            ASGF A 1 Bright FireAC();
            ASGG D 1;
            ASGF B 1 Bright FireAC();
            ASGG A 1;
            ASGG BCD 1 A_Refire();
            ASGG ABCD 2 A_Refire();
            Goto Ready;
    }
}