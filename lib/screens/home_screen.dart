import 'package:flutter/material.dart';
import 'dart:async';
import '../models/gif_model.dart';
import '../services/giphy_service.dart';
import '../widgets/search_bar.dart';
import '../widgets/gif_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GifModel> _gifs = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _currentQuery = '';
  int _currentOffset = 0;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrendingGifs();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingGifs() async {
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
    });

    try {
      final gifs = await GiphyService.getTrendingGifs();
      setState(() {
        _gifs = gifs;
        _currentOffset = gifs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load trending GIFs: $e');
    }
  }

  Future<void> _searchGifs(String query) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _currentQuery = query;
        _isLoading = true;
        _currentOffset = 0;
      });

      try {
        final gifs = await GiphyService.searchGifs(query);
        setState(() {
          _gifs = gifs;
          _currentOffset = gifs.length;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to search GIFs: $e');
      }
    });
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<GifModel> newGifs;
      if (_currentQuery.isEmpty) {
        newGifs = await GiphyService.getTrendingGifs(offset: _currentOffset);
      } else {
        newGifs = await GiphyService.searchGifs(_currentQuery, offset: _currentOffset);
      }

      setState(() {
        _gifs.addAll(newGifs);
        _currentOffset += newGifs.length;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showError('Failed to load more GIFs: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giphy GIFs'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          GifSearchBar(
            onSearch: _searchGifs,
            controller: _searchController,
          ),
          Expanded(
            child: _isLoading && _gifs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _gifs.isEmpty
                ? const Center(
              child: Text(
                'No GIFs found',
                style: TextStyle(fontSize: 18),
              ),
            )
                : GifGrid(
              gifs: _gifs,
              isLoading: _isLoadingMore,
              onLoadMore: _loadMoreGifs,
            ),
          ),
        ],
      ),
    );
  }
}