import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/features/group/repository/group_repository.dart';

final groupControllerProvider = Provider<GroupController>((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(
    groupRepository: groupRepository,
    ref: ref,
  );
});

class GroupController {
  final GroupRepository groupRepository;
  final Ref ref;                    // ← Ubah ke Ref

  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  void createGroup(
    BuildContext context, 
    String name, 
    File profilePic,
    List<Contact> selectedContact,
  ) {
    groupRepository.createGroup(context, name, profilePic, selectedContact);
  }
}