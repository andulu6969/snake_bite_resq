import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:snake_bite_resq/models/hospital_model.dart';
import 'package:snake_bite_resq/widgets/gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalLocatorScreen extends StatefulWidget {
  const HospitalLocatorScreen({super.key});

  @override
  State<HospitalLocatorScreen> createState() => _HospitalLocatorScreenState();
}

class _HospitalLocatorScreenState extends State<HospitalLocatorScreen> {
  List<Hospital> _hospitals = List.from(Hospital.mockHospitals);
  List<Hospital> _filteredHospitals = List.from(Hospital.mockHospitals);
  final TextEditingController _searchController = TextEditingController();
  bool _locating = true;
  String _locationStatus = 'Getting location…';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _computeDistances();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  //  GPS + OSRM road-distance computation
  // --------------------------------------------------------------------------
  Future<void> _computeDistances() async {
    setState(() {
      _locating = true;
      _locationStatus = 'Getting location…';
    });

    try {
      // 1. Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locating = false;
          _locationStatus = 'Location permission denied';
        });
        return;
      }

      // 2. Get device position
      if (!mounted) return;
      setState(() => _locationStatus = 'Fetching road distances…');
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;

      // 3. Build OSRM Table API URL
      //    Format: {lng},{lat} for each point; index 0 = user, 1..N = hospitals
      final hospitals = Hospital.mockHospitals;
      final coords = StringBuffer();
      coords.write('${pos.longitude},${pos.latitude}'); // source (index 0)
      for (final h in hospitals) {
        coords.write(';${h.lng},${h.lat}');
      }

      final uri = Uri.parse(
        'http://router.project-osrm.org/table/v1/driving/$coords'
        '?sources=0&annotations=distance',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode != 200) {
        throw Exception('OSRM returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // distances[0] = [0.0, d_hosp0, d_hosp1, ...]  in metres
      final rawDistances = (data['distances'] as List).first as List;

      // 4. Zip distances with hospitals, build updated list
      final updated = <Hospital>[];
      for (int i = 0; i < hospitals.length; i++) {
        final metres = (rawDistances[i + 1] as num).toDouble();
        final km = metres / 1000;
        final label = km < 1
            ? '${metres.toStringAsFixed(0)} m (road)'
            : '${km.toStringAsFixed(1)} km (road)';
        updated.add(hospitals[i].withDistance(label));
      }

      // 5. Sort nearest-first
      updated.sort((a, b) {
        double parse(String d) {
          if (d == '— km') return double.maxFinite;
          return double.tryParse(
                RegExp(r'[\d.]+').firstMatch(d)?.group(0) ?? '0',
              ) ??
              0;
        }

        return parse(a.distance).compareTo(parse(b.distance));
      });

      setState(() {
        _hospitals = updated;
        _filteredHospitals = updated;
        _locating = false;
        _locationStatus = 'Sorted by road distance';
      });
    } on Exception catch (e) {
      debugPrint('Distance computation error: $e');
      // Fallback: straight-line haversine
      await _fallbackHaversine();
    }
  }

  Future<void> _fallbackHaversine() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (!mounted) return;
      final updated =
          Hospital.mockHospitals.map((h) {
            final metres = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              h.lat,
              h.lng,
            );
            final km = metres / 1000;
            return h.withDistance(
              km < 1
                  ? '${metres.toStringAsFixed(0)} m'
                  : '${km.toStringAsFixed(1)} km',
            );
          }).toList()..sort((a, b) {
            double parse(String d) {
              if (d == '— km') return double.maxFinite;
              return double.tryParse(
                    RegExp(r'[\d.]+').firstMatch(d)?.group(0) ?? '0',
                  ) ??
                  0;
            }

            return parse(a.distance).compareTo(parse(b.distance));
          });

      setState(() {
        _hospitals = updated;
        _filteredHospitals = updated;
        _locating = false;
        _locationStatus = 'Sorted by distance (offline est.)';
      });
    } catch (_) {
      setState(() {
        _locating = false;
        _locationStatus = 'Could not get location';
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHospitals = _hospitals.where((h) {
        return h.name.toLowerCase().contains(query) ||
            h.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --------------------------------------------------------------------------
  //  UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nearest Stockpiles',
                style: TextStyle(
                  color: Colors.blueGrey, // .shade900
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                _locationStatus,
                style: TextStyle(
                  color: _locating
                      ? Colors.orange.shade700
                      : Colors.blueGrey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.blueGrey.shade900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_locating)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue.shade700),
                onPressed: _computeDistances,
                tooltip: 'Refresh distances',
              ),
          ],
        ),
        body: Column(
          children: [
            // Glassmorphism search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blueGrey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.blueGrey.shade900),
                  decoration: InputDecoration(
                    hintText: 'Search hospital…',
                    hintStyle: TextStyle(
                      color: Colors.blueGrey.shade400,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: _filteredHospitals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildHospitalCard(_filteredHospitals[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital, int index) {
    final isNearest = index == 0 && !_locating && hospital.distance != '— km';
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hospital.hasAntivenom
                ? Colors.blue.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_hospital,
            color: hospital.hasAntivenom
                ? Colors.blue.shade700
                : Colors.red.shade700,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                hospital.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                  fontSize: 14,
                ),
              ),
            ),
            if (isNearest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'NEAREST',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.route, size: 14, color: Colors.blueGrey.shade400),
                const SizedBox(width: 4),
                Text(
                  hospital.distance,
                  style: TextStyle(
                    color: isNearest
                        ? Colors.blue.shade700
                        : Colors.blueGrey.shade600,
                    fontSize: 12,
                    fontWeight: isNearest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hospital.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hospital.hasAntivenom
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hospital.hasAntivenom ? 'IN STOCK' : 'NO STOCK',
                style: TextStyle(
                  color: hospital.hasAntivenom
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final uri = Uri.parse('tel:${hospital.phone}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              messenger.showSnackBar(
                SnackBar(content: Text('Cannot call ${hospital.name}')),
              );
            }
          },
          icon: Icon(Icons.phone, color: Colors.blue.shade700),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}
