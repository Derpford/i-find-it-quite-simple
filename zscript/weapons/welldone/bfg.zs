class SimpleBFG : SimpleWeapon {
    // A more rapid-fire roomclearer than the original.
    static const String bwords[] = {
        "Big",
        "Bad",
        "Ballin'",
        "Banger",
        "Blasting",
        "Bio",
        "Botis",
        "Burning",
        "Bean",
        "Boggis",
        "Bunce",
        "Bouncy",
        "Boink",
        "Buffoon"
    };
    static const String fwords[] = {
        "Fragging",
        "Freakin'",
        "Foul-Mouthed",
        "Field",
        "Fargo",
        "Fella's",
        "Fart",
        "Frank",
        "Far-out",
        "Funky",
        "Fun",
        "Friendly",
        "Fat"
    };
    static const String gwords[] = {
        "Gun",
        "Glyph",
        "Garage",
        "Grand-daddy",
        "Gay",
        "Gigaton",
        "Giant",
        "Gander",
        "Gender",
        "Galaxy",
        "Gremlin",
        "Goon",
        "Grinder",
        "Goober"
    };
    default {
        SimpleWeapon.Mag -1;
        SimpleWeapon.Category "BFG",0;
        
        Weapon.SlotNumber 7;
        Weapon.AmmoType1 "Cell";
        Weapon.AmmoUse1 5;
        Weapon.AmmoGive1 40;
        SimpleWeapon.AmmoDrop "Cell";

        Inventory.PickupMessage "Bagged the BFG10K! Impressive.";
    }

    string GetNewTag() {
        String b = bwords[random(0,bwords.size()-1)];
        String f = fwords[random(0,fwords.size()-1)];
        String g = gwords[random(0,gwords.size()-1)];
        return String.format("%s %s %s 10K",b,f,g);
    }

    override void Tick() {
        Super.Tick();
        if(GetAge() % 35 == 0) {
            SetTag(GetNewTag());
        }
    }
    
    states {
        Spawn:
            BFUG A -1;
            Stop;
        
        Select:
            BFGG A 1 A_Raise(12);
            Loop;
        DeSelect:
            BFGG A 1 A_Lower(12);
            Loop;
        
        Ready:
            BFGG A 1 A_WeaponReady();
            Loop;
        
        Fire:
            BFGG A 5;
            BFGG B 10;
            BFGG A 10;
            Goto Ready;        
    }
}