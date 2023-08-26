class SimpleHud : BaseStatusBar {
    HUDFont HealthFont, StatFont;

    override void Init() {
        Super.Init();
		SetSize(0,320,240);

        HealthFont = HUDFont.Create("DBIGFONT",0,false,1,1);
        StatFont = HUDFont.Create("DBIGFONT",0,false,1,1);
    }

    override void Draw(int state, double ticfrac) {
        Super.Draw(state,ticfrac);

        BeginHUD();
        DrawFullscreenStuff();
    }

    void DrawFullscreenStuff() {
        let plr = SimplePlayer(CPlayer.mo);

        StatBlock sb = StatBlock(plr.FindInventory("StatBlock"));

        // Bottom of screen stuff.
		int lbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM;
		int rbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM;
		int ltxtflags = DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
		int rtxtflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;
		int cbarflags = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
		int ctxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_CENTER;
		int crtxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT;

        if (plr && sb) {
            // Positional stuff.
            double marginbottom = -64;
            vector2 statblockpos = (32,-96);
            double xmargin = 48;
            double xmargin2 = xmargin + 64;
            vector2 a1pos = (-xmargin,marginbottom);
            vector2 a2pos = (-xmargin2,marginbottom);
            vector2 aiconscl = (3,3);
            vector2 aiconoffs = (2,-8);
            vector2 hpos = (xmargin,marginbottom);
            vector2 hscl = (2,2);
            vector2 armpos = (xmargin2,marginbottom);

            int hp = CPlayer.Health;
            int arm = plr.CountInv("BasicArmor"); // TODO: Replace armor...?
            int lvl = sb.lvl;
            int xp = sb.xp;
            double atk = sb.atk;
            double aim = sb.aim;
            double def = sb.def;
            double atktf = sb.aniatk;
            double aimtf = sb.aniaim;
            double deftf = sb.anidef;

            // Health and armor.
            Color hpcol = Font.CR_BRICK;
            if (hp < 34) {
                hpcol = Font.CR_ORANGE;
            } else if (hp < 67) {
                hpcol = Font.CR_YELLOW;
            } else if (hp < 101) {
                hpcol = Font.CR_BRICK;
            } else if (hp > 100) {
                hpcol = Font.CR_CYAN;
            } else {
                hpcol = Font.CR_DARKGRAY; // Presumably, you're dead if you got to here.
            }

            DrawString(HealthFont,FormatNumber(hp),hpos,ltxtflags,hpcol,scale:hscl);
            DrawString(HealthFont,FormatNumber(arm),armpos,ltxtflags,Font.CR_GREEN,scale:hscl);

            // Weapon.
            let wpn = CPlayer.ReadyWeapon;
            if (wpn) {
                let a1 = wpn.AmmoType1;
                let a2 = wpn.AmmoType2;
                if (a1 && wpn.ammouse1 > 0) {
					let a1real = plr.FindInventory(a1.GetClassName());// a1 is a ClassPointer<Ammo>, a1real is a Pointer<Inventory>
					DrawInventoryIcon(a1real,a1pos - aiconoffs,rbarflags,scale:aiconscl);
					int amt = GetAmount(a1.GetClassName());
                    DrawString(HealthFont,FormatNumber(amt),a1pos,rtxtflags,Font.CR_RED,scale:hscl);
                }
				if (a2 && a2 != a1 && wpn.ammouse2 > 0) {
					let a2real = plr.FindInventory(a2.GetClassName());
					DrawInventoryIcon(a2real,a2pos - aiconoffs,rbarflags,scale:aiconscl);
					int amt = GetAmount(a2.GetClassName());
                    DrawString(HealthFont,FormatNumber(amt),a2pos,rtxtflags,Font.CR_RED,scale:hscl);
                }

                // Magazine.
                if (wpn is "SimpleWeapon") {
                    let sw = SimpleWeapon(wpn);
                    int m = sw.mag;
                    if (a1 && wpn.ammouse1 > 0) {
                        m = min(m,GetAmount(a1.GetClassName()));
                    }
                    DrawString(HealthFont,FormatNumber(m),(0,-96),ctxtflags,Font.CR_WHITE,scale:hscl);
                }
            }
            
            // Stat block time.
            DrawString(StatFont,String.Format("ATK: %d",atk),statblockpos+(atktf,0),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("AIM: %d",aim),statblockpos+(aimtf,-16),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("DEF: %d",def),statblockpos+(deftf,-32),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("LVL: %d",lvl),statblockpos+(atktf+aimtf+deftf,-48),Font.CR_DARKGRAY);

        }
    }
}