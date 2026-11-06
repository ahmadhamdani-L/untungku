package id.untungku.untungku_pro

import android.Manifest
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val timer = Executors.newSingleThreadScheduledExecutor()
    private val printing = AtomicBoolean(false)
    @Volatile private var socket: BluetoothSocket? = null
    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "id.untungku/printer")
            .setMethodCallHandler { call, result ->
                if (call.method !in listOf("paired", "print")) { result.notImplemented(); return@setMethodCallHandler }
                if (Build.VERSION.SDK_INT >= 31 && checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                    if (permissionResult != null) { result.error("busy", "Permintaan izin sedang berlangsung", null) }
                    else { permissionResult = result; requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 804) }
                    return@setMethodCallHandler
                }
                handlePrinter(call, result)
            }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 804) {
            permissionResult?.error("permission", if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) "Izin diberikan. Muat ulang daftar printer." else "Izin Bluetooth ditolak. PDF tetap tersedia.", null)
            permissionResult = null
        }
    }

    @Suppress("MissingPermission")
    private fun handlePrinter(call: MethodCall, result: MethodChannel.Result) {
        try {
            val adapter = getSystemService(BluetoothManager::class.java)?.adapter
            if (adapter == null || !adapter.isEnabled) { result.error("bluetooth", "Bluetooth tidak tersedia atau belum aktif", null); return }
            if (call.method == "paired") {
                result.success(adapter.bondedDevices.sortedBy { it.address }.map { mapOf("name" to (it.name ?: "Printer"), "address" to it.address) })
                return
            }
            val address = call.argument<String>("address") ?: ""
            val bytes = call.argument<ByteArray>("bytes")
            val device = adapter.bondedDevices.firstOrNull { it.address == address }
            if (device == null || bytes == null || bytes.size > 1000000) { result.error("printer", "Printer belum dipasangkan atau data tidak valid", null); return }
            if (!printing.compareAndSet(false, true)) { result.error("busy", "Pencetakan masih berlangsung", null); return }
            worker.execute {
                var error: String? = null
                var current: BluetoothSocket? = null
                var timeout: java.util.concurrent.ScheduledFuture<*>? = null
                try {
                    current = device.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"))
                    socket = current
                    val boundedSocket = current
                    timeout = timer.schedule({ try { boundedSocket.close() } catch (_: Exception) {} }, 15, TimeUnit.SECONDS)
                    current.connect()
                    current.outputStream.write(bytes)
                    current.outputStream.flush()
                } catch (_: Exception) {
                    error = "Koneksi gagal/terputus atau printer tidak mendukung Bluetooth SPP ESC/POS. Sebagian struk mungkin sudah tercetak. Periksa sebelum mencoba ulang."
                } finally {
                    timeout?.cancel(false)
                    try { current?.close() } catch (_: Exception) {}
                    socket = null
                    printing.set(false)
                }
                val message = error
                runOnUiThread { if (message == null) result.success(null) else result.error("print_failed", message, null) }
            }
        } catch (_: Exception) { result.error("printer", "Bluetooth tidak dapat diakses. Periksa izin dan pasangan printer.", null) }
    }

    override fun onDestroy() {
        try { socket?.close() } catch (_: Exception) {}
        worker.shutdownNow()
        timer.shutdownNow()
        permissionResult?.error("closed", "Halaman ditutup", null)
        permissionResult = null
        super.onDestroy()
    }
}
