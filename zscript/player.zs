class SimplePlayer : DoomPlayer {
    default {
        Player.StartItem "StatBlock";
        Player.StartItem "SimplePistol";
    }

    override void Tick() {
        Super.Tick();

        // If not dead: Do a search for nearby XP orbs and collect them.
        if (health > 0) {
            ThinkerIterator orbs = ThinkerIterator.Create("XPOrb");
            Actor o;
            while (o = Actor(orbs.next())) {
                if (o.target) { continue; } // Ignore orbs that have a target already
                if (Vec3To(o).length() <= min(o.GetAge() * 4,256)) {
                    o.target = self; 
                }
            }
        }

    }
}