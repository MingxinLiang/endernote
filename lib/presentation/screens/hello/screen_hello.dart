import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_fab.dart';

class ScreenHello extends StatelessWidget {
  final String rootPath;
  const ScreenHello({super.key, required this.rootPath});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<bool> hasText = ValueNotifier<bool>(false);

    searchController.addListener(() {
      hasText.value = searchController.text.isNotEmpty;
    });

    return Scaffold(
      appBar: CustomAppBar(
        rootPath: rootPath,
        controller: searchController,
        hasText: hasText,
      ),

      // TODO: 优化入门页面
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Untangle',
                    style: TextStyle(
                      fontFamily: 'Barriecito',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf2cdcd),
                      height: 1.1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0, top: 10),
                        child: SvgPicture.asset(
                          'lib/assets/brain.svg',
                          width: 70,
                          height: 70,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFf38ba8),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const Text(
                        'Your',
                        style: TextStyle(
                          fontFamily: 'Barriecito',
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFb4befe),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Thoughts',
                    style: TextStyle(
                      fontFamily: 'Barriecito',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFcba6f7),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    IconsaxOutline.note_2,
                    size: 24,
                    color: Color(0xFF1e1e2e),
                  ),
                  label: const Text(
                    'Create new note',
                    style: TextStyle(
                      fontFamily: 'FiraCode',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e1e2e),
                      wordSpacing: -3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF89b4fa),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () async {
                    final newFile = File(
                      '$rootPath/new_note_${DateTime.now().millisecondsSinceEpoch}.md',
                    );
                    await newFile.create();

                    Get.toNamed("/canvas", arguments: newFile.path);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(IconsaxOutline.folder),
                  label: const Text(
                    'Open a note',
                    style: TextStyle(
                      fontFamily: 'FiraCode',
                      fontWeight: FontWeight.bold,
                      wordSpacing: -3,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () =>
                      Get.toNamed("/noteList", arguments: rootPath),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFAB(rootPath: rootPath),
    );
  }
}
