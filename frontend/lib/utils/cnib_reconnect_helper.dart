String resolveCnibUrl({
  required String? userValue,
  required String? initialValue,
  required String? persistedValue,
  String? currentValue,
}) {
  final normalizedUser = userValue?.trim() ?? '';
  if (normalizedUser.isNotEmpty) {
    return normalizedUser;
  }

  final normalizedInitial = initialValue?.trim() ?? '';
  if (normalizedInitial.isNotEmpty) {
    return normalizedInitial;
  }

  final normalizedCurrent = currentValue?.trim() ?? '';
  if (normalizedCurrent.isNotEmpty) {
    return normalizedCurrent;
  }

  return persistedValue?.trim() ?? '';
}
