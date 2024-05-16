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
