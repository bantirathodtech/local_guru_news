import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

class GreetingsDashboard extends ConsumerStatefulWidget {
  const GreetingsDashboard({Key? key}) : super(key: key);

  @override
  _GreetingsDashboardState createState() => _GreetingsDashboardState();
}

class _GreetingsDashboardState extends ConsumerState<GreetingsDashboard> {
  _loadMore() {
    ref.read(greetingsPaginationControllerProvider.notifier).getGreetings();
  }

  ScreenshotController screenshotController = ScreenshotController();
  Box<String> box = Hive.box('user');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(topicsGreetingsControllerProvider);
    final topicsState =
        ref.watch(topicsGreetingsControllerProvider.notifier).state;
    ref.watch(greetingsPaginationControllerProvider);
    final greetingsState =
        ref.watch(greetingsPaginationControllerProvider.notifier).state;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Greetings',
          backgroundColor: AppColors.primary,
          iconColor: AppColors.black,
          titleColor: AppColors.black,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(65),
            child: Container(
              height: 65,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Builder(
                builder: (context) {
                  if (topicsState.refreshError) {
                    return ErrorBody(
                      message: topicsState.errorMessage,
                    );
                  } else if (topicsState.topics!.isEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: 5,
                      itemBuilder: (context, snapshot) {
                        return Container(
                          width: 100.0,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: topicsState.topics!.length,
                      itemBuilder: (context, index) {
                        return GreetingsTopicListComponent(
                          id: topicsState.topics![index].id,
                          category: topicsState.topics![index].category,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ),
        drawer: const CustomDrawer(),
        body: Stack(
          children: [
            // Greetings List
            Builder(
              builder: (context) {
                if (greetingsState.refreshError) {
                  return ErrorBody(
                    message: greetingsState.errorMessage,
                  );
                } else if (greetingsState.greetings!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.smileBeam,
                          size: 40.sp,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Fetching Greetings',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return LazyLoadScrollView(
                    onEndOfPage: _loadMore,
                    child: RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: () {
                        ref
                            .read(
                                greetingsPaginationControllerProvider.notifier)
                            .resetGreetings();
                        return ref
                            .read(
                                greetingsPaginationControllerProvider.notifier)
                            .getGreetings();
                      },
                      child: GridView.builder(
                        padding: EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: greetingsState.greetings!.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _GreetingCard(
                            greeting: greetingsState.greetings![index],
                            screenshotController: screenshotController,
                            onShare: () async {
                              setState(() {
                                _loading = true;
                              });
                              // ... existing share logic
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),

            // Loading Overlay
            if (_loading)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preparing your image for sharing...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final GreetingsModel greeting;
  final ScreenshotController screenshotController;
  final VoidCallback onShare;

  const _GreetingCard({
    required this.greeting,
    required this.screenshotController,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              greeting.image!,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),

          // Watermark
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/local_guru.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),

          // Share Button
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onShare,
                icon: Icon(
                  FontAwesomeIcons.shareAlt,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
