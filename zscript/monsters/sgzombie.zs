class ShotZombie : SimpleMonster {
    // A zombie with a shotgun!
    // Base content. 
Default
	{
		Health 30;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 170;
		Monster;
		+FLOORCLIP
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";
		Obituary "%o got taken out by a shotgun zombie.";
		Tag "Shotgun Zombie";
		DropItem "SimpleShotgun";

        SimpleMonster.Category "ZOMBIE",2;
        SimpleMonster.Weight 5;
	}

    action void FireShotgun() {
        A_CustomBulletAttack(22.5,0,3,random(1,5)*3, "BulletPuff", 0, CBAF_NORANDOM);
    }

	States
	{
	Spawn:
		SPOS AB 10 A_Look();
		Loop;
	See:
		SPOS AABBCCDD 3 A_Chase();
		Loop;
	Missile:
		SPOS E 10 A_FaceTarget();
		SPOS F 10 BRIGHT FireShotgun();
		SPOS E 10;
		Goto See;
	Pain:
		SPOS G 3;
		SPOS G 3 A_Pain();
		Goto See;
	Death:
		SPOS H 5;
		SPOS I 5 A_Scream();
		SPOS J 5 A_NoBlocking();
		SPOS K 5;
		SPOS L -1;
		Stop;
	XDeath:
		SPOS M 5;
		SPOS N 5 A_XScream();
		SPOS O 5 A_NoBlocking();
		SPOS PQRST 5;
		SPOS U -1;
		Stop;
	Raise:
		SPOS L 5;
		SPOS KJIH 5;
		Goto See;
	}
}