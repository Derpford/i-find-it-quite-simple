class DLCBrain : Thinker {
    Array<String> dlcs; // Which DLCs do you have?
    Array<String> alldlcs; // A list of all DLCs.

    Array<String> removethings; // Which things need to be yeeted?

    void InitDLC() {
        dlcs.clear();
        dlcs.push("BasePack");
    }

    void InitAvailableDLCs() {
        // Should only need to happen once, since the list of available DLCs never changes.
        alldlcs.clear();
        foreach (c : AllClasses) {
            if (c is "DLCPack" && !c.IsAbstract()) {
                // Add this DLC to the DLCs list.
                Console.printf("Found DLC %s",c.GetClassName());
                alldlcs.push(c.GetClassName());
            }
        }
    }

    DLCPack FindDLC(string dlc) {
        let pack = DLCPack(new(dlc)).get();
        return pack;
    }

    bool BuyDLC(Actor buyer) {
        // Adds a random DLC that you don't have yet.
        Array<String> buyable;
        foreach (dlc : alldlcs) {
            if (dlcs.find(dlc) == dlcs.size()) {
                // We don't already have this one, so it's buyable.
                buyable.push(dlc);
            }
        }

        // If there are no available DLCs, return early.
        if (buyable.size() == 0) {
            Console.printf("You already own all DLCs!");
            return false;
        }

        // Pick a totally random DLC from the buyable list.
        string bought = buyable[random(0,buyable.size()-1)];
        // Print out its name!
        let pack = FindDLC(bought);
        if (pack) {
            Console.printf("You got the %s!",pack.packname);
            buyer.A_Print(String.Format("You got the %s!",pack.packname),0,"DBIGFONT");
        }
        // And add it to the list.
        dlcs.push(bought);
        return true;
    }

    void RemoveDLC(int idx) {
        if (idx >= dlcs.size() || idx < 0) {
            ThrowAbortException("Tried to remove DLC that isn't bought.");
        }
        let dlc = dlcs[idx];
        let pack = FindDLC(dlc);
        if (pack) {
            removethings.append(pack.weapons);
            removethings.append(pack.monsters);
        }
    }

    void GetWeapons(string category, out Array<string> weapons, out Array<double> weights) {
        foreach (pack : dlcs) {
            let d = FindDLC(pack);
            foreach (wep : d.weapons) {
                Class<Actor> it = wep;
                if (it) {
                    let wep = SimpleWeapon(GetDefaultByType(it));
                    if (wep) {
                        // Finally, we can check the damn category.
                        if (wep.category == category) {
                            weapons.push(wep.GetClassName());
                            weights.push(wep.rarity + 1); // Weight of 0 breaks things.
                        }
                    }
                }
            }
        }
    }

    void GetMonsters(string category, int spawntier, out Array<string> monsters, out Array<double> weights) {
        foreach (pack : dlcs) {
            let d = FindDLC(pack);
            foreach (mon : d.monsters) {
                Class<Actor> it = mon;
                if (it) {
                    let mon = SimpleMonster(GetDefaultByType(it));
                    if (mon) {
                        // Finally, we can check the damn category.
                        if (mon.category == category) {
                            double t = mon.tier;
                            double st = double(spawntier);
                            double div = min(t,st) / max(t,st);
                            monsters.push(mon.GetClassName());
                            weights.push(mon.weight * div);
                        }
                    }
                }
            }
        }
    }

    override void Tick() {
        super.Tick();
        {
            // Every tick, find up to five things that are in the removethings list and thanos-snap them.
            // If the attempt to find a thing fails, remove it from the removethings list.
            // Theoretically there's a race condition here, if something spawns in *JUST* after it gets removed from removethings,
            // but it's not worth tracking down.
            for (int i = 0; i < 5; i++) {
                int idx = removethings.size() % i;
                string cname = removethings[idx];
                ThinkerIterator it = ThinkerIterator.create(cname);
                let victim = Actor(it.next());
                if (victim) {
                    // Yeet it.
                    victim.A_Remove(AAPTR_DEFAULT); // The cleanest way to just make the thing go away.
                } else {
                    removethings.delete(idx); // We couldn't find this thing, so we must be done cleaning it up.
                }
            }
        }
    }

    DLCBrain init() {
        ChangeStatNum(STAT_STATIC);
        console.printf("Initialized content pack system");
        InitDLC();
        InitAvailableDLCs();
        return self; 
    }

    static DLCBrain get() {
        ThinkerIterator it = ThinkerIterator.create("DLCBrain",STAT_STATIC);
        let p = DLCBrain(it.next());
        if (!p) {
            p = new("DLCBrain");
            p = p.init();
        }

        return p; 
    }
}

