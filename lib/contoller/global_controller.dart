import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackbarController errorSnackBar(String msg) {
  return Get.snackbar(
    "Failed",
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    barBlur: 0,
    icon: const Icon(
      Icons.error,
      color: Colors.white,
    ),
    colorText: Colors.white,
    progressIndicatorBackgroundColor: Colors.white,
  );
}

SnackbarController successSnackBar(String msg) {
  return Get.snackbar(
    "Success",
    msg,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    barBlur: 0,
    icon: const Icon(
      Icons.error,
      color: Colors.white,
    ),
    colorText: Colors.white,
    progressIndicatorBackgroundColor: Colors.white,
  );
}
