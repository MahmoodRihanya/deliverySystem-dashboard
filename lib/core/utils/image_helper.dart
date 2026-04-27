import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageHelper {
  /// بناء الرابط الكامل للصورة من المسار النسبي
  static String? buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    
    // استخراج الدومين والـ IP من API_BASE_URL
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    
    // الحصول على الدومين الأساسي (بدون /api)
    // مثال: http://localhost:3000/api -> http://localhost:3000
    final domain = baseUrl.split('/api').first;
    
    // إذا كان الرابط كاملاً بالفعل، نرجعه كما هو
    if (path.startsWith('http')) {
      return path;
    }
    
    // التأكد من عدم تكرار /api إذا كان المسار يبدأ بـ /api
    if (path.startsWith('/api')) {
      return '$domain$path';
    }
    
    return '$domain/api$path';
  }
}
