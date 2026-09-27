import 'package:flutter/material.dart';

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
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Navbar(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 78,
                  compact ? 28 : 44,
                  compact ? 20 : 78,
                  compact ? 30 : 46,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ContactIntro(),
                    SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 760;
                        final form = const ContactForm();
                        final sidebar = Column(
                          children: [
                            const DirectChannels(),
                            SizedBox(height: 12),
                            const ContactStatus(),
                          ],
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              form,
                              SizedBox(height: 18),
                              sidebar,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: form),
                            SizedBox(width: 28),
                            Expanded(flex: 2, child: sidebar),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 36),
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
