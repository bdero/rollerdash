import 'package:flutter/material.dart';

class RollerChip extends StatelessWidget {
  const RollerChip(
      {Key? key, required this.label, this.avatar, this.backgroundColor})
      : super(key: key);

  final Widget? avatar;
  final Widget label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      avatar: avatar,
      label: label,
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
    );
  }
}

class RollStatusChip extends StatelessWidget {
  const RollStatusChip({Key? key, required this.status}) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color backgroundColor;
    Widget avatar;
    switch (status) {
      case 'IN_PROGRESS':
        statusText = 'In Progress';
        backgroundColor = Colors.yellow;
        avatar = const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 3,
          ),
        );
        break;
      case 'SUCCESS':
        statusText = 'Success';
        backgroundColor = Colors.green;
        avatar = const Icon(
          Icons.check_outlined,
          color: Colors.black,
        );
        break;
      default: // FAILURE
        statusText = 'Failure';
        backgroundColor = Colors.red;
        avatar = const Icon(
          Icons.error_outline,
          color: Colors.black,
        );
        break;
    }

    return RollerChip(
      avatar: avatar,
      label: Text(
        statusText,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

class RollModeChip extends StatelessWidget {
  const RollModeChip({Key? key, required this.mode}) : super(key: key);

  final String mode;

  @override
  Widget build(BuildContext context) {
    String modeText;
    Color backgroundColor;
    IconData icon;
    switch (mode) {
      case 'RUNNING':
        modeText = 'Running';
        backgroundColor = Colors.green;
        icon = Icons.play_arrow;
        break;
      default: // STOPPED
        modeText = 'Paused';
        backgroundColor = Colors.orange;
        icon = Icons.pause_outlined;
        break;
    }

    return RollerChip(
      avatar: Icon(
        icon,
        color: Colors.black,
      ),
      label: Text(
        modeText,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
