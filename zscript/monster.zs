class SimpleMonster : Actor abstract {
    // The base class for nasty critters.
    string category; // What kinda monster is this?
    int tier; // How badass is it? 1 is the lowest tier.
    Property Category: category, tier;
    // The difference in tier between a monster and its spawner affects its weight when deciding what to spawn.
    // The weight is multiplied by min(monstertier, spawnertier) / max(monstertier, spawnertier)
    // In other words, a tier 2 monster's spawn weight is halved on a tier 1 spawner,
    // a tier 1 monster's spawn rate is halved on a tier 2 spawner,
    // and a tier 3 monster on a tier 1 spawner has 1/3rd the weight.
    double weight;
    Property Weight: weight;
}