import 'package:flutter/material.dart';

// --- Function to show the bottom sheet ---
// Renamed for clarity and updated the return type.
Future<void> showTermsAndConditionsBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up more screen space
    useSafeArea: true,       // Ensures the sheet respects system intrusions (notch, home bar)
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => const _TermsAndConditionsSheetContent(),
  );
}

// --- The content of the bottom sheet ---
// Converted to a StatefulWidget to manage its own state correctly.
class _TermsAndConditionsSheetContent extends StatefulWidget {
  const _TermsAndConditionsSheetContent({Key? key}) : super(key: key);

  @override
  State<_TermsAndConditionsSheetContent> createState() =>
      _TermsAndConditionsSheetContentState();
}

// --- The state and layout for the bottom sheet content ---
class _TermsAndConditionsSheetContentState extends State<_TermsAndConditionsSheetContent> {
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
                              'TERMS AND CONDITIONS', // UPDATED TITLE
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

                    // --- Terms and Conditions Content ---
                    // REPLACED PRIVACY POLICY CONTENT WITH TERMS AND CONDITIONS
                    _buildSubText('Last updated June 16, 2025'),
                    const SizedBox(height: 16),
                    _buildParagraph(
                        'These Legal Terms constitute a legally binding agreement made between you, whether personally or on behalf of an entity ("you"), and MAXAFFINITY LTD ("Company," "we," "us," or "our"), concerning your access to and use of our services ("Services"), including:'),
                    _buildListItem('Our mobile application: Lournal'),
                    _buildListItem(
                        'Any other related products and services that refer or link to these Legal Terms (collectively, the "Services")'),
                    _buildParagraph(
                        'Lournal is an AI-powered language learning application designed to enhance writing proficiency through structured journaling. Users compose journal entries in their target language and receive comprehensive AI-driven feedback on grammar, vocabulary, syntax, and style. All entries are archived, providing a robust historical record for progress tracking and review.'),
                    _buildParagraph(
                        'By accessing or using the Services, you confirm that you have read, understood, and agree to be bound by all of these Legal Terms. IF YOU DO NOT AGREE WITH ALL OF THESE LEGAL TERMS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SERVICES AND YOU MUST DISCONTINUE USE IMMEDIATELY.'),
                    _buildParagraph(
                        'Supplemental terms and conditions or documents that may be posted on the Services from time to time are hereby expressly incorporated herein by reference. We reserve the right, in our sole discretion, to make changes or modifications to these Legal Terms at any time. We will alert you about any changes by updating the "Last updated" date of these Legal Terms, and you waive any right to receive specific notice of each such change. It is your responsibility to periodically review these Legal Terms to stay informed of updates. You will be subject to, and will be deemed to have been made aware of and to have accepted, the changes in any revised Legal Terms by your continued use of the Services after the date such revised Legal Terms are posted.'),
                    _buildParagraph(
                        'All users who are minors in the jurisdiction in which they reside (generally under the age of 18) must have the permission of, and be directly supervised by, their parent or guardian to use the Services. If you are a minor, you must have your parent or guardian read and agree to these Legal Terms prior to you using the Services. If you still have any questions or concerns, please contact us at contact@maxaffinity.co.uk.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('SUMMARY OF KEY POINTS'),
                    const SizedBox(height: 8),
                    _buildSubText(
                        'This summary provides key points from our Legal Terms, but you can find more details about any of these topics by clicking the link following each key point or by using our table of contents below to find the section you are looking for.'),
                    const SizedBox(height: 16),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Agreement to Terms: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "By using our Services, you agree to these legally binding terms. If you don't agree, you must stop using the Services immediately. Learn more about Agreement to Our Legal Terms."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Our Services: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "The Services are intended for use only in jurisdictions where they comply with local laws and are not tailored for specific industry regulations like HIPAA or GLBA. Learn more about Our Services."),
                    ]),
                    const SizedBox(height: 12),
                     _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Intellectual Property: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "We own or license all content and marks on our Services. Your use is for personal, non-commercial purposes only, and any unauthorized use is prohibited. Learn more about Intellectual Property Rights."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'User Conduct: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "You must adhere to specific rules of conduct while using the Services, including not engaging in any prohibited activities or submitting illegal or harmful content, especially concerning AI interactions. Learn more about Prohibited Activities and User Generated Contributions."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Account and Payments: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "You may need to register and provide accurate information. For subscriptions, you agree to specified payment terms, including automatic renewal and our no-refund policy. Learn more about User Registration, Subscriptions, and Payments."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Data and Privacy: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "We are committed to data privacy and security, utilizing Firebase services for hosting, authentication, storage, and database functionalities. Your use of our Services is also governed by our Privacy Policy, which is incorporated into these terms. Learn more about Privacy Policy and User Data."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Dispute Resolution: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "Any disputes will first be attempted to be resolved through informal negotiations for at least 30 days before initiating binding arbitration. Learn more about Dispute Resolution."),
                    ]),
                     const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Limitations: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "We provide the Services \"as-is\" and are not liable for certain damages or interruptions. Your use is at your sole risk. Learn more about Disclaimer and Limitations of Liability."),
                    ]),
                    const SizedBox(height: 12),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Contact Us: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              "For any questions or complaints regarding the Services, you can contact us via the provided details. Learn more about Contact Us."),
                    ]),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('AGREEMENT TO OUR LEGAL TERMS'),
                    _buildParagraph(
                        'This section details your agreement to these Legal Terms by accessing and using our Services. It also outlines our right to update these terms and your responsibility to stay informed of any changes.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('OUR SERVICES'),
                    _buildParagraph(
                        'The information provided when using the Services is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Services from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.'),
                    _buildParagraph(
                        'The Services are not tailored to comply with industry-specific regulations (Health Insurance Portability and Accountability Act (HIPAA), Federal Information Security Management Act (FISMA), etc.), so if your interactions would be subjected to such laws, you may not use the Services. You may not use the Services in a way that would violate the Gramm-Leach-Bliley Act (GLBA).'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('INTELLECTUAL PROPERTY RIGHTS'),
                    _buildSubHeading('Our intellectual property'),
                    _buildParagraph(
                        'We are the owner or the licensee of all intellectual property rights in our Services, including all source code, databases, functionality, software, app designs, audio, video, text, photographs, and graphics in the Services (collectively, the "Content"), as well as the trademarks, service marks, and logos contained therein (the "Marks").'),
                    _buildParagraph(
                        'Our Content and Marks are protected by copyright and trademark laws (and various other intellectual property rights and unfair competition laws) and treaties in the United Kingdom, the United States and around the world.'),
                    _buildParagraph(
                        'The Content and Marks are provided in or through the Services "AS IS" for your personal, non-commercial use only.'),
                    _buildSubHeading('Your use of our Services'),
                    _buildParagraph(
                        'Subject to your compliance with these Legal Terms, including the "PROHIBITED ACTIVITIES" section below, we grant you a non-exclusive, non-transferable, revocable licence to:'),
                    _buildListItem('access the Services; and'),
                    _buildListItem(
                        'download or print a copy of any portion of the Content to which you have properly gained access,'),
                    _buildParagraph('solely for your personal, non-commercial use.'),
                    _buildParagraph(
                        'Except as set out in this section or elsewhere in our Legal Terms, no part of the Services and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.'),
                    _buildParagraph(
                        'If you wish to make any use of the Services, Content, or Marks other than as set out in this section or elsewhere in our Legal Terms, please address your request to: contact@maxaffinity.co.uk. If we ever grant you the permission to post, reproduce, or publicly display any part of our Services or Content, you must identify us as the owners or licensors of the Services, Content, or Marks and ensure that any copyright or proprietary notice appears or is visible on posting, reproducing, or displaying our Content.'),
                    _buildParagraph(
                        'We reserve all rights not expressly granted to you in and to the Services, Content, and Marks.'),
                    _buildParagraph(
                        'Any breach of these Intellectual Property Rights will constitute a material breach of our Legal Terms and your right to use our Services will terminate immediately.'),
                    _buildSubHeading('Your submissions'),
                    _buildParagraph(
                        'Please review this section and the "PROHIBITED ACTIVITIES" section carefully prior to using our Services to understand the (a) rights you give us and (b) obligations you have when you post or upload any content through the Services.'),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'Submissions: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              'By directly sending us any question, comment, suggestion, idea, feedback, or other information about the Services ("Submissions"), you agree to assign to us all intellectual property rights in such Submission. You agree that we shall own this Submission and be entitled to its unrestricted use and dissemination for any lawful purpose, commercial or otherwise, without acknowledgment or compensation to you.'),
                    ]),
                    _buildRichTextParagraph([
                      const TextSpan(
                          text: 'You are responsible for what you post or upload: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text:
                              'By sending us Submissions through any part of the Services you:'),
                    ]),
                    _buildListItem(
                        'confirm that you have read and agree with our "PROHIBITED ACTIVITIES" and will not post, send, publish, upload, or transmit through the Services any Submission that is illegal, harassing, hateful, harmful, defamatory, obscene, bullying, abusive, discriminatory, threatening to any person or group, sexually explicit, false, inaccurate, deceitful, or misleading;'),
                    _buildListItem(
                        'to the extent permissible by applicable law, waive any and all moral rights to any such Submission;'),
                    _buildListItem(
                        'warrant that any such Submission are original to you or that you have the necessary rights and licences to submit such Submissions and that you have full authority to grant us the above-mentioned rights in relation to your Submissions; and'),
                    _buildListItem(
                        'warrant and represent that your Submissions do not constitute confidential information.'),
                    _buildParagraph(
                        'You are solely responsible for your Submissions and you expressly agree to reimburse us for any and all losses that we may suffer because of your breach of (a) this section, (b) any third party\'s intellectual property rights, or (c) applicable law.'),
                    _buildSubHeading('Copyright infringement'),
                    _buildParagraph(
                        'We respect the intellectual property rights of others. If you believe that any material available on or through the Services infringes upon any copyright you own or control, please immediately refer to the "COPYRIGHT INFRINGEMENTS" section below.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('USER REPRESENTATIONS'),
                    _buildParagraph(
                        'By using the Services, you represent and warrant that:'),
                    _buildListItem(
                        '(1) all registration information you submit will be true, accurate, current, and complete;'),
                    _buildListItem(
                        '(2) you will maintain the accuracy of such information and promptly update such registration information as necessary;'),
                    _buildListItem(
                        '(3) you have the legal capacity and you agree to comply with these Legal Terms;'),
                    _buildListItem(
                        '(4) you are not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission to use the Services;'),
                    _buildListItem(
                        '(5) you will not access the Services through automated or non-human means, whether through a bot, script or otherwise;'),
                    _buildListItem(
                        '(6) you will not use the Services for any illegal or unauthorised purpose; and'),
                    _buildListItem(
                        '(7) your use of the Services will not violate any applicable law or regulation.'),
                    _buildParagraph(
                        'If you provide any information that is untrue, inaccurate, not current, or incomplete, we have the right to suspend or terminate your account and refuse any and all current or future use of the Services (or any portion thereof).'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('USER REGISTRATION'),
                    _buildParagraph(
                        'You may be required to register to use the Services. You agree to keep your password confidential and will be responsible for all use of your account and password. We reserve the right to remove, reclaim, or change a username you select if we determine, in our sole discretion, that such username is inappropriate, obscene, or otherwise objectionable.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('PURCHASES AND PAYMENT'),
                     _buildParagraph(
                        "We accept payments via the Apple App Store and Google Play Store's payment processing system."),
                    _buildParagraph(
                        'You agree to provide current, complete, and accurate purchase and account information for all purchases made via the Services. You further agree to promptly update account and payment information, including email address, payment method, and payment card expiration date, so that we can complete your transactions and contact you as needed. Sales tax will be added to the price of purchases as deemed required by us. We may change prices at any time. All payments shall be in the currency specified in the Apple App Store and Google Play Store for your region.'),
                    _buildParagraph(
                        'You agree to pay all charges at the prices then in effect for your purchases and any applicable fees, and you authorise us to charge your chosen payment provider for any such amounts upon placing your order. We reserve the right to correct any errors or mistakes in pricing, even if we have already requested or received payment.'),
                    _buildParagraph(
                        'We reserve the right to refuse any order placed through the Services. We may, in our sole discretion, limit or cancel quantities purchased per person, per household, or per order. These restrictions may include orders placed by or under the same customer account, the same payment method, and/or orders that use the same billing address. We reserve the right to limit or prohibit orders that, in our sole judgement, appear to be placed by dealers, resellers, or distributors.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('SUBSCRIPTIONS'),
                    _buildSubHeading('Billing and Renewal'),
                    _buildParagraph(
                        'Your subscription will continue and automatically renew unless cancelled. You consent to our charging your payment method on a recurring basis without requiring your prior approval for each recurring charge, until such time as you cancel the applicable order. The length of your billing cycle will depend on the type of subscription plan you choose when you subscribed to the Services.'),
                    _buildSubHeading('Free Trial'),
                    _buildParagraph(
                        'We offer a 7-day free trial to new users who register with the Services. The account will be charged according to the user\'s chosen subscription at the end of the free trial period, unless the subscription is cancelled before the trial ends.'),
                    _buildSubHeading('Cancellation and No Refunds'),
                    _buildParagraph(
                        'All purchases are non-refundable. You can cancel your subscription at any time by logging into your account in the Lournal app or through your Google Play Store subscription settings. Your cancellation will take effect at the end of the current paid term. This means you will retain access to the subscription benefits until the end of your current billing cycle, but you will not receive a refund for any portion of the unused term. If you have any questions or are unsatisfied with our Services, please email us at contact@maxaffinity.co.uk.'),
                    _buildSubHeading('Fee Changes'),
                    _buildParagraph(
                        'We may, from time to time, make changes to the subscription fee and will communicate any price changes to you in accordance with applicable law.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('PROHIBITED ACTIVITIES'),
                    _buildParagraph(
                        'You may not access or use the Services for any purpose other than that for which we make the Services available. The Services may not be used in connection with any commercial endeavours except those that are specifically endorsed or approved by us.'),
                    _buildParagraph('As a user of the Services, you agree not to:'),
                    _buildListItem(
                        'Systematically retrieve data or other content from the Services to create or compile, directly or indirectly, a collection, compilation, database, or directory without written permission from us.'),
                    _buildListItem(
                        'Trick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passwords.'),
                    _buildListItem(
                        'Circumvent, disable, or otherwise interfere with security-related features of the Services, including features that prevent or restrict the use or copying of any Content or enforce limitations on the use of the Services and/or the Content contained therein.'),
                    _buildListItem(
                        'Disparage, tarnish, or otherwise harm, in our opinion, us and/or the Services.'),
                    _buildListItem(
                        'Use any information obtained from the Services in order to harass, abuse, or harm another person.'),
                    _buildListItem(
                        'Make improper use of our support services or submit false reports of abuse or misconduct.'),
                    _buildListItem(
                        'Use the Services in a manner inconsistent with any applicable laws or regulations.'),
                    _buildListItem('Engage in unauthorised framing of or linking to the Services.'),
                    _buildListItem(
                        'Upload or transmit viruses, Trojan horses, or other material that interferes with any party\'s uninterrupted use of the Services.'),
                    _buildListItem(
                        'Engage in any automated use of the system, such as using scripts to send comments or messages.'),
                    _buildListItem(
                        'Delete the copyright or other proprietary rights notice from any Content.'),
                    _buildListItem(
                        'Attempt to impersonate another user or person or use the username of another user.'),
                    _buildListItem(
                        'Interfere with, disrupt, or create an undue burden on the Services or connected networks.'),
                    _buildListItem(
                        'Harass, annoy, intimidate, or threaten any of our employees or agents.'),
                    _buildListItem(
                        'Attempt to bypass any measures designed to prevent or restrict access to the Services.'),
                    _buildListItem(
                        'Copy or adapt the Services\' software, including but not limited to Flash, PHP, HTML, JavaScript, or other code.'),
                    _buildListItem(
                        'Use the Services as part of any effort to compete with us or for any revenue-generating endeavour.'),
                    _buildListItem(
                        'Upload, create, store, or transmit any content that is illegal, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, libelous, invasive of another\'s privacy, hateful, racially, ethnically, or otherwise objectionable, especially when interacting with the AI feedback system.'),
                    _buildListItem(
                        'Attempt to manipulate, bypass, or interfere with the functionality, security features, or safety measures of the AI feedback system.'),
                    _buildListItem(
                        'Use automated systems or software to interact with the Services in a manner not typical of human usage.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('PRIVACY POLICY'),
                    _buildParagraph(
                        'We care about data privacy and security. Please review our Privacy Policy: http://www.maxaffinity.co.uk/privacy. By using the Services, you agree to be bound by our Privacy Policy, which is incorporated into these Legal Terms. Please be advised the Services are hosted using Firebase services, which may involve data processing and storage across various global locations. Through your continued use of the Services, you acknowledge and consent to the transfer and processing of your data in accordance with our Privacy Policy and the terms of Firebase.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('DISCLAIMER'),
                    _buildParagraph(
                        'THE SERVICES ARE PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. YOU AGREE THAT YOUR USE OF THE SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SERVICES AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE MAKE NO WARRANTIES OR REPRESENTATIONS ABOUT THE ACCURACY OR COMPLETENESS OF THE SERVICES\' CONTENT OR THE CONTENT OF ANY WEBSITES OR MOBILE APPLICATIONS LINKED TO THE SERVICES AND WE WILL ASSUME NO LIABILITY OR RESPONSIBILITY FOR ANY (1) ERRORS, MISTAKES, OR INACCURACIES OF CONTENT AND MATERIALS, (2) PERSONAL INJURY OR PROPERTY DAMAGE, OF ANY NATURE WHATSOEVER, RESULTING FROM YOUR ACCESS TO AND USE OF THE SERVICES, (3) ANY UNAUTHORISED ACCESS TO OR USE OF OUR SECURE SERVERS AND/OR ANY AND ALL PERSONAL INFORMATION AND/OR FINANCIAL INFORMATION STORED THEREIN, (4) ANY INTERRUPTION OR CESSATION OF TRANSMISSION TO OR FROM THE SERVICES, (5) ANY BUGS, VIRUSES, TROJAN HORSES, OR THE LIKE WHICH MAY BE TRANSMITTED TO OR THROUGH THE SERVICES BY ANY THIRD PARTY, AND/OR (6) ANY ERRORS OR OMISSIONS IN ANY CONTENT AND MATERIALS OR FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF THE USE OF ANY CONTENT POSTED, TRANSMITTED, OR OTHERWISE MADE AVAILABLE VIA THE SERVICES.'),
                     const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('LIMITATIONS OF LIABILITY'),
                    _buildParagraph(
                        'IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE SERVICES, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. NOTWITHSTANDING ANYTHING TO THE CONTRARY CONTAINED HEREIN, OUR LIABILITY TO YOU FOR ANY CAUSE WHATSOEVER AND REGARDLESS OF THE FORM OF THE ACTION, WILL AT ALL TIMES BE LIMITED TO THE LESSER OF THE AMOUNT PAID, IF ANY, BY YOU TO US DURING THE SIX (6) MONTH PERIOD PRIOR TO ANY CAUSE OF ACTION ARISING.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('DISPUTE RESOLUTION'),
                    _buildSubHeading('Informal Negotiations'),
                    _buildParagraph(
                        'To expedite resolution and control the cost of any dispute, controversy, or claim related to these Legal Terms (each a "Dispute" and collectively, the "Disputes") brought by either you or us (individually, a "Party" and collectively, the "Parties"), the Parties agree to first attempt to negotiate any Dispute (except those Disputes expressly provided below) informally for at least thirty (30) days before initiating arbitration. Such informal negotiations commence upon written notice from one Party to the other Party.'),
                    _buildSubHeading('Binding Arbitration'),
                     _buildParagraph(
                        'Any dispute arising from the relationships between the Parties to these Legal Terms shall be determined by one arbitrator who will be chosen in accordance with the Arbitration and Internal Rules of the European Court of Arbitration being part of the European Centre of Arbitration having its seat in Strasbourg, and which are in force at the time the application for arbitration is filed, and of which adoption of this clause constitutes acceptance. The seat of arbitration shall be Bristol, England. The language of the proceedings shall be English. Applicable rules of substantive law shall be the law of England.'),
                    _buildSubHeading('Restrictions'),
                     _buildParagraph(
                        'The Parties agree that any arbitration shall be limited to the Dispute between the Parties individually. To the full extent permitted by law, (a) no arbitration shall be joined with any other proceeding; (b) there is no right or authority for any Dispute to be arbitrated on a class-action basis or to utilise class action procedures; and (c) there is no right or authority for any Dispute to be brought in a purported representative capacity on behalf of the general public or any other persons.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('GOVERNING LAW'),
                     _buildParagraph(
                        'These Legal Terms are governed by and interpreted following the laws of the United Kingdom, and the use of the United Nations Convention of Contracts for the International Sales of Goods is expressly excluded. If your habitual residence is in the EU, and you are a consumer, you additionally possess the protection provided to you by obligatory provisions of the law in your country to residence. MAXAFFINITY LTD and yourself both agree to submit to the non-exclusive jurisdiction of the courts of England, United Kingdom, which means that you may make a claim to defend your consumer protection rights in regards to these Legal Terms in the United Kingdom, or in the EU country in which you reside.'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildHeading('CONTACT US'),
                    _buildParagraph(
                        'In order to resolve a complaint regarding the Services or to receive further information regarding use of the Services, please contact us at: Email: contact@maxaffinity.co.uk'),

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