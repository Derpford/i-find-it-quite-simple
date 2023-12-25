// Weapons.
class MeleeSpawn : DLCWeaponSpawner replaces Chainsaw {
    default {
        DLCWeaponSpawner.Category "MELEE";
    }
}

class PistolSpawn : DLCWeaponSpawner replaces Pistol {
    default {
        DLCWeaponSpawner.Category "PISTOL";
    }
}

class ShotgunSpawn : DLCWeaponSpawner replaces Shotgun {
    default {
        DLCWeaponSpawner.Category "SHOTGUN";
    }
}

class HeavySpawn : DLCWeaponSpawner replaces SuperShotgun {
    default {
        DLCWeaponSpawner.Category "HEAVY";
    }
}

class RifleSpawn : DLCWeaponSpawner replaces Chaingun {
    default {
        DLCWeaponSpawner.Category "RIFLE";
    }
}

class ExplosiveSpawn : DLCWeaponSpawner replaces RocketLauncher {
    default {
        DLCWeaponSpawner.Category "EXPLOSIVE";
    }
}

class EnergySpawn : DLCWeaponSpawner replaces PlasmaRifle {
    default {
        DLCWeaponSpawner.Category "ENERGY";
    }
}

class BFGSpawn : DLCWeaponSpawner replaces BFG9000 {
    default {
        DLCWeaponSpawner.Category "BFG";
    }
}

// Armors.

class LowArmorSpawn : DLCArmorSpawner replaces GreenARmor {
    default {
        DLCArmorSpawner.tier 1;
    }
}

class HighArmorSpawn : DLCArmorSpawner replaces BlueArmor {
    default {
        DLCArmorSpawner.tier 2;
    }
}

// Monsters.

class ZombSpawn1 : DLCMonsterSpawner replaces ZombieMan {
    default {
        DLCMonsterSpawner.Category "ZOMBIE",1;
    }
}

class ZombSpawn2 : DLCMonsterSpawner replaces ShotgunGuy {
    default {
        DLCMonsterSpawner.Category "ZOMBIE",2;
    }
}

class ZombSpawn3 : DLCMonsterSpawner replaces ChaingunGuy {
    default {
        DLCMonsterSpawner.Category "ZOMBIE",3;
    }
}