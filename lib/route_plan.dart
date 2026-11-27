import 'dart:math' as math;

class RouteStop {
  const RouteStop(this.name, this.category, this.eastKm, this.northKm);

  final String name;
  final String category;
  final double eastKm;
  final double northKm;

  double distanceTo(RouteStop other) => math.sqrt(
    math.pow(eastKm - other.eastKm, 2) + math.pow(northKm - other.northKm, 2),
  );
}

const departure = RouteStop('Merter station', 'Start', 0.55, 0.67);

const sampleStops = [
  RouteStop('Atlas Fabrics', 'Fabric', 3.62, 2.02),
  RouteStop('Selin Trimmings', 'Haberdashery', 1.42, 1.05),
  RouteStop('Mavi Threads', 'Thread', 2.95, 0.68),
  RouteStop('Lotus Textiles', 'Fabric', 2.18, 1.97),
  RouteStop('Moda Fasteners', 'Hardware', 3.83, 1.14),
  RouteStop('Yildiz Buttons', 'Haberdashery', 0.97, 1.66),
];

List<RouteStop> initialStops() => sampleStops.take(3).toList();

double routeDistance(Iterable<RouteStop> stops) {
  var previous = departure;
  var distance = 0.0;
  for (final stop in stops) {
    distance += previous.distanceTo(stop);
    previous = stop;
  }
  return distance;
}

// The picker exposes six stops, so we can compare every order on-device.
// Keep the draft when its distance ties the best candidate.
List<RouteStop> shortestVisitOrder(List<RouteStop> stops) {
  var best = List.of(stops);
  var bestDistance = routeDistance(stops);

  void visit(
    RouteStop previous,
    List<RouteStop> remaining,
    List<RouteStop> order,
    double distance,
  ) {
    if (distance >= bestDistance) return;
    if (remaining.isEmpty) {
      best = List.of(order);
      bestDistance = distance;
      return;
    }

    for (final stop in remaining) {
      visit(stop, remaining.where((candidate) => candidate != stop).toList(), [
        ...order,
        stop,
      ], distance + previous.distanceTo(stop));
    }
  }

  visit(departure, stops, [], 0);
  return best;
}
