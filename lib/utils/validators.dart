String? validateMaxLengthDigits(String? value, int maxLen) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length > maxLen) {
    return 'Must be at most $maxLen digits';
  }
  return null;
}

String? validateExactDigits(String? value, int len) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length != len) {
    return 'Must be exactly $len digits';
  }
  return null;
}

String? validateMinLength(String? value, int minLen, {String? emptyMsg}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) {
    return emptyMsg;
  }
  return v.length < minLen ? 'Minimum $minLen characters' : null;
}

String? validateOnlyLettersAndSpaces(
  String? value, {
  int minLen = 1,
  int? maxLen,
}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;

  if (v.length < minLen) return 'Too short';
  if (maxLen != null && v.length > maxLen) return 'Too long';

  final ok = RegExp(r'^[a-zA-Z ]+$').hasMatch(v);
  return ok ? null : 'Use letters and spaces only';
}
