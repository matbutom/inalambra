import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

enum EstadoOsc { inactivo, listo, error }

class OscMessage {
  final String address;
  final List<dynamic> arguments;

  OscMessage(this.address, this.arguments);

  // Serializa el mensaje según spec OSC 1.0
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // 1. Address string: null-terminated, padding a múltiplo de 4 bytes
    buffer.add(_padString(address));

    // 2. Type tag string: empieza con ",", un char por argumento,
    //    null-terminated, paddeado a 4 bytes
    final typeTags = StringBuffer(',');
    for (final arg in arguments) {
      if (arg is int) {
        typeTags.write('i');
      } else if (arg is double) {
        typeTags.write('f');
      } else {
        typeTags.write('s');
      }
    }
    buffer.add(_padString(typeTags.toString()));

    // 3. Argumentos: big-endian, 4 bytes int/float, strings paddeados
    for (final arg in arguments) {
      if (arg is int) {
        final bytes = ByteData(4);
        bytes.setInt32(0, arg, Endian.big);
        buffer.add(bytes.buffer.asUint8List());
      } else if (arg is double) {
        final bytes = ByteData(4);
        bytes.setFloat32(0, arg, Endian.big);
        buffer.add(bytes.buffer.asUint8List());
      } else {
        buffer.add(_padString(arg.toString()));
      }
    }

    return buffer.toBytes();
  }

  factory OscMessage.fromBytes(Uint8List bytes) {
    int offset = 0;

    String readString() {
      final start = offset;
      while (offset < bytes.length && bytes[offset] != 0) {
        offset++;
      }
      final s = String.fromCharCodes(bytes.sublist(start, offset));
      offset++; // saltar null terminator
      offset = ((offset + 3) ~/ 4) * 4; // alinear a 4 bytes
      return s;
    }

    final address = readString();
    final typeTags = readString();

    final arguments = <dynamic>[];
    // typeTags[0] == ',' — se itera desde índice 1
    for (int i = 1; i < typeTags.length; i++) {
      final tag = typeTags[i];
      if (tag == 'i') {
        final data = ByteData.sublistView(bytes, offset, offset + 4);
        arguments.add(data.getInt32(0, Endian.big));
        offset += 4;
      } else if (tag == 'f') {
        final data = ByteData.sublistView(bytes, offset, offset + 4);
        arguments.add(data.getFloat32(0, Endian.big));
        offset += 4;
      } else if (tag == 's') {
        arguments.add(readString());
      }
      // OSC: otros tipos de tags (b, T, F, etc.) no implementados en esta versión
    }

    return OscMessage(address, arguments);
  }

  // String padding: null-terminated, alineado a múltiplo de 4 bytes
  static Uint8List _padString(String s) {
    final encoded = Uint8List.fromList([...s.codeUnits, 0]);
    final paddedLength = ((encoded.length + 3) ~/ 4) * 4;
    final result = Uint8List(paddedLength);
    result.setRange(0, encoded.length, encoded);
    return result;
  }

  @override
  String toString() => 'OscMessage($address, $arguments)';
}

class OscService {
  final String remoteHost;
  final int remotePort;
  final int localPort;

  RawDatagramSocket? _socket;
  final _controller = StreamController<OscMessage>.broadcast();

  // OSC: sin conexión persistente — UDP es sin estado.
  // "listo" significa que el socket está abierto, no que hay sesión activa.
  Stream<OscMessage> get messages => _controller.stream;

  OscService({
    required this.remoteHost,
    required this.remotePort,
    required this.localPort,
  });

  // Abre el socket UDP. No hay handshake ni broker.
  Future<void> init() async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      localPort,
    );
    _socket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket!.receive();
        if (datagram != null) {
          try {
            final msg = OscMessage.fromBytes(datagram.data);
            _controller.add(msg);
          } catch (_) {
            // ignorar paquetes malformados
          }
        }
      }
    });
  }

  void send(OscMessage msg) {
    if (_socket == null) return;
    final bytes = msg.toBytes();
    _socket!.send(bytes, InternetAddress(remoteHost), remotePort);
  }

  void dispose() {
    _socket?.close();
    _socket = null;
    _controller.close();
  }
}
