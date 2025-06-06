
enum KeretaStatus {
  willArrive,
  onRoute,
  finished,
}

class Kereta {
  final String kode;
  final String nama;
  final String fromStasiun;
  final String toStasiun;
  final String jadwal;
  final KeretaStatus status;
  final String? arrivalCountdown;
  final List<StasiunRoute> route;
  final List<Gerbong> gerbongs;

  const Kereta({
    required this.kode,
    required this.nama,
    required this.fromStasiun,
    required this.toStasiun,
    required this.jadwal,
    required this.status,
    this.arrivalCountdown,
    required this.route,
    required this.gerbongs,
  });

  Kereta copyWith({
    String? kode,
    String? nama,
    String? fromStasiun,
    String? toStasiun,
    String? jadwal,
    KeretaStatus? status,
    String? arrivalCountdown,
    List<StasiunRoute>? route,
    List<Gerbong>? gerbongs,
  }) {
    return Kereta(
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      fromStasiun: fromStasiun ?? this.fromStasiun,
      toStasiun: toStasiun ?? this.toStasiun,
      jadwal: jadwal ?? this.jadwal,
      status: status ?? this.status,
      arrivalCountdown: arrivalCountdown ?? this.arrivalCountdown,
      route: route ?? this.route,
      gerbongs: gerbongs ?? this.gerbongs,
    );
  }
}

class StasiunRoute {
  final String nama;
  final String waktu;
  final bool isPassed;
  final bool isActive;

  const StasiunRoute({
    required this.nama,
    required this.waktu,
    this.isPassed = false,
    this.isActive = false,
  });
}

class Gerbong {
  final String kode;
  final String tipe;
  final int kapasitas;
  final int terisi;

  const Gerbong({
    required this.kode,
    required this.tipe,
    required this.kapasitas,
    required this.terisi,
  });
}