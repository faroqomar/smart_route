import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'route_map.dart';
import 'route_plan.dart';

const _paper = Color(0xfff7f6ef);
const _ink = Color(0xff202b23);
const _muted = Color(0xff575f51);
const _line = Color(0xffdedfd1);
const _green = Color(0xff263d2c);
const _lime = Color(0xffd2f579);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Route',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          primary: _green,
          surface: _paper,
          onSurface: _ink,
        ),
        scaffoldBackgroundColor: _paper,
        dividerColor: _line,
      ),
      home: const RoutePlanner(),
    );
  }
}

class RoutePlanner extends StatefulWidget {
  const RoutePlanner({super.key});

  @override
  State<RoutePlanner> createState() => _RoutePlannerState();
}

class _RoutePlannerState extends State<RoutePlanner> {
  List<RouteStop> _draft = initialStops();
  List<RouteStop>? _optimized;

  List<RouteStop> get _stops => _optimized ?? _draft;

  Future<void> _chooseStops() async {
    final chosen = await showModalBottomSheet<List<RouteStop>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _paper,
      builder: (_) => _StopPicker(stops: _stops),
    );
    if (!mounted || chosen == null || listEquals(chosen, _stops)) return;
    setState(() {
      _draft = chosen;
      _optimized = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final optimized = _optimized != null;
    final distance = routeDistance(_stops);
    final saved = routeDistance(_draft) - distance;

    final overview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RouteMap(stops: _stops),
        const SizedBox(height: 12),
        _RouteSummary(
          count: _stops.length,
          distance: distance,
          optimized: optimized,
          saved: saved,
        ),
      ],
    );
    final itinerary = _Itinerary(stops: _stops, onChoose: _chooseStops);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    const SizedBox(height: 22),
                    const Text(
                      'Plan your route',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 36,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A sample wholesale shopping trip in Merter.',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 760) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              overview,
                              const SizedBox(height: 19),
                              itinerary,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: overview),
                            const SizedBox(width: 26),
                            Expanded(flex: 4, child: itinerary),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: _paper,
            border: Border(top: BorderSide(color: _line)),
          ),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: SizedBox(
                  width: double.infinity,
                  child: optimized
                      ? OutlinedButton.icon(
                          onPressed: () => setState(() => _optimized = null),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            side: const BorderSide(color: _green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(Icons.undo_rounded, size: 20),
                          label: const Text('Restore original order'),
                        )
                      : FilledButton.icon(
                          onPressed: _draft.length < 2
                              ? null
                              : () => setState(
                                  () => _optimized = shortestVisitOrder(_draft),
                                ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            backgroundColor: _green,
                            foregroundColor: _lime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(Icons.route_rounded, size: 22),
                          label: const Text(
                            'Optimize route',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: SizedBox.square(
            dimension: 38,
            child: Icon(Icons.route_rounded, color: _lime, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Smart Route',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -.6,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xffecefdf),
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              'SAMPLE DATA',
              style: TextStyle(
                color: _green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({
    required this.count,
    required this.distance,
    required this.optimized,
    required this.saved,
  });

  final int count;
  final double distance;
  final bool optimized;
  final double saved;

  @override
  Widget build(BuildContext context) {
    final status = optimized ? 'Optimized' : 'Draft';
    final detail = !optimized
        ? 'Visit order'
        : saved < .05
        ? 'Already shortest'
        : '${saved.toStringAsFixed(1)} km shorter';

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          '$count stops. ${distance.toStringAsFixed(1)} kilometers '
          'straight-line distance. $status. $detail.',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffeeefe6),
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: _Metric(value: '$count', label: 'Stops'),
              ),
              const SizedBox(height: 29, child: VerticalDivider(width: 1)),
              Expanded(
                flex: 2,
                child: _Metric(
                  value: '${distance.toStringAsFixed(1)} km',
                  label: 'Straight-line distance',
                ),
              ),
              const SizedBox(height: 29, child: VerticalDivider(width: 1)),
              Expanded(
                flex: 2,
                child: _Metric(value: status, label: detail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -.25,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: _muted, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _Itinerary extends StatelessWidget {
  const _Itinerary({required this.stops, required this.onChoose});

  final List<RouteStop> stops;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your stops',
                style: TextStyle(
                  fontSize: 23,
                  height: 1.1,
                  letterSpacing: -.65,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onChoose,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: const Color(0xffecefdf),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Choose stops'),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Row(
          children: [
            Icon(Icons.my_location_rounded, size: 14, color: _muted),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Start at Merter station',
                style: TextStyle(fontSize: 13, color: _muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        if (stops.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Choose at least two stops to compare visit orders.',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          )
        else
          for (var i = 0; i < stops.length; i++) ...[
            const Divider(height: 1, thickness: 1),
            _StopRow(
              stop: stops[i],
              number: i + 1,
              previous: i == 0 ? departure : stops[i - 1],
            ),
          ],
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.stop,
    required this.number,
    required this.previous,
  });

  final RouteStop stop;
  final int number;
  final RouteStop previous;

  @override
  Widget build(BuildContext context) {
    final distance = previous.distanceTo(stop).toStringAsFixed(1);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label:
          'Stop $number, ${stop.name}, ${stop.category}, '
          '$distance kilometers from ${previous.name}.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xffe8ebdc),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    stop.category,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$distance km',
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopPicker extends StatefulWidget {
  const _StopPicker({required this.stops});

  final List<RouteStop> stops;

  @override
  State<_StopPicker> createState() => _StopPickerState();
}

class _StopPickerState extends State<_StopPicker> {
  late final _selected = widget.stops.toSet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose stops',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the sample shops you want to visit.',
            style: TextStyle(color: _muted),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final stop in sampleStops)
                  CheckboxListTile(
                    title: Text(stop.name),
                    subtitle: Text(stop.category),
                    value: _selected.contains(stop),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(stop);
                      } else {
                        _selected.remove(stop);
                      }
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => Navigator.pop(context, _selected.toList()),
            child: Text('Apply stops (${_selected.length})'),
          ),
        ],
      ),
    );
  }
}
