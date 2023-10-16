class PistolZombie : SimpleMonster {
    // A zombie with a pistol.
    // Low tier, but very common early on.
    // Functionally identical to the vanilla ZombieMan, but it drops a SimplePistol.

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
		Obituary "%o was mugged by a pistol zombie.";
		Tag "Pistol Zombie";
		DropItem "SimplePistol";

        SimpleMonster.Category "ZOMBIE",1;
        SimpleMonster.Weight 10;
	}
 	States
	{
	Spawn:
		MGPS AB 10 A_Look;
		Loop;
	See:
		MGPS AABBCCDD 4 A_Chase;
		Loop;
	Missile:
		MGPS E 10 A_FaceTarget;
		MGPS F 8 A_PosAttack;
		MGPS E 8;
		Goto See;
	Pain:
		MGPS G 3;
		MGPS G 3 A_Pain;
		Goto See;
	Death:
		MGPS H 4;
		MGPS V 4 A_Scream;
		MGPS W 4 A_NoBlocking;
		MGPS X 4;
		MGPS Y 4;
		MGPS Z -1;
		Stop;
	XDeath:
		MGPS M 5;
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;
	Raise:
		POSS K 5;
		POSS JI 5;
        MGPS H 5;
		Goto See;
	}
}