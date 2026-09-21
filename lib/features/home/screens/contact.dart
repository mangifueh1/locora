import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:locora/features/home/widgets/contact_cta.dart';
import 'package:locora/features/home/widgets/contact_form.dart';
import 'package:locora/features/home/widgets/contact_intro.dart';
import 'package:locora/features/home/widgets/contact_status.dart';
import 'package:locora/features/home/widgets/direct_channels.dart';
import 'package:locora/shared/widgets/footer.dart';
import 'package:locora/shared/widgets/navbar.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              Padding(
                padding: EdgeInsets.fromLTRB(78.w, 44.h, 78.w, 46.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ContactIntro(),
                    SizedBox(height: 28.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 760.w;
                        final form = const ContactForm();
                        final sidebar = Column(
                          children: [
                            const DirectChannels(),
                            SizedBox(height: 12.h),
                            const ContactStatus(),
                          ],
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              form,
                              SizedBox(height: 18.h),
                              sidebar,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: form),
                            SizedBox(width: 28.w),
                            Expanded(flex: 2, child: sidebar),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 36.h),
                    const ContactCta(),
                  ],
                ),
              ),
              const LocoraFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
