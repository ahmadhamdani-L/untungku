part of 'ads.dart';

enum RewardFeature {
  advancedReports('Laporan arus kas lanjutan'),
  insights('Asisten usaha'),
  calculator('Kalkulator harga'),
  csvImport('Impor produk CSV'),
  receiptCustomization('Personalisasi struk'),
  printerSettings('Pengaturan printer');

  final String label;
  const RewardFeature(this.label);
}

/// Process-only entitlement. No backup, financial record or consent is changed.
class RewardAccess extends ChangeNotifier {
  final DateTime Function() now;
  DateTime? until;
  Timer? _expiry;
  RewardAccess({DateTime Function()? clock}) : now = clock ?? DateTime.now;
  bool get unlocked => until != null && now().isBefore(until!);
  void earn() {
    until = now().add(const Duration(minutes: 30));
    _expiry?.cancel();
    _expiry = Timer(const Duration(minutes: 30), notifyListeners);
    notifyListeners();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }
}

final rewardAccess = RewardAccess();

Future<bool> confirmRewardAd(BuildContext context, String reward) async {
  final route = DialogRoute<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Tonton iklan untuk membuka?'),
      content: Text(
        '$reward\n\nSelesaikan satu iklan untuk memperoleh hadiah. Menutup iklan sebelum selesai tidak membuka akses. Anda boleh membatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(d, true),
          child: const Text('Tonton iklan'),
        ),
      ],
    ),
  );
  final confirmed = await Navigator.of(context).push(route) ?? false;
  await route.completed;
  return confirmed;
}

/// Authorizes entry once. Expiry must never interrupt an active import or print.
class RewardFeatureGate extends StatefulWidget {
  final RewardFeature feature;
  final WidgetBuilder builder;
  final RewardAccess? access;
  final bool fullPage;
  const RewardFeatureGate({
    super.key,
    required this.feature,
    required this.builder,
    this.access,
    this.fullPage = false,
  });
  @override
  State<RewardFeatureGate> createState() => _RewardFeatureGateState();
}

class _RewardFeatureGateState extends State<RewardFeatureGate> {
  late final RewardAccess access;
  late final PreparedPlacement placement;
  bool entered = false, busy = false;
  @override
  void initState() {
    super.initState();
    access = widget.access ?? rewardAccess;
    placement = PreparedPlacement(
      PreparedFormat.rewarded,
      onEarned: access.earn,
    );
    if (liveAdsEnabled && !access.unlocked) placement.start();
  }

  @override
  void dispose() {
    placement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([access, placement]),
    builder: (context, _) {
      if (!liveAdsEnabled || access.unlocked || entered) {
        entered = true;
        return widget.builder(context);
      }
      final locked = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                widget.feature.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Selesaikan satu iklan untuk membuka 6 fitur tambahan selama 30 menit pada sesi ini: ${RewardFeature.values.map((f) => f.label).join(', ')}. Akses berakhir saat aplikasi ditutup. Alat yang sudah dibuka tetap dapat diselesaikan. Pencatatan dasar, PIN, backup dan pemulihan tetap gratis.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.ondemand_video_outlined),
                label: Text(
                  placement.ready
                      ? 'Buka dengan iklan'
                      : placement.loading
                      ? 'Menyiapkan iklan…'
                      : 'Iklan belum tersedia',
                ),
                onPressed: busy || !placement.ready
                    ? null
                    : () async {
                        setState(() => busy = true);
                        final confirmed = await confirmRewardAd(
                          context,
                          'Buka semua 6 fitur tambahan selama 30 menit pada sesi ini.',
                        );
                        if (!mounted) return;
                        if (confirmed) {
                          final earned = await placement.show(
                            safe: () =>
                                mounted &&
                                ModalRoute.isCurrentOf(context) != false,
                          );
                          if (!mounted || !context.mounted) return;
                          if (!earned) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Iklan belum selesai atau tidak tersedia. Fitur belum dibuka.',
                                ),
                              ),
                            );
                          }
                        }
                        if (mounted) setState(() => busy = false);
                      },
              ),
              if (!placement.ready && !placement.loading)
                TextButton(
                  onPressed: () => unawaited(placement.prepare()),
                  child: const Text('Coba lagi'),
                ),
            ],
          ),
        ),
      );
      return widget.fullPage
          ? Scaffold(
              appBar: AppBar(title: Text(widget.feature.label)),
              body: locked,
            )
          : locked;
    },
  );
}
