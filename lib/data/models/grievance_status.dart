enum GrievanceStatus {
  submitted,
  acknowledged,
  inProgress,
  resolved,
  closed,
  rejected,
  draft,
  processing,
}

GrievanceStatus parseGrievanceStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'submitted':
      return GrievanceStatus.submitted;
    case 'acknowledged':
      return GrievanceStatus.acknowledged;
    case 'in progress':
      return GrievanceStatus.inProgress;
    case 'resolved':
      return GrievanceStatus.resolved;
    case 'closed':
      return GrievanceStatus.closed;
    case 'rejected':
      return GrievanceStatus.rejected;
    case 'draft':
      return GrievanceStatus.draft;
    case 'processing':
      return GrievanceStatus.processing;
    default:
      return GrievanceStatus.submitted;
  }
}

