class Hospital {
  final String id;
  final String name;
  final String address;
  final String distance; // computed dynamically by HospitalLocatorScreen
  final bool hasAntivenom;
  final String phone;
  final double lat;
  final double lng;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.hasAntivenom,
    required this.phone,
    required this.lat,
    required this.lng,
  });

  /// Returns a copy with the distance string replaced.
  Hospital withDistance(String newDistance) => Hospital(
    id: id,
    name: name,
    address: address,
    distance: newDistance,
    hasAntivenom: hasAntivenom,
    phone: phone,
    lat: lat,
    lng: lng,
  );

  /// All 10 Kedah government hospitals with real coordinates.
  static const List<Hospital> mockHospitals = [
    Hospital(
      id: 'KDH-HSB',
      name: 'Hospital Sultanah Bahiyah',
      address: 'Km 6, Jalan Langgar, 05460 Alor Setar, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-740 6233',
      lat: 6.1287,
      lng: 100.3753,
    ),
    Hospital(
      id: 'KDH-HSAH',
      name: 'Hospital Sultan Abdul Halim',
      address: 'Jalan Langgar, 08000 Sungai Petani, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-423 5333',
      lat: 5.6497,
      lng: 100.4902,
    ),
    Hospital(
      id: 'KDH-HKU',
      name: 'Hospital Kulim',
      address: 'Jalan Pegawai, 09000 Kulim, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-490 1333',
      lat: 5.3600,
      lng: 100.5587,
    ),
    Hospital(
      id: 'KDH-HJT',
      name: 'Hospital Jitra',
      address: 'Jalan Changlun, 06000 Jitra, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-917 1400',
      lat: 6.2731,
      lng: 100.4239,
    ),
    Hospital(
      id: 'KDH-HSM',
      name: 'Hospital Sultanah Maliha',
      address: 'Jalan Bukit Tangga, 07000 Langkawi, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-966 3333',
      lat: 6.3300,
      lng: 99.8178,
    ),
    Hospital(
      id: 'KDH-HBA',
      name: 'Hospital Baling',
      address: 'Jalan Hospital, 09100 Baling, Kedah',
      distance: '— km',
      hasAntivenom: true,
      phone: '04-470 1333',
      lat: 5.6786,
      lng: 100.9193,
    ),
    Hospital(
      id: 'KDH-HSI',
      name: 'Hospital Sik',
      address: 'Jalan Hospital, 08200 Sik, Kedah',
      distance: '— km',
      hasAntivenom: false,
      phone: '04-469 5000',
      lat: 5.8083,
      lng: 100.7317,
    ),
    Hospital(
      id: 'KDH-HYN',
      name: 'Hospital Yan',
      address: 'Jalan Pantai, 06800 Yan, Kedah',
      distance: '— km',
      hasAntivenom: false,
      phone: '04-785 1333',
      lat: 5.7906,
      lng: 100.3869,
    ),
    Hospital(
      id: 'KDH-HKN',
      name: 'Hospital Kuala Nerang',
      address: 'Jalan Hospital, 06300 Kuala Nerang, Kedah',
      distance: '— km',
      hasAntivenom: false,
      phone: '04-786 6200',
      lat: 6.2551,
      lng: 100.6172,
    ),
    Hospital(
      id: 'KDH-HPD',
      name: 'Hospital Pendang',
      address: 'Jalan Hospital, 06700 Pendang, Kedah',
      distance: '— km',
      hasAntivenom: false,
      phone: '04-759 1333',
      lat: 5.9956,
      lng: 100.4756,
    ),
  ];
}
