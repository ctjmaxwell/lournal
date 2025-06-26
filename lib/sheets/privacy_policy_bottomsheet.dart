import 'package:flutter/material.dart';

// --- Function to show the bottom sheet ---
// Renamed for clarity and updated the return type.
Future<void> showPrivacyPolicyBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up more screen space
    useSafeArea: true,       // Ensures the sheet respects system intrusions (notch, home bar)
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => const _PrivacyPolicySheetContent(),
  );
}

// --- The content of the bottom sheet ---
// Converted to a StatefulWidget to manage its own state correctly.
class _PrivacyPolicySheetContent extends StatefulWidget {
  const _PrivacyPolicySheetContent({Key? key}) : super(key: key);
  

  @override
  State<_PrivacyPolicySheetContent> createState() =>
      _PrivacyPolicySheetContentState();
}

// --- The state and layout for the bottom sheet content ---
class _PrivacyPolicySheetContentState extends State<_PrivacyPolicySheetContent> {
  @override
  Widget build(BuildContext context) {
    // Using a Material widget allows for proper theming and background color.
    // Using Theme.of(context).colorScheme.surface is generally recommended for sheet backgrounds.
    return Material(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: false, // SafeArea is handled by the showModalBottomSheet's useSafeArea property
        child: Stack(
          children: [
            // --- Scrollable Content ---
            Padding(
              // Padding for the main content area
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Top Bar with Close Button ---
                    const Padding(
                      padding: EdgeInsets.only(top: 32.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title is now aligned with the text content
                          Expanded(
                            child: Text(
                              'PRIVACY POLICY',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Privacy Policy Content ---
                    _buildSubText('Last updated June 13, 2025'),
                    const SizedBox(height: 16),
                    _buildParagraph(
                        "This Privacy Notice for MAXAFFINITY LTD ('we', 'us', or 'our'), describes how and why we might access, collect, store, use, and/or share ('process') your personal information when you use our services ('Services'), including when you:"),
                    _buildListItem(
                        'Visit our website at http://www.maxaffinity.co.uk or any website of ours that links to this Privacy Notice.'),
                    _buildListItem(
                        'Download and use our mobile application (Lournal), or any other application of ours that links to this Privacy Notice.'),
                    _buildListItem(
                        'Engage with us in other related ways, including any sales, marketing, or events.'),
                    _buildParagraph(
                        'We are committed to protecting your privacy and personal information globally. This Privacy Notice applies to all users of our Services, regardless of their location, and aims to comply with applicable data protection laws. We are responsible for making decisions about how your personal information is processed. If you do not agree with our policies and practices, please do not use our Services. If you still have any questions or concerns, please contact us at contact@maxaffinity.co.uk.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('SUMMARY OF KEY POINTS'),
                    const SizedBox(height: 8),
                    _buildSubText(
                        'This summary provides key points from our Privacy Notice, but you can find out more details about any of these topics by clicking the link following each key point or by using our table of contents below to find the section you are looking for.'),
                    const SizedBox(height: 16),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'What personal information do we process? ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "When you use our Services, we may process personal information depending on how you interact with us and the Services, the choices you make, and the products and features you use. This includes your email address and password for account creation, and the text-based journal entries you provide. Learn more about personal information you disclose to us."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Do we process any sensitive personal information? ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "Due to the nature of a journaling application, your journal entries may contain sensitive personal information. We only process this information to provide you with our Services, including AI-generated feedback, and we do so with your explicit consent. Learn more about sensitive information we process."),
                    ]),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('WHAT INFORMATION DO WE COLLECT?'),
                    const SizedBox(height: 12),
                    _buildSubHeading('Personal information you disclose to us'),
                    _buildParagraph(
                        'We collect personal information that you voluntarily provide to us when you register on the Services, express an interest in obtaining information about us or our products and Services, when you participate in activities on the Services, or otherwise when you contact us.'),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Personal Information Provided by You. ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              'The personal information that we collect depends on the context of your interactions with us and the Services, the choices you make, and the products and features you use. The personal information we collect may include the following:'),
                    ]),
                    _buildListItem('Email Addresses'),
                    _buildListItem('Passwords'),
                    _buildListItem('User Journal Entries (text-based)'),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Sensitive Information. ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              'Due to the nature of a journaling application, the text-based entries you submit may contain "special categories" of personal data as defined by the UK GDPR (e.g., information about your racial or ethnic origin, political opinions, religious or philosophical beliefs, trade union membership, genetic data, biometric data, data concerning health or data concerning a natural person\'s sex life or sexual orientation). We process this information solely for the purpose of providing the journaling and AI feedback features of the Lournal app. We will obtain your explicit consent for the processing of this sensitive data when you sign up for and use the AI feedback feature.'),
                    ]),
                    _buildParagraph(
                        'All personal information that you provide to us must be true, complete, and accurate, and you must notify us of any changes to such personal information.'),
                    const SizedBox(height: 12),

                    // --- NEW CONTENT STARTS HERE ---
                    _buildSubHeading('Information automatically collected'),
                    _buildParagraph(
                        'Our website is hosted on Firebase Hosting. Firebase Hosting may automatically collect certain information when you visit, use, or navigate the website. This information does not reveal your specific identity (like your name or contact information) but may include device and usage information, such as your IP address, browser and device characteristics, operating system, language preferences, referring URLs, device name, country, location, information about how and when you use our website, and other technical information. This information is primarily needed to maintain the security and operation of our website, and for our internal analytics and reporting purposes. For more information, please refer to the Firebase Privacy Policy. We do not use cookies on our website.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('HOW DO WE PROCESS YOUR INFORMATION?'),
                    _buildParagraph(
                        'We process your personal information for a variety of reasons, depending on how you interact with our Services, including:'),
                    _buildListItem(
                        'To facilitate account creation and authentication and otherwise manage user accounts. We may process your information so you can create and log in to your account, as well as keep your account in working order.'),
                    _buildListItem(
                        'To provide the core functionality of the Lournal app. We process your journal entries to store them on your behalf and synchronise them across your devices.'),
                    _buildListItem(
                        'To provide AI-powered feedback. With your explicit consent, we will send your journal entries to Google\'s Gemini API to generate feedback for you.'),
                    _buildListItem(
                        'To protect our Services. We may process your information as part of our efforts to keep our Services safe and secure, including fraud monitoring and prevention.'),
                    _buildListItem(
                        'To comply with our legal obligations. We may process your information to comply with our legal obligations, respond to legal requests, and exercise, establish, or defend our legal rights.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('WHAT LEGAL BASES DO WE RELY ON TO PROCESS YOUR PERSONAL INFORMATION?'),
                    _buildParagraph(
                        'We process your personal information based on valid legal grounds, as required by applicable data protection laws. While our primary compliance framework is the UK General Data Protection Regulation (UK GDPR) due to our company\'s establishment, the legal bases we rely on are generally consistent across many privacy regimes. We may rely on the following legal bases to process your personal information:'),
                    _buildRichTextParagraph([
                      const TextSpan(text: 'Consent. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may process your information if you have given us permission (i.e., consent) to use your personal information for a specific purpose. Specifically, we rely on your explicit consent to process the content of your journal entries for the purpose of providing AI-generated feedback. You can withdraw your consent at any time.'),
                    ]),
                     _buildRichTextParagraph([
                      const TextSpan(text: 'Performance of a Contract. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may process your personal information when we believe it is necessary to fulfil our contractual obligations to you, including providing our Services or at your request prior to entering into a contract with you. This includes creating and maintaining your account and storing your journal entries.'),
                    ]),
                     _buildRichTextParagraph([
                      const TextSpan(text: 'Legitimate Interests. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may process your information when we believe it is reasonably necessary to achieve our legitimate business interests and those interests do not outweigh your interests and fundamental rights and freedoms. For example, we may process your personal information for some of the purposes described in order to prevent fraud and to ensure the security of our Services.'),
                    ]),
                     _buildRichTextParagraph([
                      const TextSpan(text: 'Legal Obligations. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may process your information where we believe it is necessary for compliance with our legal obligations, such as to cooperate with a law enforcement body or regulatory agency, exercise or defend our legal rights, or disclose your information as evidence in litigation in which we are involved.'),
                    ]),
                     _buildRichTextParagraph([
                      const TextSpan(text: 'Vital Interests. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may process your information where we believe it is necessary to protect your vital interests or the vital interests of a third party, such as situations involving potential threats to the safety of any person.'),
                    ]),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('WHEN AND WITH WHOM DO WE SHARE YOUR PERSONAL INFORMATION?'),
                    _buildParagraph('We may need to share your personal information in the following situations:'),
                    _buildRichTextParagraph([
                      const TextSpan(text: 'With our Service Providers. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may share your personal information with third-party vendors, service providers, contractors, or agents who perform services for us or on our behalf and require access to such information to do that work. The service providers we use are:'),
                    ]),
                    _buildListItem('Firebase (Google): We use Firebase for user authentication (email and password sign-in), cloud storage of your journal entries (Cloud Firestore), and for hosting our mobile application and website. You can find more information on Google\'s privacy practices here: https://policies.google.com/privacy.'),
                    _buildListItem('Google AI (Gemini API): We use the Google AI Gemini API to provide you with feedback on your journal entries. When you use this feature, the text of your journal entry is sent to the Google AI platform for analysis. You can find more information on Google\'s privacy practices here: https://policies.google.com/privacy.'),
                     _buildRichTextParagraph([
                      const TextSpan(text: 'Business Transfers. ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.'),
                    ]),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('INTERNATIONAL DATA TRANSFERS'),
                     _buildParagraph('MAXAFFINITY LTD is based in the United Kingdom. Your information may be processed and stored in the UK and in other countries where our service providers (such as Google and Firebase) operate. These countries may not have data protection laws as comprehensive as those in your own country.'),
                     _buildParagraph('When we transfer personal information to countries outside of the UK or the European Economic Area (EEA), we implement appropriate safeguards to ensure that your data remains protected in accordance with this Privacy Notice and applicable laws. These safeguards may include:'),
                     _buildListItem('Adequacy Decisions: Relying on an adequacy decision from the European Commission or the UK government, which recognizes that a country provides an adequate level of data protection.'),
                     _buildListItem('Standard Contractual Clauses (SCCs): Implementing standard contractual clauses approved by the European Commission or the UK Information Commissioner\'s Office, which are legally binding agreements designed to protect personal data.'),
                     _buildListItem('Binding Corporate Rules (BCRs): For intra-group transfers, if applicable.'),
                     _buildListItem('Your Explicit Consent: In specific situations, if a transfer is necessary and no other safeguards are available, we may transfer your data based on your explicit consent.'),
                     _buildParagraph('By using our Services, you understand that your information may be transferred to and processed in countries outside of your country of residence.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    _buildHeading('HOW LONG DO WE KEEP YOUR INFORMATION?'),
                    _buildParagraph('We will only keep your personal information for as long as it is necessary for the purposes set out in this Privacy Notice, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements). No purpose in this notice will require us keeping your personal information for longer than the period of time in which users have an account with us.'),
                    _buildParagraph('When we have no ongoing legitimate business need to process your personal information, we will either delete or anonymise such information, or, if this is not possible (for example, because your personal information has been stored in backup archives), then we will securely store your personal information and isolate it from any further processing until deletion is possible. If you choose to delete your account, all of your personal data, including your journal entries, will be permanently deleted from our active databases.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('HOW DO WE KEEP YOUR INFORMATION SAFE?'),
                    _buildParagraph('We have implemented appropriate and reasonable technical and organisational security measures designed to protect the security of any personal information we process. We rely on the security measures provided by our third-party service providers, Firebase and Google AI, to safeguard your data. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure, so we cannot promise or guarantee that hackers, cybercriminals, or other unauthorised third parties will not be able to defeat our security and improperly collect, access, steal, or modify your information. Although we will do our best to protect your personal information, transmission of personal information to and from our Services is at your own risk. You should only access the Services within a secure environment.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    _buildHeading('WHAT ARE YOUR PRIVACY RIGHTS?'),
                    _buildParagraph('Depending on your location and the data protection laws that apply to you, you may have certain rights regarding your personal information. While our processing is primarily governed by the UK General Data Protection Regulation (UK GDPR) due to our company\'s establishment, we aim to respect these rights broadly. These rights may include, but are not limited to:'),
                    _buildListItem('(i) The right to be informed about how your data is processed (which this Privacy Notice aims to do).'),
                    _buildListItem('(ii) The right of access to and obtain a copy of your personal information.'),
                    _buildListItem('(iii) The right to rectification of inaccurate or incomplete information.'),
                    _buildListItem('(iv) The right to erasure of your personal information (often known as the \'right to be forgotten\').'),
                    _buildListItem('(v) The right to restrict processing of your personal information.'),
                    _buildListItem('(vi) The right to data portability (receiving your data in a structured, commonly used, and machine-readable format).'),
                    _buildListItem('(vii) The right to object to the processing of your personal information in certain circumstances.'),
                    _buildListItem('(viii) The right to withdraw consent at any time where consent is the legal basis for processing.'),
                    _buildParagraph('You can make such a request by contacting us by using the contact details provided in the section \'HOW CAN YOU CONTACT US ABOUT THIS NOTICE?\' below. We will consider and act upon any request in accordance with applicable data protection laws.'),
                    _buildRichTextParagraph([
                        const TextSpan(text: 'Complaints: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'If you believe we are unlawfully processing your personal information, you have the right to lodge a complaint with your local data protection supervisory authority. For users in the UK, this would be the Information Commissioner\'s Office (ICO). You can find their contact details here: https://ico.org.uk/make-a-complaint/data-protection-complaints/data-protection-complaints/.'),
                    ]),
                    _buildRichTextParagraph([
                        const TextSpan(text: 'Withdrawing your consent: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'If we are relying on your consent to process your personal information, you have the right to withdraw your consent at any time. You can withdraw your consent at any time by contacting us by using the contact details provided in the section \'HOW CAN YOU CONTACT US ABOUT THIS NOTICE?\' below. However, please note that this will not affect the lawfulness of the processing before its withdrawal, nor will it affect the processing of your personal information conducted in reliance on lawful processing grounds other than consent.'),
                    ]),
                     _buildSubHeading('Account Information'),
                    _buildParagraph('If you would at any time like to review or change the information in your account or terminate your account, you can do so in the app\'s settings. Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('DO WE MAKE UPDATES TO THIS NOTICE?'),
                    _buildParagraph('We may update this Privacy Notice from time to time. The updated version will be indicated by an updated \'Revised\' date at the top of this Privacy Notice. If we make material changes to this Privacy Notice, we may notify you either by prominently posting a notice of such changes or by directly sending you a notification. We encourage you to review this Privacy Notice frequently to be informed of how we are protecting your information.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('HOW CAN YOU CONTACT US ABOUT THIS NOTICE?'),
                    _buildParagraph('If you have questions or comments about this notice, you may email us at contact@maxaffinity.co.uk'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    _buildHeading('HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU?'),
                    _buildParagraph('Based on the applicable laws of your country, you may have the right to request access to the personal information we collect from you, change that information, or delete it in some circumstances. To request to review, update, or delete your personal information, please contact us at contact@maxaffinity.co.uk. You can also delete your account directly within the \'Lournal\' app, which will result in the deletion of all your associated data.'),
                    
                    // --- Bottom Padding to ensure content is not hidden by the button ---
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // --- Positioned "Done" Button ---
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                  child: const Text('Done',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Text Styling ---

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSubText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRichTextParagraph(List<InlineSpan> children) {
    // Get the default text style (which includes your grey color) from the theme.
    final defaultTextStyle = DefaultTextStyle.of(context).style;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: RichText(
        text: TextSpan(
          // Use the default style and just change the parts you need.
          style: defaultTextStyle.copyWith(
            fontSize: 15,
            height: 1.5,
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}