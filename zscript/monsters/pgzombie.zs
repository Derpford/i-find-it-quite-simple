class PlasmaZombie : SimpleMonster {
    // Look out! He's got a plasma gun!
    // Fires weaker plasma than the player, but at a similar rate. Doesn't always stop, either.

    default {
        Health 50; // Slightly weaker than the CG zombie.
        Radius 20;
        Height 56;
        Mass 80; // Easier to push around, too!
        Speed 8;
        PainChance 170;
        Monster;
        +FLOORCLIP;
        SeeSound "shotguy/sight";
        AttackSound "weapons/plasmaf";
        PainSound "shotguy/pain";
        DeathSound "shotguy/death";
        ActiveSound "shotguy/active";
        Obituary "%o was scorched by a Plasma Trooper.";
        Tag "Plasma Trooper";
        DropItem "SimplePlasma";

        SimpleMonster.Category "ZOMBIE",3;
        SimpleMonster.Weight 4; // Slightly less common than chaingunners.
    }

    action void FirePlasma() {
        A_SpawnProjectile("PZombieBolt");
        A_StartSound("weapons/plasmaf");
    }

    states {
        Spawn:
            FRPO AB 8 A_Look();
            Loop;
        
        See:
            FRPO AABBCCDD 2 A_Chase(); // Slightly more agile than average.
            Loop;
        
        Missile:
            FRPO E 15 A_FaceTarget();
        MissileLoop:
            FRPO F 2 FirePlasma();
            FRPO E 3;
            FRPO E 0 A_MonsterRefire(80,"MissileEnd");
            Loop;
        MissileEnd:
            FRPO E 10;
            Goto See;
        
        Pain:
            FRPO G 3;
            FRPO G 4 A_Pain();
            Goto See;
        
        Death:
            FRPO G 4;
            FRPO H 4;
            FRPO I 4 A_Scream();
            FRPO J 4 A_NoBlocking();
            FRPO K 4;
            FRPO L -1;
        
        XDeath:
            FRPO G 4;
            FRPO O 4 A_ScreamAndUnblock();
            FRPO PQRSTU 4;
            FRPO V -1;
        
        Raise:
            FRPO L 5;
            FRPO KJIHG 5;
            Goto See;
    }
}

class PZombieBolt : BlueBolt {
    default {
        DamageFunction (24);
    }
}