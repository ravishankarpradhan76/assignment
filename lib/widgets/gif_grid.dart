import 'package:flutter/material.dart';
import '../models/gif_model.dart';
import 'gif_item.dart';

class GifGrid extends StatelessWidget {
  final List<GifModel> gifs;
  final bool isLoading;
  final VoidCallback onLoadMore;

  const GifGrid({
    super.key,
    required this.gifs,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: gifs.length + (isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= gifs.length) {
            return  Center(
                child: CircularProgressIndicator(),
            );
          }
          return GifItem(gif: gifs[index]);
        },
      ),
    );
  }
}