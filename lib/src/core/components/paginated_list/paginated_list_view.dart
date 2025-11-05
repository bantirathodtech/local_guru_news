import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

/// Reusable Paginated List View with lazy loading
/// 
/// Features:
/// - Infinite scroll pagination
/// - Pull-to-refresh
/// - Loading indicators
/// - Error handling
/// - Empty state handling
/// 
/// Usage:
/// ```dart
/// PaginatedListView<PostsModel>(
///   items: posts,
///   isLoading: isLoading,
///   hasError: hasError,
///   errorMessage: errorMessage,
///   onLoadMore: () => loadMorePosts(),
///   onRefresh: () => refreshPosts(),
///   itemBuilder: (context, index, item) => NewsCard(post: item),
///   loadingWidget: NewsShimmer(),
///   emptyWidget: EmptyState(),
///   errorWidget: ErrorWidget(message: errorMessage),
/// )
/// ```
class PaginatedListView<T> extends StatelessWidget {
  /// List of items to display
  final List<T> items;

  /// Whether data is currently loading
  final bool isLoading;

  /// Whether there's an error
  final bool hasError;

  /// Error message to display
  final String? errorMessage;

  /// Callback when reaching end of list (for loading more)
  final VoidCallback? onLoadMore;

  /// Callback for pull-to-refresh
  final Future<void> Function()? onRefresh;

  /// Builder for each item in the list
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// Widget to show while loading initial data
  final Widget? loadingWidget;

  /// Widget to show when list is empty
  final Widget? emptyWidget;

  /// Widget to show on error
  final Widget? errorWidget;

  /// Widget to show at bottom while loading more
  final Widget? loadingMoreWidget;

  /// Scroll physics for the list
  final ScrollPhysics? physics;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Whether to show loading indicator at bottom
  final bool showLoadingMore;

  /// Separator widget between items
  final Widget? separator;

  /// Shrink wrap the list (for nested scroll views)
  final bool shrinkWrap;

  /// Scroll controller (optional)
  final ScrollController? controller;

  const PaginatedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onLoadMore,
    this.onRefresh,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.loadingMoreWidget,
    this.physics,
    this.padding,
    this.showLoadingMore = true,
    this.separator,
    this.shrinkWrap = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show loading widget if initial load and no items
    if (isLoading && items.isEmpty) {
      return loadingWidget ?? _defaultLoadingWidget();
    }

    // Show error widget if error and no items
    if (hasError && items.isEmpty) {
      return errorWidget ??
          _defaultErrorWidget(errorMessage ?? 'An error occurred');
    }

    // Show empty widget if no items
    if (items.isEmpty && !isLoading) {
      return emptyWidget ?? _defaultEmptyWidget();
    }

    // Build list with lazy loading
    Widget listView = ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      padding: padding ?? EdgeInsets.zero,
      itemCount: items.length + (showLoadingMore && isLoading ? 1 : 0),
      separatorBuilder: separator != null
          ? (context, index) => separator!
          : (context, index) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        // Show loading indicator at bottom
        if (index >= items.length) {
          return loadingMoreWidget ?? _defaultLoadingMoreWidget();
        }

        return itemBuilder(context, index, items[index]);
      },
    );

    // Wrap with lazy load scroll view if onLoadMore is provided
    if (onLoadMore != null) {
      listView = LazyLoadScrollView(
        onEndOfPage: onLoadMore!,
        scrollOffset: 200, // Load more when 200px from bottom
        child: listView,
      );
    }

    // Wrap with refresh indicator if onRefresh is provided
    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _defaultLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultLoadingMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

