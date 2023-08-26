mixin class DropSpin {
    // When spawned, spin a bit.
    double spin;
    int spindir;

    override void PostBeginPlay() {
        Super.PostBeginPlay();
        spin = frandom(0,10);
        spindir = random(0,1) ? -1 : 1;
    }

    override void Tick() {
        super.Tick();
        if (spin > 0) {
            angle += spin * spindir;
            spin -= max(spin * 0.1,0.1);
        }
    }
}