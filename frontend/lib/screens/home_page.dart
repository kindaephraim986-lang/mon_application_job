import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget _buildStory(String initials, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade300,
          child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 68,
          child: Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPost(BuildContext context, String author, String body) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.blueGrey[100], child: Text(author[0])),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Il y a 2 h', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(body),
            const SizedBox(height: 10),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('120 Likes', style: TextStyle(color: Colors.grey[600])),
                Text('34 Comments', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('Like')),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.mode_comment_outlined), label: const Text('Comment')),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined), label: const Text('Share')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.facebook, color: Color(0xFF1877F2)),
            const SizedBox(width: 8),
            const Text('AfriBook', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black54)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.message, color: Colors.black54)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // composer
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.grey.shade300, child: const Text('E')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration.collapsed(hintText: "Quoi de neuf ?"),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.photo, color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // stories
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 6),
                  _buildStory('EM', 'Ephraim'),
                  const SizedBox(width: 12),
                  _buildStory('AL', 'Aline'),
                  const SizedBox(width: 12),
                  _buildStory('MK', 'Mika'),
                  const SizedBox(width: 12),
                  _buildStory('ST', 'Steeve'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // feed
            _buildPost(context, 'Ephraim Kinda', 'Voici une super nouvelle pour la communauté Job research!'),
            _buildPost(context, 'Aline T.', 'Projet terminé — merci à toute l’équipe.'),
            _buildPost(context, 'Mika L.', 'Recherche développeur Flutter.'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Amis'),
          BottomNavigationBarItem(icon: Icon(Icons.ondemand_video), label: 'Watch'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        onTap: (i) {},
      ),
    );
  }
}


