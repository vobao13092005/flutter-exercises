import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Profile',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            Row(
              children: [
                const Icon(Icons.dark_mode),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/300', // Ảnh đại diện mẫu
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bao Vo',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Flutter Developer | UI Designer',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),

                      // Thông tin cá nhân
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: const Text('baovo@example.com'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: const Text('+84 123 456 789'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Location'),
                          subtitle: const Text('Da Nang, Viet Nam'),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      // Kỹ năng
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          Chip(label: Text('Flutter')),
                          Chip(label: Text('Dart')),
                          Chip(label: Text('Firebase')),
                          Chip(label: Text('UI/UX Design')),
                          Chip(label: Text('Git')),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      // Liên kết mạng xã hội
                      const Text(
                        'Social Links',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.facebook),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.linked_camera), // demo
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.web),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
