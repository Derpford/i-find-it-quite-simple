mixin class WeightedRandom {
    int WeightedRandom(Array<Double> weights) {
        double sum;
        for (int i = 0; i < weights.size(); i++) {
            sum += weights[i];
        }

        // And now we roll.
        double roll = frandom(0,sum);
        for (int i = 0; i < weights.size(); i++) {
            if (roll < weights[i]) {
                return i;
            } else {
                roll -= weights[i];
            }
        }
        // If we reach this point, something went wrong.
        return -1;
    }
}