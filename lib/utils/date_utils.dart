import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
}

String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

String getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else {
    return formatDate(dateTime);
  }
}

int calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;
  
  if (today.month < birthDate.month || 
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  
  return age;
}

int calculateYearsOfService(DateTime enlistmentDate) {
  final today = DateTime.now();
  int years = today.year - enlistmentDate.year;
  
  if (today.month < enlistmentDate.month || 
      (today.month == enlistmentDate.month && today.day < enlistmentDate.day)) {
    years--;
  }
  
  return years;
}
