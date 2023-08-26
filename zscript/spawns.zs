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