class DLCBuyButton : Inventory {
    // A usable inventory item that buys new DLC.
    const cost = 1500;
    DLCBrain brain;
    default {
        +Inventory.INVBAR;
        +Inventory.KEEPDEPLETED;
        Tag "DLC Button";
        Inventory.Icon "PINSA0";
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();
        brain = DLCBrain.get();
    }

    override bool Use(bool pickup) {
        if (owner.Score >= cost) {
            if (brain.BuyDLC(owner)) {
                owner.Score -= cost; 
            }
            return false; // Don't consume the item.
        } else {
            owner.A_Print(String.Format("You need %d Bucks to buy DLC!",cost),0,"DBIGFONT");
            return false;
        }
    }
}

class DLCMonsterSpawner : RandomSpawner {
    // Like the WeaponSpawner, but for monsters.
    mixin WeightedRandom;
    string category;
    int tier;
    Property Category: category,tier; // Which kind of monster should spawn here?

    override Name ChooseSpawn() {
        bool nomonsters = sv_nomonsters || level.nomonsters;
        if (nomonsters) { return "None"; }
        DLCBrain brain = DLCBrain.get();
        Array<String> monsters;
        Array<double> weights;
        brain.GetMonsters(category,tier,monsters,weights);
        int select = WeightedRandom(weights);
        if (select >= 0) {
            return monsters[select];
        } else {
            // Whoops, nothing to spawn.
            return "None";
        }
    }
}

class DLCWeaponSpawner : RandomSpawner {
    mixin WeightedRandom;
    // Picks a random weapon out of available weapons of the appropriate type. Higher tier weapons have higher weight.
    string category;
    Property Category: category; // Which kind of weapon should spawn here?

    override Name ChooseSpawn() {
        DLCBrain brain = DLCBrain.get();
        Array<String> weapons;
        Array<double> weights;
        brain.GetWeapons(category,weapons,weights);
        int select = WeightedRandom(weights);
        if (select >= 0) {
            return weapons[select];
        } else {
            // Whoops, nothing to spawn.
            return "None";
        }
    }
}

class DLCPack : Thinker Abstract {
    // Contains a list of weapons and monsters unlocked by this pack.
    Array<String> weapons;
    Array<String> monsters;

    string packname;

    DLCPack init() {
        ChangeStatNum(STAT_STATIC);
        self.setup();
        Console.printf("Enabled DLC pack \"%s\"", packname);
        return self;
    }

    DLCPack get() {
        ThinkerIterator it = ThinkerIterator.create(GetClassName(),STAT_STATIC);
        let p = DLCPack(it.next());
        if (!p) {
            p = DLCPack(new(GetClassName()));
            p = p.init();
        }

        return p; 
    }

    abstract void setup(); // Add weapons and monsters to the pack.
}

class BasePack : DLCPack {
    // Contains all the starter weapons.
    override void setup() {
        packname = "Base Content";
        // Weapons
        weapons.push("SimplePistol");
        weapons.push("SimpleShotgun");
        weapons.push("StockRifle");
        weapons.push("SimpleGrenade");
        weapons.push("RawketLawnchair");
        weapons.push("SimplePlasma");
        // Monsters
        monsters.push("PistolZombie");
        monsters.push("ShotZombie");
    }
}

class BoomstickPack : DLCPack {
    // A simple DLC pack that adds the Double Barrel and Double Barrel Zombie.
    override void setup() {
        packname = "Boomstick Pack";
        weapons.push("DoubleBarrel");
        monsters.push("DBZombie");
    }
}

class HeavyPack : DLCPack {
    // Includes the Assault Cannon and Magnum Pistol.
    // Also the Chaingun Zombie.
    override void setup() {
        packname = "Heavy Weapons Pack";
        weapons.push("AssaultCannon");
        monsters.push("ChaingunZombie");
    }
}

class ZombiePack1 : DLCPack {
    // Includes the Rifle Zombie and Plasma Zombie.
    // Plasma Zombie TODO.
    override void setup() {
        packname = "Zombie Pack 1";
        monsters.push("RifleZombie");
    }
}