class SimpleHud : BaseStatusBar {
    HUDFont HealthFont, StatFont, SmallFont;

    double invticfrac; // controls animating invbar items

    override void Init() {
        Super.Init();
		SetSize(0,320,240);

        HealthFont = HUDFont.Create("DBIGFONT",0,false,1,1);
        StatFont = HUDFont.Create("DBIGFONT",0,false,1,1);
        SmallFont = HUDFont.Create("CONFONT",0,false,1,1);
    }

    override void Draw(int state, double ticfrac) {
        Super.Draw(state,ticfrac);

        BeginHUD();
        DrawFullscreenStuff();
    }

    void DrawFullscreenStuff() {
        let plr = SimplePlayer(CPlayer.mo);

        StatBlock sb = StatBlock(plr.FindInventory("StatBlock"));
        TechFlask tf = TechFlask(plr.FindInventory("TechFlask"));
        ArmorMod am = ArmorMod(plr.FindInventory("ArmorMod",true));

        // Bottom of screen stuff.
		int lbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM;
		int rbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM;
		int ltxtflags = DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
		int rtxtflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;
		int cbarflags = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
		int ctxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_CENTER;
        int toptxtflags = DI_SCREEN_CENTER_TOP|DI_TEXT_ALIGN_CENTER;
		int crtxtflags = DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT;
        int sidebartxt = DI_SCREEN_RIGHT_CENTER|DI_TEXT_ALIGN_RIGHT;

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
            int arm = plr.CountInv("ArmorPoints"); // TODO: Replace armor...?
            Color acol = am.col;
            int lvl = sb.lvl;
            int xp = sb.xp;
            double atk = sb.atk;
            double aim = sb.aim;
            double end = sb.end;
            double atktf = sb.aniatk;
            double aimtf = sb.aniaim;
            double endtf = sb.aniend;

            // Health and armor.
            Color hpcol = Font.CR_BRICK;
            if (hp <= 0) {
                hpcol = Font.CR_RED;
            } else if (hp < 34) {
                hpcol = Font.CR_ORANGE;
            } else if (hp < 67) {
                hpcol = Font.CR_YELLOW;
            } else if (hp < 101) {
                hpcol = Font.CR_BRICK;
            } else if (hp > 100) {
                hpcol = Font.CR_CYAN;
            } else {
                hpcol = Font.CR_DARKGRAY; // How did you get here?.
            }

            DrawString(HealthFont,FormatNumber(hp),hpos,ltxtflags,hpcol,scale:hscl);
            DrawString(HealthFont,FormatNumber(arm),armpos,ltxtflags,acol,scale:hscl);

            // Techflask values.
            if (tf) {
                DrawString(SmallFont,FormatNumber(tf.hpe),hpos + (0,16),ltxtflags,hpcol);
                DrawString(SmallFont,FormatNumber(tf.arme),armpos + (0,16),ltxtflags,acol);
            }

            // Weapons.
            Inventory inv = plr.inv;
            int sel = -1;
            Array<string> categories;
            categories.resize(7);
            while (inv) {
                if (inv is "SimpleWeapon") {
                    SimpleWeapon s = SimpleWeapon(inv);
                    int slot = s.slotnumber - 1;
                    categories[slot] = String.Format("%s [%d]",s.GetTag(), s.slotnumber);
                    if (CPlayer.ReadyWeapon == inv) {
                        sel = slot; // Latest item in the array is selected.
                    }
                }
                inv = inv.inv;
            }

            vector2 wlistpos = (-32,0 - (categories.size() * 4.5));
            for (int i = 0; i < categories.size(); i++) {
                if (sel == i) {
                    DrawString(SmallFont,categories[i],wlistpos + (0,i * 9),sidebartxt,Font.CR_WHITE);
                } else {
                    DrawString(SmallFont,categories[i],wlistpos + (0,i * 9),sidebartxt,Font.CR_DARKGRAY);
                }
            }

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
                    if (m > 0) {
                        DrawString(HealthFont,FormatNumber(m),(0,-96),ctxtflags,Font.CR_WHITE,scale:hscl);
                    }
                }
            }

            // Inventory bar.
			let w = plr.InvSel;
			if (w) {
				vector2 invpos = (-96,-8);
				if (IsInventoryBarVisible()) {
					invticfrac = clamp(invticfrac+0.5,0,4);
				} else {
					invticfrac = clamp(invticfrac-0.5,0,4);
				}
				if (w.PrevInv()) {
					DrawInventoryIcon(w.PrevInv(),invpos+(-16,-2),cbarflags,0.5);
				}
				if (w.NextInv()) {
					DrawInventoryIcon(w.NextInv(),invpos+(16,-2),cbarflags,0.5);
				}
                int wamt = GetAmount(w.GetClassName());
				DrawInventoryIcon(w,invpos+(0,-invticfrac),cbarflags);
                if (wamt > 1) {
                    DrawString(SmallFont,FormatNumber(wamt),invpos+(8,-4-invticfrac),cbarflags);
                }
			}
            
            // Score.

            DrawString(SmallFont,String.Format("$%d",plr.Score),(0,48),toptxtflags,Font.CR_WHITE,scale:(2,2));
            
            // Stat block time.
            DrawString(StatFont,String.Format("ATK: %d",atk),statblockpos+(atktf,0),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("AIM: %d",aim),statblockpos+(aimtf,-16),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("END: %d",end),statblockpos+(endtf,-31),ltxtflags,Font.CR_ICE);
            DrawString(StatFont,String.Format("LVL: %d",lvl),statblockpos+(atktf+aimtf+endtf,-48),Font.CR_DARKGRAY);

        }
    }
}