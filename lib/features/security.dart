part of 'app.dart';

final pinProvider = Provider<PinController?>((ref) => null);

class SecurityGate extends StatefulWidget {
  final PinController controller;
  final Widget child;
  const SecurityGate({
    super.key,
    required this.controller,
    required this.child,
  });
  @override
  State<SecurityGate> createState() => _SecurityGateState();
}

class _SecurityGateState extends State<SecurityGate>
    with WidgetsBindingObserver {
  Timer? timer;
  TextEditingController? activeInput;
  PinController get security => widget.controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    security.addListener(changed);
    FocusManager.instance.addListener(inputFocusChanged);
    touch();
  }

  void inputFocusChanged() {
    activeInput?.removeListener(touch);
    final context = FocusManager.instance.primaryFocus?.context;
    final editable = context?.widget is EditableText
        ? context!.widget as EditableText
        : context?.findAncestorWidgetOfExactType<EditableText>();
    activeInput = editable?.controller;
    activeInput?.addListener(touch);
    touch();
  }

  void changed() {
    if (mounted) {
      setState(() {});
      touch();
    }
  }

  void touch() {
    timer?.cancel();
    if (security.enabled && !security.locked) {
      timer = Timer(Duration(seconds: security.timeoutSeconds), security.lock);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ([
      AppLifecycleState.inactive,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
    ].contains(state)) {
      timer?.cancel();
      security.lock();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    security.removeListener(changed);
    FocusManager.instance.removeListener(inputFocusChanged);
    activeInput?.removeListener(touch);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => touch(),
    child: Focus(
      onKeyEvent: (_, _) {
        touch();
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          Offstage(
            offstage: security.locked,
            child: ExcludeFocus(
              excluding: security.locked,
              child: widget.child,
            ),
          ),
          if (security.locked)
            Positioned.fill(
              child: HeroControllerScope.none(
                child: Navigator(
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => _PinUnlock(controller: security),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PinUnlock extends StatefulWidget {
  final PinController controller;
  const _PinUnlock({required this.controller});
  @override
  State<_PinUnlock> createState() => _PinUnlockState();
}

class _PinUnlockState extends State<_PinUnlock> {
  final pin = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const Text('Buka LabaRapi'),
                  TextField(
                    controller: pin,
                    obscureText: true,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'PIN'),
                  ),
                  if (error != null) Text(error!),
                  FilledButton(
                    onPressed: busy
                        ? null
                        : () async {
                            setState(() {
                              busy = true;
                              error = null;
                            });
                            final value = pin.text;
                            pin.clear();
                            try {
                              await widget.controller.unlock(value);
                            } catch (e) {
                              if (mounted) {
                                setState(
                                  () => error = e.toString().replaceFirst(
                                    'Invalid argument(s): ',
                                    '',
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => busy = false);
                              }
                            }
                          },
                    child: const Text('Buka'),
                  ),
                  const Text(
                    'PIN tidak dapat dipulihkan secara lokal. Tidak ada PIN pemulihan. Data tidak dihapus saat PIN salah. Gunakan backup eksternal untuk pemulihan di instalasi baru.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<String?> backupPassword(
  BuildContext context, {
  required bool confirmation,
}) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _BackupPasswordDialog(confirmation: confirmation),
);

class _BackupPasswordDialog extends StatefulWidget {
  final bool confirmation;
  const _BackupPasswordDialog({required this.confirmation});
  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final first = TextEditingController(), second = TextEditingController();
  String? error;
  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.confirmation ? 'Password backup baru' : 'Buka backup terenkripsi',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: first,
            obscureText: true,
            maxLength: 256,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Password (minimal 12 karakter)',
            ),
          ),
          if (widget.confirmation)
            TextField(
              controller: second,
              obscureText: true,
              maxLength: 256,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi password',
              ),
            ),
          const Text(
            'Simpan password di tempat aman. Password yang lupa tidak dapat dipulihkan.',
          ),
          if (error != null) Text(error!),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          if (first.text.length < 12 ||
              (widget.confirmation && first.text != second.text)) {
            setState(
              () => error =
                  'Password minimal 12 karakter dan konfirmasi harus sama.',
            );
            return;
          }
          Navigator.pop(context, first.text);
        },
        child: const Text('Lanjutkan'),
      ),
    ],
  );
}

class PinSettingsPage extends ConsumerStatefulWidget {
  const PinSettingsPage({super.key});
  @override
  ConsumerState<PinSettingsPage> createState() => _PinSettingsState();
}

class _PinSettingsState extends ConsumerState<PinSettingsPage> {
  final old = TextEditingController(),
      pin = TextEditingController(),
      confirmPin = TextEditingController();
  int timeout = 60;
  bool acknowledged = false, busy = false;
  @override
  void dispose() {
    old.dispose();
    pin.dispose();
    confirmPin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(pinProvider);
    if (controller == null) {
      return const Scaffold(
        body: Center(child: Text('Penyimpanan keamanan belum tersedia')),
      );
    }
    Future<void> configure(bool disable) => action(context, () async {
      if (busy) return;
      if (!disable && (!acknowledged || pin.text != confirmPin.text)) {
        throw ArgumentError(
          'Setujui kebijakan pemulihan dan samakan konfirmasi PIN',
        );
      }
      setState(() => busy = true);
      try {
        await controller.configure(
          old.text,
          disable ? null : pin.text,
          timeout: timeout,
        );
        old.clear();
        pin.clear();
        confirmPin.clear();
        if (context.mounted) Navigator.pop(context);
      } finally {
        if (mounted) setState(() => busy = false);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan PIN')),
      body: PageBody(
        children: [
          const Text(
            'PIN melindungi akses aplikasi, bukan mengenkripsi database. PIN tersimpan hanya sebagai verifikator pada penyimpanan aman Android. Backup JSON biasa dapat dibaca siapa pun yang memilikinya.',
          ),
          if (controller.enabled)
            TextField(
              controller: old,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN saat ini'),
            ),
          TextField(
            controller: pin,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN baru (4–6 digit)',
            ),
          ),
          TextField(
            controller: confirmPin,
            obscureText: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Konfirmasi PIN baru'),
          ),
          DropdownButtonFormField<int>(
            initialValue: timeout,
            decoration: const InputDecoration(
              labelText: 'Kunci setelah tidak aktif',
            ),
            items: const [
              DropdownMenuItem(value: 30, child: Text('30 detik')),
              DropdownMenuItem(value: 60, child: Text('1 menit')),
              DropdownMenuItem(value: 300, child: Text('5 menit')),
            ],
            onChanged: busy
                ? null
                : (value) => setState(() => timeout = value!),
          ),
          CheckboxListTile(
            value: acknowledged,
            onChanged: busy ? null : (v) => setState(() => acknowledged = v!),
            title: const Text(
              'Saya memahami PIN yang lupa tidak dapat dipulihkan. Saya telah menyimpan backup eksternal beserta passwordnya untuk instalasi baru. Tidak ada bypass atau penghapusan data otomatis.',
            ),
          ),
          FilledButton(
            onPressed: busy ? null : () => configure(false),
            child: const Text('Simpan PIN'),
          ),
          if (controller.enabled)
            OutlinedButton(
              onPressed: busy ? null : () => configure(true),
              child: const Text('Nonaktifkan PIN setelah verifikasi'),
            ),
        ],
      ),
    );
  }
}
