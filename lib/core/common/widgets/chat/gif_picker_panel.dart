import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GifPickerPanel extends StatefulWidget {
  const GifPickerPanel({
    super.key,
    required this.onGifSelected,
    required this.giphyApiKey,
  });

  final void Function(String gifUrl) onGifSelected;
  final String giphyApiKey;

  @override
  State<GifPickerPanel> createState() => _GifPickerPanelState();
}

class _GifPickerPanelState extends State<GifPickerPanel> {
  final _dio = Dio();
  final _searchController = TextEditingController();
  List<_GifItem> _gifs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _dio.get(
        'https://api.giphy.com/v1/gifs/trending',
        queryParameters: {
          'api_key': widget.giphyApiKey,
          'limit': 30,
          'rating': 'g',
        },
      );
      _parseResponse(response.data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadTrending();
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _dio.get(
        'https://api.giphy.com/v1/gifs/search',
        queryParameters: {
          'api_key': widget.giphyApiKey,
          'q': query,
          'limit': 30,
          'rating': 'g',
        },
      );
      _parseResponse(response.data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseResponse(dynamic data) {
    final items = <_GifItem>[];
    final dataList = data['data'] as List? ?? [];
    for (final gif in dataList) {
      final images = gif['images'] as Map<String, dynamic>?;
      if (images == null) continue;
      final preview =
          (images['fixed_width_small'] ?? images['fixed_width']) as Map<String, dynamic>?;
      final original = images['original'] as Map<String, dynamic>?;
      if (preview != null && original != null) {
        items.add(_GifItem(
          previewUrl: preview['url'] as String? ?? '',
          fullUrl: original['url'] as String? ?? '',
        ));
      }
    }
    if (mounted) setState(() => _gifs = items);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search GIFs...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.color.surfaceContainerHigh,
              ),
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          'Failed to load GIFs',
                          style: TextStyle(
                            color: context.color.onSurfaceVariant,
                            fontSize: 13.sp,
                          ),
                        ),
                      )
                    : _gifs.isEmpty
                        ? Center(
                            child: Text(
                              'No GIFs found',
                              style: TextStyle(
                                color: context.color.onSurfaceVariant,
                                fontSize: 13.sp,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.all(4.r),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4.r,
                              crossAxisSpacing: 4.r,
                            ),
                            itemCount: _gifs.length,
                            itemBuilder: (context, index) {
                              final gif = _gifs[index];
                              return GestureDetector(
                                onTap: () =>
                                    widget.onGifSelected(gif.fullUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CachedNetworkImage(
                                    imageUrl: gif.previewUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: context
                                          .color.surfaceContainerHighest,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: context
                                          .color.surfaceContainerHighest,
                                      child: Icon(Icons.broken_image,
                                          size: 24.sp),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _GifItem {
  const _GifItem({required this.previewUrl, required this.fullUrl});
  final String previewUrl;
  final String fullUrl;
}
