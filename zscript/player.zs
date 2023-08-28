class SimplePlayer : DoomPlayer {
    default {
        Player.StartItem "StatBlock";
        Player.StartItem "SimplePistol";
        Player.StartItem "DLCBuyButton";
        Player.StartItem "ScoreItem", 500;
    }

    override void Tick() {
        Super.Tick();

        // If not dead: Do a search for nearby XP orbs and collect them.
        if (health > 0) {
            ThinkerIterator orbs = ThinkerIterator.Create("VacuumChase");
            Actor o;
            while (o = Actor(orbs.next())) {
                if (o.target) { continue; } // Ignore orbs that have a target already
                if (Vec3To(o).length() <= min(o.GetAge() * 4,256)) {
                    o.target = self; 
                }
            }
        }
    }

    override void CheckJump() {
        let btn = GetPlayerInput(INPUT_BUTTONS);
        bool isMoving = btn & (BT_FORWARD|BT_BACK|BT_MOVELEFT|BT_MOVERIGHT);
        bool isStrafing = btn & (BT_MOVELEFT|BT_MOVERIGHT);
        bool isForward = btn & BT_FORWARD;
        bool isBack = btn & BT_BACK;
        bool isJumping = btn & BT_JUMP;
        double xv, yv, ang;
        if (isMoving) {
            xv = GetPlayerInput(MODINPUT_FORWARDMOVE) / 12800.0;
            yv = GetPlayerInput(MODINPUT_SIDEMOVE) / 10240.0;
            ang = atan2(-yv,xv);
        }
        if(isJumping && player.onground)
		{
			if(waterlevel >= 2)
			{
				// Swimming overrides everything.
				vel.z = 4 * speed;
				return;
			}

            if (isMoving) {
                if (!isForward) {
                    // Jumping while strafing applies additional sideways boost.
                    // Backjumping does something similar.
                    double boostang = 0;
                    if (isStrafing && !isBack) {
                        boostang = -90;
                        if (yv < 0) {
                            boostang = 90;
                        }
                    }
                    if (isBack && !isStrafing) {
                        boostang = 180;
                    }
                    VelFromAngle(15,angle+boostang);
                } else {
                    // Jumping while moving forward coerces your velocity toward your movement keys.
                    vector2 inputvel = (cos(angle+ang),sin(angle+ang));
                    double boost = 1 - vel.xy.unit() dot inputvel;
                    Thrust(vel.length() * boost * 0.5,angle+ang);
                }
            }

            vel.z += 10;
        }
    }
}