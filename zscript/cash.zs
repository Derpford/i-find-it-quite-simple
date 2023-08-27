class SimpleCoin : VacuumChase {
    double multiplier;
    Property Mult : multiplier; // How much more valuable is this item than it usually is?

    override string PickupMessage() {
        return String.Format("Scored %d Bucks!",amount);
    }

    Default {
        Scale 0.5;
        Inventory.Amount 5;
        +INVENTORY.ALWAYSPICKUP;
    }

    override void PostBeginPlay() {
        super.PostBeginPlay();
    }

    override bool TryPickup(in out Actor other) {
        other.score += ceil(amount * multiplier);
        GoAwayAndDie();
        return true;
    }
}

class CopperCoin : SimpleCoin {
    default {
        SimpleCoin.Mult 1; // Basic coin value.
    }

    states {
        Spawn:
            SCRC ABCDEFGH 2;
            loop;
    }
}

class SilverCoin : SimpleCoin {
    default {
        SimpleCoin.Mult 1.5; // Better.
    }

    states {
        Spawn:
            SCRS ABCDEFGH 2;
            loop;
    }
}

class GoldCoin : SimpleCoin {
    default {
        SimpleCoin.Mult 2.5; // Best.
    }

    states {
        Spawn:
            SCRG ABCDEFGH 2;
            loop;
    }
}
