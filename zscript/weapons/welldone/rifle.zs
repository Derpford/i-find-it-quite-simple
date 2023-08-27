class StockRifle : SimpleWeapon {
    // AIM DOWN THE SIGHTS--
    default {
        Tag "Stock Rifle";
        SimpleWeapon.Category "RIFLE",0;
        SimpleWeapon.Mag 25;

        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "Clip";
        SimpleWeapon.AmmoDrop "Clip";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 15;
        Inventory.PickupMessage "Scooped up a Stock Rifle!";
    }

    action void FireRifle() {
        // A_FireBullets(0.5,2,1,random(12,15),flags:FBF_USEAMMO|FBF_NORANDOM);
        Hitscan((0.5,2),1,random(12,15));
        A_StartSound("weapons/pistol");
        A_Overlay(-2,"Flash");
        A_OverlayFlags(-2,PSPF_RENDERSTYLE,true);
        invoker.mag--;
    }

    action void TossEmptyMag() {
        A_StartSound("weapons/sshoto");
        A_SpawnItemEX("DroppedRifleMag",xvel:frandom(4,12),yvel:frandom(-4,4));
    }

    action void StartArmSwing() {
        A_Overlay(-3,"ReloadHand");
    }

    action void HandStart() {
        A_OverlayPivot(-3,0.3,1.0);
        A_OverlayRotate(-3,100);
    }

    action void HandSwing() {
        A_OverlayRotate(-3,-20,WOF_ADD);
    }

    states {
        Spawn:
            SMGR H 0;
            SMGI A -1;
            Stop;
        
        Select:
            SMGR B 0 StartArmSwing();
        SelectLoop:
            SMGR B 1 A_Raise(18);
            Loop;
        DeSelect:
            SMGG A 1 A_Lower(18);
            Loop;
        
        Ready:
            SMGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            SMGR A 4;
            SMGR B 2 TossEmptyMag();
            SMGR B 6 StartArmSwing();
            SMGR A 0 A_StartSound("weapons/sshotc");
            SMGR A 8 A_Reload();
            Goto Ready; // TODO
        
        Fire:
            SMGG A 0 FireRifle();
            SMGG A 2 A_WeaponOffset(0,10,WOF_ADD);
            SMGG A 4 A_WeaponOffset(0,-10,WOF_ADD);
            SMGG A 0 A_Refire();
            Goto Ready;
        
        Flash:
            SMGF ABCD 1 Bright A_OverlayRenderStyle(-2,STYLE_Add);
            Goto LightDone;
        
        ReloadHand:
            SMGR H 0;
            SMGR H 0 HandStart();
            SMGR HHHHHHHHHH 1 HandSwing();
            Goto LightDone;
    }
}

class DroppedRifleMag : Actor {
    mixin DropSpin;
    default {
        +FLATSPRITE;
        Scale 0.3;
    }

    states {
        Spawn:
            MAGD A -1;
            Stop;
    }
}