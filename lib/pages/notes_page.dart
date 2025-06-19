import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lournal/components/my_bottom_bar.dart';
import 'package:lournal/components/note_tile.dart';
import 'package:lournal/components/profile_bottomsheet.dart';
import 'package:lournal/components/show_filter_bottomsheet.dart';
import 'package:lournal/services/firestore.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // search controller & current query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // TYPE filter keys
  static const _typeKeys = [
    'Diary',
    'Gratitude',
    'Dreams',
    'Study/Work',
    'Goals',
    'Travel',
    'Creative Writing',
    'Health & Fitness',
    'Conversations',
  ];
  Set<String> _selectedTypes = {};

  // LANGUAGE filter keys
  static const _languageKeys = [
    'English',
    'Spanish',
    'Portuguese',
    'French',
    'German',
    'Italian',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean',
    'Dutch',
    'Arabic',
    'Hindi',
    'Swahili',
    'Swedish',
    'Turkish',
  ];
  Set<String> _selectedLanguages = {};

  String _formatHeaderDate(DateTime dt) {
    final now = DateTime.now();
    final aDate = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (aDate == today) return 'Today, ' + DateFormat('d MMM').format(dt);
    if (aDate == yesterday) return 'Yesterday, ' + DateFormat('d MMM').format(dt);
    return DateFormat('EEEE, d MMM').format(dt);
  }

  void _onFilterTap() async {
    final initialSelection = {
      ..._selectedTypes,
      ..._selectedLanguages,
    };
    final result = await showFilterBottomSheet(
      context,
      initialSelection: initialSelection,
    );
    if (result is Map<String, bool>) {
      setState(() {
        _selectedTypes = result.entries
            .where((e) => _typeKeys.contains(e.key) && e.value)
            .map((e) => e.key)
            .toSet();
        _selectedLanguages = result.entries
            .where((e) => _languageKeys.contains(e.key) && e.value)
            .map((e) => e.key)
            .toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      // Use extendBodyBehindAppBar to make the body extend behind the app bar area
      extendBodyBehindAppBar: true,
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          MyBottomBar.showMakerSheet(
            context,
            defaultLanguage: "Spanish",
          );
        },
        child: const Icon(Icons.add),
      ),

      // Replace the Column with CustomScrollView for slivers
      body: SafeArea(
        // Set top to false so we can handle the top safe area with the SliverAppBar
        top: true,
        bottom: false, // Set to false, we'll handle bottom padding with a Sliver
        child: CustomScrollView(
          slivers: [
          // SliverAppBar with Instagram-style safe area handling
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            floating: true,
            pinned: false, // Pin the app bar to preserve status bar safe area
            snap: false, // Disable snap when using pinned
            expandedHeight: 60, // Provide room for content
            // Force the app bar to respect the safe area
            toolbarHeight: 56,
            collapsedHeight: 56,
            forceElevated: true,
            // Add bottom padding to account for status bar height
            flexibleSpace: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            ),
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Material(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _onFilterTap,
                    child: const Center(
                      child: Icon(
                        Icons.filter_list,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        profileBottomSheet(context);
                      },
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Search bar in a SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.tertiary,
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search your Lournals…',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
          ),

          // Notes List using SliverList
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNotesStream(),
            builder: (context, snapshot) {
              // Show loading indicator if data is still loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              // Handle error state
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error loading notes: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              // Check if we have data but it's empty
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              // client‑side filtering: type, language, search
              final filteredDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data()! as Map<String, dynamic>;
                final noteType = (data['type'] as String?) ?? '';
                final noteLanguage = (data['language'] as String?) ?? '';
                final title = ((data['title'] ?? '') as String).toLowerCase();
                final content = ((data['content'] ?? '') as String).toLowerCase();

                if (_selectedTypes.isNotEmpty &&
                    !_selectedTypes.contains(noteType)) {
                  return false;
                }
                if (_selectedLanguages.isNotEmpty &&
                    !_selectedLanguages.contains(noteLanguage)) {
                  return false;
                }
                if (_searchQuery.isNotEmpty &&
                    !title.contains(_searchQuery) &&
                    !content.contains(_searchQuery)) {
                  return false;
                }
                return true;
              }).toList();
              
              // Show empty state if filteredDocs is empty
              if (filteredDocs.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyStateForFilters(),
                );
              }

              // Convert ListView.builder to SliverList
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final data = filteredDocs[i].data()! as Map<String, dynamic>;
                    final ts = data['timestamp'] as Timestamp;
                    final thisDate = ts.toDate();

                    // show header if date changed
                    bool showHeader = false;
                    if (i == 0) {
                      showHeader = true;
                    } else {
                      final prevTs = (filteredDocs[i - 1].data()! as Map<String, dynamic>)['timestamp'] as Timestamp;
                      final prevDate = prevTs.toDate();
                      if (prevDate.year != thisDate.year ||
                          prevDate.month != thisDate.month ||
                          prevDate.day != thisDate.day) {
                        showHeader = true;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 32,
                              bottom: 5,
                            ),
                            child: Text(
                              _formatHeaderDate(thisDate),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        NotesTile(
                          docId: filteredDocs[i].id,
                          title: data['title'] ?? 'Untitled',
                          content: data['content'] ?? '',
                          translation: data['translation'] ?? '',
                          feedback: data['feedback'] ?? '',
                          type: data['type'] ?? 'text',
                          language: data['language'] ?? '',
                          score: data['score'] ?? 0,
                          onDeletePressed: () => firestoreService.deleteNote(filteredDocs[i].id),
                          onEditPressed: () {},
                        ),
                      ],
                    );
                  },
                  childCount: filteredDocs.length,
                ),
              );
            },
          ),
          // SliverToBoxAdapter for bottom padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80.0, // Adjust this value to your desired padding
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  // Empty state widget when no notes exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48.0, right: 64.0, left: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.sticky_note_2_rounded,
                size: 100,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Start Your Journey!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Write In A Language You're Learning",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Empty state widget when filtered notes are empty
  Widget _buildEmptyStateForFilters() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48.0, right: 64.0, left: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.filter_alt_off,
                size: 100,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Matching Lournals!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try Changing Your Search Criteria Or Filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}