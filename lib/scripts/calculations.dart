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
/// - [startP] is the starting potential, in V,
/// - [rate] is the voltage rate, in V/s,
/// - [count] is the number of cycles.
/// - [type] is the type of the experiment, which can be either 'cyclic_voltammetry' or 'chronoamperometry'.
double calculateDuration(double initialP, double finalP, double startP,
    double rate, int count, String type) {
  if (type == 'cyclic_voltammetry') {
    return (finalP.abs() + initialP.abs()) / rate * count * 2;
  } else {
    return (finalP.abs() + initialP.abs()) / rate * count;
  }
}

/// Transform the given [potential] to a real voltage value.
double transformPotential(double potential) {
  return potential.toDouble() / 255 * 2 - 1;
}

/// Transform the given [current] to a real current value.
/// As we need to get the [slope] and [intercept] values from the calibration
/// settings, we need to pass them as arguments.
double transformCurrent(double current, double slope, double intercept) {
  return slope * current + intercept;
}
