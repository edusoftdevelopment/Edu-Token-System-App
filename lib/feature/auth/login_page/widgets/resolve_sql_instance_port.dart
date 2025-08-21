import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class ResolveSqlInstancePort {
   /// Resolve named SQL Server instance to TCP port using SQL Browser (UDP 1434).
  /// Returns port as int on success, or null on failure/timeout.
  Future<int?> resolveSqlInstancePort({
    required String host,
    required String instanceName,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    RawDatagramSocket? socket;
    Timer? watchdog;

    try {
      // Create UDP socket
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.readEventsEnabled = true;

      // SQL Server Browser service request format:
      // 0x02 for instance enumeration
      final request = Uint8List.fromList([0x02]);

      final completer = Completer<int?>();
      final buffer = StringBuffer();
      var receivedData = false;

      // Setup timeout
      watchdog = Timer(timeout, () {
        if (!completer.isCompleted) {
          log('SQL Browser timeout after ${timeout.inSeconds}s' as num);
          completer.complete(null);
        }
      });

      // Listen for responses
      socket.listen(
        (event) {
          if (event == RawSocketEvent.read) {
            final datagram = socket?.receive();
            if (datagram == null) return;

            receivedData = true;
            try {
              // Append response to buffer
              buffer.write(utf8.decode(datagram.data, allowMalformed: true));

              // Parse complete response
              final response = buffer.toString();
              log('SQL Browser raw response: $response' as num);

              // Extract instance info
              final instances = response.split(';;');
              for (final instance in instances) {
                if (instance.toLowerCase().contains(
                  instanceName.toLowerCase(),
                )) {
                  // Parse instance details
                  final details = instance.split(';');
                  for (var i = 0; i < details.length; i++) {
                    if (details[i].toLowerCase() == 'tcp') {
                      if (i + 1 < details.length) {
                        final port = int.tryParse(details[i + 1]);
                        if (port != null && !completer.isCompleted) {
                          log('Found instance $instanceName on port $port' as num);
                          completer.complete(port);
                          return;
                        }
                      }
                    }
                  }
                }
              }
            } catch (e) {
              log('Error parsing SQL Browser response: $e' as num);
            }
          }
        },
        onError: (e) {
          log('Socket error: $e' as num);
          if (!completer.isCompleted) completer.complete(null);
        },
        cancelOnError: true,
      );

      // Send request to SQL Browser service
      log('Querying SQL Browser on $host:1434 for instance $instanceName' as num);
      socket.send(request, InternetAddress(host), 1434);

      // Wait for response
      final port = await completer.future;

      // Log outcome
      if (!receivedData) {
        log('No response from SQL Browser service' as num);
      } else if (port == null) {
        log('Instance $instanceName not found in response' as num);
      }

      return port;
    } catch (e) {
      log('SQL Browser resolution failed: $e' as num);
      return null;
    } finally {
      watchdog?.cancel();
      socket?.close();
    }
  }
}