import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lournal/helper/date_format_helper.dart';
import 'package:provider/provider.dart';
import 'package:lournal/components/my_bottom_bar.dart';
import 'package:lournal/components/note_tile.dart';
import 'package:lournal/sheets/profile_bottomsheet.dart';
import 'package:lournal/sheets/show_filter_bottomsheet.dart';
import 'package:lournal/providers/notes_provider.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  // Filter keys remain as constants
  static const _typeKeys = [
    'Diary', 'Gratitude', 'Dreams', 'Study/Work', 'Goals', 'Travel', 
    'Creative Writing', 'Health & Fitness', 'Conversations',
  ];
  static const _languageKeys = [
    'English', 'Spanish', 'Portuguese', 'French', 'German', 'Italian', 'Russian', 
    'Chinese', 'Japanese', 'Korean', 'Dutch', 'Arabic', 'Hindi', 'Swahili', 'Swedish', 'Turkish',
  ];


  void _onFilterTap(BuildContext context) async {
    // Use `context.read` here because we are not rebuilding based on this, just calling a method.
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    // ... rest of the method is the same
    final initialSelection = {
      ...notesProvider.selectedTypes,
      ...notesProvider.selectedLanguages,
    };

    final result = await showFilterBottomSheet(
      context,
      initialSelection: initialSelection,
    );

    if (result is Map<String, bool>) {
      final newSelectedTypes = result.entries
          .where((e) => _typeKeys.contains(e.key) && e.value)
          .map((e) => e.key)
          .toSet();
      final newSelectedLanguages = result.entries
          .where((e) => _languageKeys.contains(e.key) && e.value)
          .map((e) => e.key)
          .toSet();
      
      notesProvider.updateFilters(newSelectedTypes, newSelectedLanguages);
    }
  }

  @override
  Widget build(BuildContext context) {
    // No longer using context.watch here! This is the key change.
    // The main page structure will not rebuild on provider notifications.
    final notesProvider = context.read<NotesProvider>();
    final searchController = TextEditingController(text: notesProvider.searchQuery);
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        // ... same as before
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          MyBottomBar.showMakerSheet(context, defaultLanguage: "Spanish");
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              // ... same as before
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: false,
              expandedHeight: 60,
              toolbarHeight: 56,
              collapsedHeight: 56,
              forceElevated: true,
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
                      onTap: () => _onFilterTap(context),
                      child: const Center(child: Icon(Icons.filter_list, size: 20, color: Colors.white)),
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
                        key: const Key('profile_button'),
                        customBorder: const CircleBorder(),
                        onTap: () => profileBottomSheet(context),
                        child: const Center(child: Icon(Icons.person, size: 20, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.tertiary,
                  controller: searchController,
                  // Use context.read to call the method without subscribing
                  onChanged: (value) => context.read<NotesProvider>().updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search your Lournals…',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
            // *** THE BIG CHANGE: Delegate list building to a dedicated widget ***
            const _NotesList(), 
            const SliverToBoxAdapter(
              child: SizedBox(height: 120.0), // Padding for the FAB
            ),
          ],
        ),
      ),
    );
  }
  
  // Empty state widgets are now moved into _NotesList where they are used.
}

// *** SIMPLIFIED DEDICATED WIDGET FOR THE LIST ***
class _NotesList extends StatelessWidget {
  const _NotesList();

  @override
  Widget build(BuildContext context) {
    // This widget still watches, but now it receives a complete state.
    final notesProvider = context.watch<NotesProvider>();

    // Handle loading and error states from the provider
    if (notesProvider.isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (notesProvider.hasError) {
      return SliverFillRemaining(child: Center(child: Text(notesProvider.error!, style: const TextStyle(color: Colors.red))));
    }
    
    // Get the final, pre-filtered list directly from the provider
    final filteredDocs = notesProvider.filteredNotes;

    // Handle the empty states
    if (notesProvider.searchQuery.isEmpty && notesProvider.selectedTypes.isEmpty && notesProvider.selectedLanguages.isEmpty) {
      if (filteredDocs.isEmpty) {
        return SliverFillRemaining(child: _buildEmptyState(context));
      }
    } else {
      if (filteredDocs.isEmpty) {
         return SliverFillRemaining(child: _buildEmptyStateForFilters(context));
      }
    }

    // Build the list, same as before
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final doc = filteredDocs[i];
          final data = doc.data()! as Map<String, dynamic>;
          final ts = data['timestamp'] as Timestamp;
          final thisDate = ts.toDate();

          bool showHeader = false;
          if (i == 0) {
            showHeader = true;
          } else {
            final prevTs = (filteredDocs[i - 1].data()! as Map<String, dynamic>)['timestamp'] as Timestamp;
            if (thisDate.day != prevTs.toDate().day ||
                thisDate.month != prevTs.toDate().month ||
                thisDate.year != prevTs.toDate().year) {
              showHeader = true;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 5),
                  // Assuming you have this helper function available
                  child: Text(formatHeaderDate(thisDate), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              NotesTile(
                docId: doc.id,
                title: data['title'] ?? 'Untitled',
                content: data['content'] ?? '',
                translation: data['translation'] ?? '',
                feedback: data['feedback'] ?? '',
                type: data['type'] ?? 'text',
                language: data['language'] ?? '',
                score: data['score'] ?? 0,
                onDeletePressed: () => context.read<NotesProvider>().deleteNote(doc.id),
                onEditPressed: () { /* Your edit logic here */ },
              ),
            ],
          );
        },
        childCount: filteredDocs.length,
      ),
    );
  }
}
  
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 48.0, right: 64.0, left: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(Icons.sticky_note_2_rounded, size: 100, color: Theme.of(context).colorScheme.tertiary),
          ),
          const SizedBox(height: 14),
          const Text('Start Your Journey!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Write In A Language You're Learning", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

Widget _buildEmptyStateForFilters(BuildContext context) {
  // ... same as before
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 48.0, right: 64.0, left: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(Icons.filter_alt_off, size: 100, color: Theme.of(context).colorScheme.tertiary),
          ),
          const SizedBox(height: 14),
          const Text('No Matching Lournals!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Try Changing Your Search Criteria Or Filters', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
        ],
      ),
    ),
  );
}
