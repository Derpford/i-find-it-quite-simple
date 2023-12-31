class RifleZombie : SimpleMonster {
    // A zombie with a rifle, dropping the Stock Rifle.
    // Tier 1, but weighted higher than the pistol zombie, so once it's unlocked
    // it'll spawn more often than pistol zombies.
    // Functionally, it's a standard zombieman with a two shot burst.
    
	Default
	{
		Health 20;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 200;
		Monster;
		+FLOORCLIP
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "$OB_ZOMBIE";
		Tag "$FN_ZOMBIE";
		DropItem "StockRifle";

        SimpleMonster.Category "ZOMBIE",1;
        SimpleMonster.Weight 15;
	}
 	States
	{
	Spawn:
		POSS AB 10 A_Look;
		Loop;
	See:
		POSS AABBCCDD 4 A_Chase;
		Loop;
	Missile:
		POSS E 10 A_FaceTarget;
		POSS F 8 A_PosAttack;
		POSS E 8;
		POSS F 8 A_PosAttack;
		POSS E 8;
		Goto See;
	Pain:
		POSS G 3;
		POSS G 3 A_Pain;
		Goto See;
	Death:
		POSS H 5;
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		POSS L -1;
		Stop;
	XDeath:
		POSS M 5;
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;
	Raise:
		POSS K 5;
		POSS JIH 5;
		Goto See;
	}
}