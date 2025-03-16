// lib/views/widgets/loading_indicator.dart

import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;
  
  const LoadingIndicator({
    Key? key,
    this.message,
    this.overlay = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                message!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
    
    if (overlay) {
      return Stack(
        children: [
          const ModalBarrier(
            color: Colors.black54,
            dismissible: false,
          ),
          loadingWidget,
        ],
      );
    }
    
    return loadingWidget;
  }
}