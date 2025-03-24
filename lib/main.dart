import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart'; 
import 'interview_screen.dart'; 

void main() {
  runApp(const AIInterviewer());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

class AIInterviewer extends StatelessWidget {
  const AIInterviewer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Poppins'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Set<String> favoriteRoles = {};

  void _toggleFavorite(String role) {
    setState(() {
      if (favoriteRoles.contains(role)) {
        favoriteRoles.remove(role);
      } else {
        favoriteRoles.add(role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _buildHomeScreen(),
      FavoritesScreen(favoriteRoles: favoriteRoles),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppData.categories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CategoryCard(
                  title: AppData.categories[index]["title"]!,
                  icon: AppData.categories[index]["icon"]!,
                  onTap: () {
                    // Navigate to CategoryRolesScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryRolesScreen(
                          categoryTitle: AppData.categories[index]["title"]!,
                          favoriteRoles: favoriteRoles,
                          onFavoriteToggle: _toggleFavorite,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Popular and Trending Job Roles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: AppData.roles.length,
            itemBuilder: (context, index) {
              final role = AppData.roles[index];
              return RoleItemCard(
                title: role["title"]!,
                image: role["image"]!,
                duration: role["duration"]!,
                rating: role["rating"]!,
                isFavorite: favoriteRoles.contains(role["title"]),
                onFavoriteToggle: () => _toggleFavorite(role["title"]!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoleDetailScreen(
                        title: role["title"]!,
                        image: role["image"]!,
                        duration: role["duration"]!,
                        rating: role["rating"]!,
                        description: role["description"]!, // Pass description
                        isFavorite: favoriteRoles.contains(role["title"]),
                        onFavoriteToggle: () => _toggleFavorite(role["title"]!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleItemCard extends StatelessWidget {
  final String title;
  final String image;
  final String duration;
  final String rating;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const RoleItemCard({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
    required this.rating,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          duration,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        iconSize: 24,
                        onPressed: onFavoriteToggle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final Set<String> favoriteRoles;

  const FavoritesScreen({super.key, required this.favoriteRoles});

  @override
  Widget build(BuildContext context) {
    // Filter roles to only include favorites
    final favoriteRoleList = AppData.roles.where((role) => favoriteRoles.contains(role["title"])).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: favoriteRoleList.isEmpty
          ? const Center(child: Text("No favorites added yet.", style: TextStyle(fontSize: 18)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: favoriteRoleList.length,
                itemBuilder: (context, index) {
                  final role = favoriteRoleList[index];
                  return RoleItemCard(
                    title: role["title"]!,
                    image: role["image"]!,
                    duration: role["duration"]!,
                    rating: role["rating"]!,
                    isFavorite: true, // Since these are favorites, set isFavorite to true
                    onFavoriteToggle: () {
                      // Remove the role from favorites when the heart icon is tapped
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${role["title"]} removed from favorites"),
                        ),
                      );
                      // Navigate back to the homepage (or update state if using a state management solution)
                      Navigator.pop(context);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleDetailScreen(
                            title: role["title"]!,
                            image: role["image"]!,
                            duration: role["duration"]!,
                            rating: role["rating"]!,
                            description: role["description"]!, 
                            isFavorite: true,
                            onFavoriteToggle: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${role["title"]} removed from favorites"),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class CategoryRolesScreen extends StatelessWidget {
  final String categoryTitle;
  final Set<String> favoriteRoles;
  final Function(String) onFavoriteToggle;

  const CategoryRolesScreen({
    super.key,
    required this.categoryTitle,
    required this.favoriteRoles,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Filter roles for the selected category
    final categoryRoles = AppData.roles.where((role) => role["category"] == categoryTitle).toList();

    return Scaffold(
      appBar: AppBar(title: Text(categoryTitle)),
      body: categoryRoles.isEmpty
          ? const Center(child: Text("No roles found for this category.", style: TextStyle(fontSize: 18)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryRoles.length,
                itemBuilder: (context, index) {
                  final role = categoryRoles[index];
                  return RoleItemCard(
                    title: role["title"]!,
                    image: role["image"]!,
                    duration: role["duration"]!,
                    rating: role["rating"]!,
                    isFavorite: favoriteRoles.contains(role["title"]),
                    onFavoriteToggle: () => onFavoriteToggle(role["title"]!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleDetailScreen(
                            title: role["title"]!,
                            image: role["image"]!,
                            duration: role["duration"]!,
                            rating: role["rating"]!,
                            description: role["description"]!, 
                            isFavorite: favoriteRoles.contains(role["title"]),
                            onFavoriteToggle: () => onFavoriteToggle(role["title"]!),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class RoleDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final String duration;
  final String rating;
  final String description;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RoleDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
    required this.rating,
    required this.description,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  _RoleDetailScreenState createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<RoleDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                widget.image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.duration,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  widget.rating,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Description",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InterviewScreen(roleTitle: widget.title),
            ),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}