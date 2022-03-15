import 'package:flutter/services.dart';

final numberRegexp = RegExp(r'(\d|\.)');
final numberFormatter = FilteringTextInputFormatter.allow(numberRegexp);
