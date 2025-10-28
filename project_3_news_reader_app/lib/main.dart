import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
    );
  }
}

/// Model Article
class Article {
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? sourceName;

  Article({
    required this.title,
    this.author,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No title',
      author: json['author'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      content: json['content'],
      sourceName: json['source'] != null ? json['source']['name'] : null,
    );
  }
}

/// Service to fetch from NewsAPI.org
class NewsApiService {
  // TODO: đặt API key của bạn ở đây
  static const String _apiKey = 'fc2421bd523a4bf8937d0306ba0cde86';

  // Ví dụ lấy top headlines (có thể đổi country=vn hoặc q=keyword)
  Future<List<Article>> fetchTopHeadlines({String country = 'us'}) async {
    final uri = Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=$country&pageSize=30&apiKey=$_apiKey',
    );

    final resp = await http.get(uri).timeout(const Duration(seconds: 15));

    if (resp.statusCode == 200) {
      final jsonBody = jsonDecode(resp.body);
      if (jsonBody['status'] == 'ok') {
        final List items = jsonBody['articles'] as List;
        return items.map((e) => Article.fromJson(e)).toList();
      } else {
        throw Exception('API error: ${jsonBody['message'] ?? 'unknown'}');
      }
    } else {
      throw Exception('Network error: ${resp.statusCode}');
    }
  }
}

/// Home page shows list of articles using FutureBuilder
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsApiService _service = NewsApiService();
  late Future<List<Article>> _futureArticles;
  String _country = 'us';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureArticles = _service.fetchTopHeadlines(country: _country);
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
    await _futureArticles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Reader'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                _country = val;
                _load();
              });
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'us', child: Text('US')),
              PopupMenuItem(value: 'gb', child: Text('UK')),
              PopupMenuItem(value: 'vn', child: Text('Vietnam')),
              PopupMenuItem(value: 'jp', child: Text('Japan')),
            ],
            icon: const Icon(Icons.public),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Article>>(
          future: _futureArticles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading indicator
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Error handling UI
              return ListView(
                // ListView để RefreshIndicator vẫn hoạt động
                children: [
                  SizedBox(height: 120),
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Lỗi khi tải tin: ${snapshot.error}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _load();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Không có bài viết nào',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            } else {
              final articles = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: articles.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final a = articles[index];
                  return ListTile(
                    leading: a.urlToImage != null
                        ? SizedBox(
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                a.urlToImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          )
                        : const SizedBox(
                            width: 100,
                            child: Icon(Icons.image, size: 48),
                          ),
                    title: Text(
                      a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${a.sourceName ?? 'Unknown'} • ${a.publishedAt != null ? _formatDate(a.publishedAt!) : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetail(article: a),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    // Simple format: YYYY-MM-DD HH:MM
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

/// Detail page
class ArticleDetail extends StatelessWidget {
  final Article article;
  const ArticleDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName ?? 'Article'),
        actions: [
          if (article.url != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _openUrl(article.url!, context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (article.urlToImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.urlToImage!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 200,
                  child: Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            article.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (article.author != null) Text('By ${article.author}  •  '),
              if (article.publishedAt != null)
                Text(_formatDate(article.publishedAt!)),
            ],
          ),
          const SizedBox(height: 12),
          if (article.description != null) Text(article.description!),
          const SizedBox(height: 12),
          if (article.content != null) Text(article.content!),
          const SizedBox(height: 20),
          if (article.url != null)
            ElevatedButton.icon(
              onPressed: () => _openUrl(article.url!, context),
              icon: const Icon(Icons.link),
              label: const Text('Mở trang gốc'),
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _openUrl(String? url, BuildContext context) async {
    if (url == null || !url.startsWith('http')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL bài báo không hợp lệ')));
      return;
    }

    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở URL (trình duyệt không hỗ trợ)'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi mở URL: $e')));
    }
  }
}
