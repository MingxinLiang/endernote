import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:endernote/presentation/widgets/custom_list_tile.dart';

class ScreenAbout extends StatelessWidget {
  const ScreenAbout({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String> getAppVersion() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      return packageInfo.version;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxOutline.arrow_left_2),
        ),
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                '让我们痛苦的从来不是远方的山，而是脚下的泥沙。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '--出发比到达重要',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: getAppVersion(),
              builder: (context, snapshot) => CustomListTile(
                lead: IconsaxOutline.info_circle,
                title: 'Version',
                subtitle: snapshot.data,
              ),
            ),
            const CustomListTile(
              lead: IconsaxOutline.award,
              title: 'Authors',
              subtitle: '玊',
            ),
            // const CustomListTile(
            //  lead: IconsaxOutline.award,
            //  title: 'Acknowledgments',
            //  subtitle:
            //      'Built by Endernote crafters with Flutter, using amazing tools like flutter_bloc and more.',
            //),
            //CustomListTile(
            //  lead: IconsaxOutline.star,
            //  title: 'Star us on Github',
            //  subtitle:
            //      'It will motivate us to work on cool projects like this.',
            //  trail: IconsaxOutline.link,
            //  onTap: () async => await launchUrl(
            //    Uri.parse('http s://www.baidu.com'),
            //  ),
            //),
            //CustomListTile(
            //  lead: IconsaxOutline.message,
            //  title: 'Support',
            //  subtitle: 'Found an issue? Need help? Create an issue here.',
            //  trail: IconsaxOutline.link,
            //  onTap: () async => await launchUrl(
            //    Uri.parse('https://www.github.com/shaaanuu/endernote/issues'),
            //  ),
            //),
          ],
        ),
      ),
    );
  }
}
