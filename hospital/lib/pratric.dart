import 'package:flutter/material.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Medical Center',
      'description':
          'Yorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.',
      'image':
          'https://randomuser.me/api/portraits/men/32.jpg', // replace with your doctor image
      'color': Colors.teal,
    },
    {
      'title': 'Online Consultation',
      'description': 'Talk with a specialist from home.',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: banner['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner['description'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Image.network(banner['image'], fit: BoxFit.cover),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 10 : 8,
              height: isActive ? 10 : 7,
              decoration: BoxDecoration(
                color: isActive ? Colors.teal : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
