export function calculatePrice(distanceKm) {
  const baseFare = 3;
  const perKm = 1.5;
  const total = baseFare + distanceKm * perKm;
  return Math.round(total * 100) / 100;
}
