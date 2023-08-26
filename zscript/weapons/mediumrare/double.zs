class DoubleBarrel : SimpleWeapon {
    default {
        Tag "Double Barrel";
        SimpleWeapon.Category "SHOTGUN",1;

        Weapon.SlotNumber 3;
        Weapon.AmmoType1 "Shell";
        Weapon.AmmoType2 "Shell";
        SimpleWeapon.AmmoDrop "Shell";
        Weapon.AmmoUse1 2;
        Weapon.AmmoGive1 2;
        Weapon.AmmoUse2 4;
        
        SimpleWeapon.Mag 2;
    }

    action void FireBuckshot() {
        Hitscan((8,1),21,random(7,15));
        A_StartSound("weapons/sshotf");
        A_GunFlash();
        invoker.mag -= 2;
    }

    action void FireDragonBreath() {
        // TODO: Dragon's Breath projectile.
        A_StartSound("weapons/sshotf");
        invoker.mag -= 2;
    }

    states {
        Spawn:
            SGN2 A -1;
            Stop;
        
        Select:
            SHT2 GGGHHH 1 A_Raise(18);
        SelLoop:
            SHT2 A 1 A_Raise(18);
            Loop;
        
        DeSelect:
            SHT2 BBBCCC 1 A_Lower(18);
        DeSelLoop:
            SHT2 C 1 A_Lower(18);
            Loop;

        Ready:
            SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Fire:
            SHT2 A 3 FireBuckshot();
        Reload:
            SHT2 A 5;
            SHT2 B 5;
            SHT2 C 6;
            SHT2 D 6 A_StartSound("weapons/sshoto");
            SHT2 E 8;
            SHT2 F 6 A_StartSound("weapons/sshotl");
            SHT2 G 5 A_Reload();
            SHT2 H 5 A_StartSound("weapons/sshotc");
            SHT2 A 3;
            Goto Ready;

        Flash:
            SHT2 I 3 Bright A_Light1();
            SHT2 J 2 Bright A_Light2();
            Goto LightDone;
    }
}
