import 'package:intl/intl.dart';

class Review {
  final String id;
  final String author;
  final String content;
  final DateTime? createdAt;
  final double? rating;
  final String? authorAvatarPath;
  
  Review({
    required this.id,
    required this.author,
    required this.content,
    this.createdAt,
    this.rating,
    this.authorAvatarPath,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']);
      } catch (e) {
        print('Error parsing date: ${json['created_at']}');
      }
    }
    
    return Review(
      id: json['id'].toString(),
      author: json['author'],
      content: json['content'],
      createdAt: parsedDate,
      rating: json['author_details']?['rating']?.toDouble(),
      authorAvatarPath: json['author_details']?['avatar_path'],
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      }
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    
    // Always show the full date with year
    return DateFormat('MMMM d, y').format(createdAt!);
  }

  String? get fullAvatarPath {
    if (authorAvatarPath == null) return null;
    if (authorAvatarPath!.startsWith('/http')) {
      return authorAvatarPath!.substring(1);
    }
    return 'https://image.tmdb.org/t/p/w100_and_h100_face$authorAvatarPath';
  }
}