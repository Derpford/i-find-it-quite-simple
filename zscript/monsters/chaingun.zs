class ChaingunZombie : SimpleMonster {
    // Doesn't appear until the Assault Pack is unlocked...because he drops an Assault Cannon.
    // He's the first Tier 3 zombie, and has been altered slightly. He fires eight shots total, two shots per barrel.

    Default
	{
		Health 60; // Should be more reliably one-shot by shotguns now.
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 170;
		Monster;
		+FLOORCLIP
		SeeSound "chainguy/sight";
		PainSound "chainguy/pain";
		DeathSound "chainguy/death";
		ActiveSound "chainguy/active";
		AttackSound "chainguy/attack";
		Obituary "%o met the budda-budda-budda and became a bit too hole-y.";
		Tag "Chaingun Zombie";
		Dropitem "AssaultCannon";

        SimpleMonster.Category "ZOMBIE",3;
        SimpleMonster.Weight 5;
	}
    
    action void FireAC() {
        A_CustomBulletAttack(22.5,0,2,random(1,5)*3, "BulletPuff", 0, CBAF_NORANDOM);
    }

	States
	{
	Spawn:
		CPOS AB 10 A_Look();
		Loop;
	See:
		CPOS AABBCCDD 3 A_Chase();
		Loop;
	Missile:
		CPOS E 10 A_FaceTarget();
		CPOS FEFE 4 BRIGHT FireAC();
		CPOS E 10;
		Goto See;
	Pain:
		CPOS G 3;
		CPOS G 3 A_Pain();
		Goto See;
	Death:
		CPOS H 5;
		CPOS I 5 A_Scream();
		CPOS J 5 A_NoBlocking();
		CPOS KLM 5;
		CPOS N -1;
		Stop;
	XDeath:
		CPOS O 5;
		CPOS P 5 A_XScream();
		CPOS Q 5 A_NoBlocking();
		CPOS RS 5;
		CPOS T -1;
		Stop;
	Raise:
		CPOS N 5;
		CPOS MLKJIH 5;
		Goto See;
	}
}