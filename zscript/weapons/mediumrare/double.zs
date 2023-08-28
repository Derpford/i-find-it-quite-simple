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
        
        SimpleWeapon.Mag -1;
    }

    action void FireBuckshot() {
        Hitscan((8,1),21,random(7,15));
        A_StartSound("weapons/sshotf");
        A_GunFlash();
    }

    action void FireDragonBreath() {
        A_FireProjectile("DragonBreathBlast");
        A_StartSound("weapons/sshotf");
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

        AltFire:
            SHT2 A 3 FireDragonBreath();
            Goto Reload;

        Flash:
            SHT2 I 3 Bright A_Light1();
            SHT2 J 2 Bright A_Light2();
            Goto LightDone;
    }
}

class DragonBreathBlast : Actor {
    default {
        PROJECTILE;
        Radius 2; // Uses explosions to do "ripping".
        +THRUACTORS;
        +BRIGHT;
        RenderStyle "Add";
        DamageType "Fire";
        Speed 60;
    }

    action void FireBurst() {
        double range = 64;
        A_Explode(10,range,0,fulldamagedistance:range);
        if (bNOGRAVITY) {
            if (invoker.vel.length() > 10) {
                invoker.vel = invoker.vel.unit() * (invoker.vel.length() * 0.9);
            } else {
                bNOGRAVITY = false;
            }
        }
        A_SpawnItemEX("FireParticle",range,angle:frandom(0,360));
    }

    states {
        Spawn:
            MISL BBCCDDCC 1 FireBurst();
            Loop;
        
        Death:
            MISL CD 3;
            Stop;

    }
}

class FireParticle : Actor {
    default {
        +NOINTERACTION;
        RenderStyle "Add";
        Scale 0.25;
        +BRIGHT;
    }

    states {
        Spawn:
            MISL BCD 3;
            Stop;
    }
}