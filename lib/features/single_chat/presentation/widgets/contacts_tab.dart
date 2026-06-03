import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key, required this.onUserSelected});

  final void Function(Map<String, dynamic> user) onUserSelected;

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab>
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  bool _permissionDenied = false;
  List<_ContactMatch> _matches = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final status = await FlutterContacts.permissions
        .request(PermissionType.read);
    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      if (mounted) setState(() => _permissionDenied = true);
      if (mounted) setState(() => _loading = false);
      return;
    }

    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone, ContactProperty.email},
    );

    final contactEmails = <String, Contact>{};
    final contactPhones = <String, Contact>{};

    for (final contact in contacts) {
      for (final email in contact.emails) {
        final cleaned = email.address.trim().toLowerCase();
        if (cleaned.isNotEmpty) contactEmails[cleaned] = contact;
      }
      for (final phone in contact.phones) {
        final cleaned = _normalizePhone(phone.number);
        if (cleaned.isNotEmpty) contactPhones[cleaned] = contact;
      }
    }

    final usersSnapshot =
        await FirebaseFirestore.instance.collection(usersCollection).get();

    final matches = <_ContactMatch>[];
    final matchedContactIds = <String>{};

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final userEmail = (data['email'] as String? ?? '').trim().toLowerCase();
      final userPhone = _normalizePhone(data['phoneNumber'] as String? ?? '');

      Contact? matchedContact;
      if (userEmail.isNotEmpty && contactEmails.containsKey(userEmail)) {
        matchedContact = contactEmails[userEmail];
      } else if (userPhone.isNotEmpty && contactPhones.containsKey(userPhone)) {
        matchedContact = contactPhones[userPhone];
      }

      if (matchedContact != null) {
        matchedContactIds.add(matchedContact.id ?? '');
        matches.add(_ContactMatch(
          contactName: matchedContact.displayName ?? '',
          userData: {'id': doc.id, ...data},
          isRegistered: true,
        ));
      }
    }

    // Add non-registered contacts
    for (final contact in contacts) {
      final name = contact.displayName ?? '';
      if (!matchedContactIds.contains(contact.id) && name.isNotEmpty) {
        matches.add(_ContactMatch(
          contactName: name,
          userData: null,
          isRegistered: false,
        ));
      }
    }

    matches.sort((a, b) {
      if (a.isRegistered && !b.isRegistered) return -1;
      if (!a.isRegistered && b.isRegistered) return 1;
      return a.contactName.compareTo(b.contactName);
    });

    if (mounted) {
      setState(() {
        _matches = matches;
        _loading = false;
      });
    }
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.contacts_outlined,
                  size: 64.sp, color: context.color.onSurfaceVariant),
              SizedBox(height: 16.h),
              Text(
                context.translate(LangKeys.contactPermissionRequired),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: context.color.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              FilledButton(
                onPressed: _loadContacts,
                child: Text(context.translate(LangKeys.grantPermission)),
              ),
            ],
          ),
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Text(
          context.translate(LangKeys.noContactsFound),
          style: TextStyle(
            fontSize: 15.sp,
            color: context.color.onSurfaceVariant,
          ),
        ),
      );
    }

    final registered = _matches.where((m) => m.isRegistered).toList();
    final notRegistered = _matches.where((m) => !m.isRegistered).toList();

    return ListView(
      children: [
        if (registered.isNotEmpty) ...[
          _SectionHeader(
            title: context.translate(LangKeys.contactsOnApp),
            count: registered.length,
          ),
          ...registered.map((m) => _ContactTile(
                name: m.contactName,
                subtitle: m.userData?['email'] as String? ?? '',
                isRegistered: true,
                onTap: () => widget.onUserSelected(m.userData!),
              )),
        ],
        if (notRegistered.isNotEmpty) ...[
          _SectionHeader(
            title: context.translate(LangKeys.inviteToApp),
            count: notRegistered.length,
          ),
          ...notRegistered.map((m) => _ContactTile(
                name: m.contactName,
                subtitle: '',
                isRegistered: false,
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text: context.translate(LangKeys.inviteMessage),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}

class _ContactMatch {
  const _ContactMatch({
    required this.contactName,
    required this.userData,
    required this.isRegistered,
  });

  final String contactName;
  final Map<String, dynamic>? userData;
  final bool isRegistered;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        '$title ($count)',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: context.color.primary,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.subtitle,
    required this.isRegistered,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool isRegistered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final color = _getColor(name);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.color.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isRegistered
          ? Icon(Icons.chat_outlined, color: context.color.primary)
          : Text(
              context.translate(LangKeys.invite),
              style: TextStyle(
                color: context.color.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
      onTap: onTap,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? '${name[0]}${name[1]}'.toUpperCase()
        : name[0].toUpperCase();
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
