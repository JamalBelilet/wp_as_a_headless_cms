import 'dart:convert';

import 'package:http/http.dart' as http;

const baseUrl =
    'https://public-api.wordpress.com/wp/v2/sites/en.blog.wordpress.com';

class Post {
  final int id;
  final String excerpt;
  final String title;
  final String link;

  const Post({
    required this.id,
    required this.excerpt,
    required this.title,
    required this.link,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      excerpt: json['excerpt']['rendered'],
      title: json['title']['rendered'],
      link: json['link'],
    );
  }
}

Future<List<Post>> getPosts([limit = 10]) async {
  final response = await http.get(Uri.parse(
      '${baseUrl}/posts?per_page=10&_fields=author,id,excerpt,title,link'));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as List;
    final List<Post> posts =
        json.map((postJson) => Post.fromJson(postJson)).toList();

    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
}

// For more check https://developer.wordpress.org/rest-api/reference/posts/