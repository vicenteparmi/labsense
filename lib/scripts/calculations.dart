/// Calculates the duration of the cyclic voltammetry experiment.
///
/// The formula is:
/// ```
/// duration = (finalP - initialP) / rate * count
/// ```
///
/// where:
/// - [initialP] is the initial potential, in V,
/// - [finalP] is the final potential, in V,
/// - [rate] is the voltage rate, in V/s,
/// - [count] is the number of cycles.
double calculateDuration(
    double initialP, double finalP, double rate, int count) {
  return (finalP.abs() + initialP.abs()) / rate * count;
}

/// Transform the given [potential] to a real voltage value.
double transformPotential(double potential) {
  return potential.toDouble() / 255 * 2 - 1;
}

/// Transform the given [current] to a real current value.
double transformCurrent(double current) {
  return current.toDouble() / 1023 * 5 * 12E3;
}
