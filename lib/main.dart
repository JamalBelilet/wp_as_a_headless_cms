import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wp_as_a_headless_cms/posts_repository.dart';

void main() {
  runApp(const WpAsAHeadlessCmsApp());
}

class WpAsAHeadlessCmsApp extends StatelessWidget {
  const WpAsAHeadlessCmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Wp as a headless cms',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansGeorgianTextTheme(textTheme),
      ),
      home: const PostsPage(title: 'Wordpress.com as a Headless CMS'),
    );
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key, required this.title});

  final String title;

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<List<Post>> futurePosts = getPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];

                return InkWell(
                  onTap: () async {
                    if (!await launchUrlString(post.link)) {
                      throw Exception('Could not launch ${post.link}');
                    }
                  },
                  child: Container(
                    color: index % 2 == 1
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : null,
                    child: Column(
                      children: [
                        Html(data: '<h2>${post.title}</h2>'),
                        Html(data: post.excerpt),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                '❗️ ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
