import 'dart:math';

import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/modules/terminal/controllers/terminal_controller.dart';
import 'package:get/get.dart';

class TerminalSession {
  int id;
  ContainerInfo container;
  TerminalController controller;

  TerminalSession({
    required this.id,
    required this.container,
    required this.controller,
  });
}

class TerminalSessionController extends GetxController {
  final RxMap<int, TerminalSession> sessions = <int, TerminalSession>{}.obs;

  TerminalSession getOrCreateSession(ContainerInfo container) {
    // Find existing session for this container
    final existingSession = sessions.values.firstWhere(
      (session) => session.container.name == container.name,
      orElse: () => _createNewSession(container),
    );

    return existingSession;
  }

  List<TerminalSession> getSessionsOfContainer(ContainerInfo container) {
    return sessions.values
        .where((session) => session.container.name == container.name)
        .toList();
  }

  Future<void> removeTerminal(int id) async {
    final session = sessions.remove(id);
    if (session != null) {
      await session.controller.disposeTerm();
      session.controller.onClose();
    }
  }

  TerminalSession _createNewSession(ContainerInfo container) {
    // Generate a unique ID for this session
    final id = _generateUniqueId();

    // Create and initialize the terminal controller
    final terminalController = TerminalController();
    terminalController.closeOnPageClose.value = false;
    terminalController.onInit();

    // Set the container name for the terminal controller
    terminalController.containerName.value = container.name;

    // Create the session
    final session = TerminalSession(
      id: id,
      container: container,
      controller: terminalController,
    );

    // Store the session
    sessions[id] = session;

    return session;
  }

  int _generateUniqueId() {
    final random = Random.secure();
    int id;
    do {
      id = random.nextInt(256);
    } while (sessions.containsKey(id));
    return id;
  }
}
