import 'dart:async';

import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchUsersTab extends StatefulWidget {
  const SearchUsersTab({super.key, required this.onUserSelected});

  final void Function(Map<String, dynamic> user) onUserSelected;

  @override
  State<SearchUsersTab> createState() => _SearchUsersTabState();
}

class _SearchUsersTabState extends State<SearchUsersTab>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final cleaned = query.trim().toLowerCase();
    if (cleaned.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasSearched = true;
    });

    try {
      final currentUserId = getCurrentUser().uid;
      final snapshot = await FirebaseFirestore.instance
          .collection(usersCollection)
          .get();

      final matches = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        if (doc.id == currentUserId) continue;

        final data = doc.data();
        final name = (data['name'] as String? ?? '').toLowerCase();
        final email = (data['email'] as String? ?? '').toLowerCase();
        final phone = (data['phoneNumber'] as String? ?? '').toLowerCase();

        if (name.contains(cleaned) ||
            email.contains(cleaned) ||
            phone.contains(cleaned)) {
          matches.add({'id': doc.id, ...data});
        }
      }

      if (mounted) {
        setState(() {
          _results = matches;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: context.translate(LangKeys.searchByNameEmailPhone),
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: context.color.surfaceContainerHigh,
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : !_hasSearched
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_outlined,
                            size: 64.sp,
                            color: context.color.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            context.translate(LangKeys.searchForUsers),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: context.color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            context
                                .translate(LangKeys.noUserFoundWithThisEmail),
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: context.color.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final user = _results[index];
                            final name = user['name'] as String? ?? '';
                            final email = user['email'] as String? ?? '';
                            final displayName =
                                name.isNotEmpty ? name : email;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getColor(displayName),
                                child: Text(
                                  _getInitials(displayName),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: name.isNotEmpty && email.isNotEmpty
                                  ? Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: context.color.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.chat_outlined,
                                color: context.color.primary,
                              ),
                              onTap: () => widget.onUserSelected(user),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final cleanName = name.split('@').first;
    return cleanName.length >= 2
        ? '${cleanName[0]}${cleanName[1]}'.toUpperCase()
        : cleanName[0].toUpperCase();
  }

  Color _getColor(String text) {
    const colors = [
      Color(0xFFEF5350), Color(0xFF42A5F5), Color(0xFF66BB6A),
      Color(0xFFFFA726), Color(0xFFAB47BC), Color(0xFF26C6DA),
      Color(0xFFEC407A), Color(0xFF8D6E63),
    ];
    final hash = text.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return colors[hash % colors.length];
  }
}
