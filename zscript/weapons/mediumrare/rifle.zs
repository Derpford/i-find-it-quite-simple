class GrenadeRifle : StockRifle {
    // Like the Stock Rifle, but looks different, has slightly different handling, and also has a grenade launcher.
    int shotcount;
    default {
        Tag "Grenade Rifle";
        SimpleWeapon.Category "RIFLE",1;
        SimpleWeapon.Mag 20;

        Inventory.PickupMessage "Ganked a Grenade Rifle!";

        Weapon.AmmoType2 "Clip";
        Weapon.AmmoUse2 20;
    }

    action void FireRifle2() {
        Hitscan((1,1.5),1,random(20,30));
        A_StartSound("weapons/rifle2");
        A_Overlay(-2,"Flash");
        A_OverlayFlags(-2,PSPF_RENDERSTYLE,true);
        invoker.mag--;
    }

    action void SetFireTic() {
        invoker.shotcount++;
        if (invoker.shotcount % 4 == 0)  {
            invoker.shotcount = 0;
            A_SetTics(2);
        }
    }

    action void FireGrenade() {
        A_FireProjectile("RifleGrenade",pitch:-5);
        A_StartSound("Hellstorm/Fire");
        A_Overlay(-2,"Smoke");
        A_OverlayFlags(-2,PSPF_RENDERSTYLE,true);
    }

    states {
        Spawn:
            GRFI A -1;
            Stop;
        
        Select:
            GRFG A 1 A_Raise(18);
            Loop;
        DeSelect:
            GRFG A 1 A_Lower(18);
            Loop;
        
        Ready:
            GRFG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            GRFG A 0 A_OverlayPivot(0,0.5,1);
            GRFG A 2 A_WeaponOffset(12,48,WOF_INTERPOLATE);
            GRFG A 8 A_StartSound("weapons/sshoto");
            GRFG A 6 A_OverlayRotate(0,-12);
            GRFG A 0 A_Reload();
            GRFG A 2 A_OverlayRotate(0,0);
            GRFG A 0 A_StartSound("weapons/sshotc");
            GRFG A 2 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            Goto Ready;

        Fire:
            GRFG A 1 FireRifle2();
            GRFG A 1 A_WeaponOffset(0,12,WOF_ADD);
            GRFG A 1 { A_WeaponOffset(0,-12,WOF_ADD); SetFireTic(); }
            GRFG A 1 FireRifle2();
            GRFG A 1 A_WeaponOffset(0,12,WOF_ADD);
            GRFG A 1 { A_WeaponOffset(0,-12,WOF_ADD); SetFireTic(); }
            Goto Ready;
        
        Flash:
            GRFF ABCD random(0,1) Bright A_OverlayRenderStyle(-2,STYLE_Add);
            Stop;

        AltFire:
            GRFG A 1 FireGrenade();
            GRFG A 4 A_WeaponOffset(0,30,WOF_ADD);
            GRFG A 16 A_WeaponOffset(0,-30,WOF_ADD);
            Goto Reload; // tech: ending a mag with a grenade shot goes direct into reloading
        
        Smoke:
            GRFF E 3 A_OverlayRenderStyle(-2,STYLE_Add);
            GRFF F 5;
            GRFF G 7;
            Stop;
    }
}

class RifleGrenade : GrenadeShot {
    default {
        BounceType "None";
        Speed 60;
    }
}