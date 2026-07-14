const truckImages = [
  'assets/images/truck.png',
  'assets/images/truck1.png',
  'assets/images/truck2.png',
  'assets/images/truck3.png',
  'assets/images/truck4.png',
];

String truckImageFor(String seed) =>
    truckImages[seed.hashCode.abs() % truckImages.length];
