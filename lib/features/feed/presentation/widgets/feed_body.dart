import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../decisions/presentation/providers/decision_providers.dart';
import '../../../discover/presentation/widgets/discover_feed.dart';
import '../providers/feed_providers.dart';
import 'feed_list.dart';

class FeedBody extends ConsumerStatefulWidget {
  const FeedBody({super.key, required this.currentUid});

  final String? currentUid;

  @override
  ConsumerState<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends ConsumerState<FeedBody> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Para vos'),
            Tab(text: 'Tendencias'),
            Tab(text: 'Siguiendo'),
            Tab(text: 'Descubrir'),
          ],
        ),
        categoriesAsync.when(
          data: (categories) => SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategory == category.id,
                      onSelected: (_) => setState(() => _selectedCategory = category.id),
                    ),
                  ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FeedList(
                decisionsAsync: _selectedCategory == null
                    ? ref.watch(recentFeedProvider)
                    : ref.watch(categoryFeedProvider(_selectedCategory!)),
                emptyMessage: 'Todavía no hay decisiones.\n¡Creá la primera!',
              ),
              FeedList(
                decisionsAsync: ref.watch(trendingFeedProvider),
                emptyMessage: 'Todavía no hay actividad suficiente.',
              ),
              widget.currentUid == null
                  ? const Center(child: Text('Iniciá sesión para ver esto.'))
                  : FeedList(
                      decisionsAsync: ref.watch(followingFeedProvider(widget.currentUid!)),
                      emptyMessage: 'Seguí a otros usuarios para ver sus decisiones acá.',
                    ),
              DiscoverFeed(currentUid: widget.currentUid),
            ],
          ),
        ),
      ],
    );
  }
}
