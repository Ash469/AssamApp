class ApplicationStatus {
  final String name;
  final String subtitle;
  final String status;
  final Map<String, String>? details;
  final List<StatusUpdate>? updates;

  ApplicationStatus({
    required this.name,
    required this.subtitle,
    required this.status,
    this.details,
    this.updates,
  });
}

class StatusUpdate {
  final String date;
  final String status;

  StatusUpdate({
    required this.date,
    required this.status,
  });
}
