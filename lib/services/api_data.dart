List<Map<String, dynamic>> dataList(Map<String, dynamic> response) {
  final data = response['data'];
  final source = data is Map<String, dynamic> && data['data'] is List
      ? data['data']
      : data;

  if (source is List) {
    return source.whereType<Map<String, dynamic>>().toList();
  }

  return const [];
}

Map<String, dynamic> dataMap(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is Map<String, dynamic>) return data;
  return response;
}
