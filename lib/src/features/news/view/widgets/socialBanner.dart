import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../src.dart';

class SocialBanner extends ConsumerStatefulWidget {
  final String? id;
  final int? index;
  final String? whatsCount;
  final String? likes;
  final String? dislikes;
  final String? liked;
  final String? comments;
  final String? title;
  final String? image;
  final String? description;
  final String? layout;
  final bool? single;

  const SocialBanner({
    Key? key,
    required this.id,
    required this.index,
    required this.whatsCount,
    this.likes,
    this.dislikes,
    this.liked,
    this.comments,
    this.title,
    this.image,
    this.layout,
    this.single,
    this.description,
  }) : super(key: key);

  @override
  _SocialBannerState createState() => _SocialBannerState();
}

class _SocialBannerState extends ConsumerState<SocialBanner>
    with SingleTickerProviderStateMixin {
  Box<String> box = Hive.box('user');
  late AnimationController _animationController;
  int? _currentHoverIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id ?? '';
    
    // Watch the state to get real-time updates for likes/dislikes
    String likes = widget.likes ?? '0';
    String dislikes = widget.dislikes ?? '0';
    String liked = widget.liked ?? '';
    
    // Watch state for real-time updates (batch updates handled by Riverpod)
    if (widget.single!) {
      // Single post view - watch postIndividualControllerProvider
      final individualState = ref.watch(postIndividualControllerProvider);
      if (individualState.posts != null && 
          individualState.posts!.isNotEmpty) {
        final post = individualState.posts![0];
        if (post.id == id) {
          likes = post.likes ?? '0';
          dislikes = post.dislikes ?? '0';
          liked = post.liked ?? '0';
        }
      }
    } else {
      // List view - watch legacyPostPaginationControllerProvider
      final paginationState = ref.watch(legacyPostPaginationControllerProvider);
      if (paginationState.posts != null && 
          widget.index != null && 
          widget.index! >= 0 && 
          widget.index! < paginationState.posts!.length) {
        final post = paginationState.posts![widget.index!];
        if (post.id == id) {
          likes = post.likes ?? '0';
          dislikes = post.dislikes ?? '0';
          liked = post.liked ?? '0';
        }
      }
    }
    
    final comments = widget.comments ?? '0';
    final whatsCount = widget.whatsCount ?? '0';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimatedButton(
                index: 0,
                icon: 'assets/icons/like.svg',
                activeIcon: 'assets/icons/like.svg',
                label: 'నచ్చింది',
                count: likes,
                isActive: liked == '1',
                activeColor: Color(0xFF1976D2), // Material Blue 700
                inactiveColor: isDark
                    ? Colors.grey.shade400
                    : Color(0xFF757575), // Material Grey 600
                onTap: () => _handleLikeDislike(1),
              ),
              _buildAnimatedButton(
                index: 1,
                icon: 'assets/icons/dislike.svg',
                activeIcon: 'assets/icons/dislike.svg',
                label: 'నచ్చలేదు',
                count: dislikes,
                isActive: liked == '-1',
                activeColor: Color(0xFFD32F2F), // Material Red 700
                inactiveColor: isDark
                    ? Colors.grey.shade400
                    : Color(0xFF757575),
                onTap: () => _handleLikeDislike(-1),
              ),
              _buildAnimatedButton(
                index: 2,
                icon: 'assets/icons/comment.svg',
                activeIcon: 'assets/icons/comment.svg',
                label: 'వ్యాఖ్యలు',
                count: comments,
                isActive: false,
                activeColor: Color(0xFFF57C00), // Material Orange 700
                inactiveColor: isDark
                    ? Colors.grey.shade400
                    : Color(0xFF757575),
                onTap: () {
                  ref.read(postid.notifier).state = id;
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CommentsScreen(
                        index: widget.index,
                        single: widget.single!,
                        id: id,
                      ),
                      transitionDuration: Duration(milliseconds: 300),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              _buildAnimatedButton(
                index: 3,
                icon: 'assets/icons/whatsapp.svg',
                activeIcon: 'assets/icons/whatsapp.svg',
                label: 'WhatsApp',
                count: whatsCount,
                isActive: false,
                activeColor: Color(0xFF25D366), // WhatsApp Green
                inactiveColor: isDark
                    ? Colors.grey.shade400
                    : Color(0xFF757575),
                onTap: () async {
                  AppLogger.logInfo(
                    'Legacy WhatsApp share tapped id=$id',
                    tag: 'legacyNewsView',
                  );
                  // Show WhatsApp numbers dialog with share_plus option
                  await _showWhatsAppShareOptions(context, id);
                },
              ),
              _buildMoreOptionsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required int index,
    required String icon,
    required String activeIcon,
    required String label,
    required String count,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHovered = _currentHoverIndex == index;
    // Always show count for likes and dislikes to provide feedback
    final hasCount = true; // Always display count

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: activeColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.12)
                  : isHovered
                      ? inactiveColor.withOpacity(0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated scale and background
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.18)
                        : isHovered
                            ? inactiveColor.withOpacity(0.08)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: activeColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: isHovered ? 1.1 : 1.0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: SvgPicture.asset(
                      isActive ? activeIcon : icon,
                      width: 18.sp,
                      height: 18.sp,
                      colorFilter: ColorFilter.mode(
                        isActive ? activeColor : inactiveColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2),
                // Count and label with better spacing
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasCount)
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: isActive ? activeColor : inactiveColor,
                          height: 1.0,
                          letterSpacing: -0.2,
                        ),
                        child: Text(
                          _formatCount(count),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (hasCount) SizedBox(height: 1),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? activeColor
                            : (isDark
                                ? Colors.grey.shade400
                                : AppColors.textSecondary).withOpacity(0.8),
                        height: 1.1,
                        letterSpacing: 0.1,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHovered = _currentHoverIndex == 4;
    final greyColor = isDark ? Colors.grey.shade600 : Colors.grey;
    final textColor = isDark
        ? Colors.grey.shade400
        : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMoreOptions(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: greyColor.withOpacity(0.1),
          highlightColor: greyColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? greyColor.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedScale(
                    scale: isHovered ? 1.1 : 1.0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: SvgPicture.asset(
                      'assets/icons/more.svg',
                      width: 18.sp,
                      height: 18.sp,
                      colorFilter: ColorFilter.mode(
                        textColor.withOpacity(0.8),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.8),
                    height: 1.1,
                    letterSpacing: 0.1,
                  ),
                  child: Text(
                    'More',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(String count) {
    final numCount = int.tryParse(count) ?? 0;
    if (numCount >= 1000000) {
      return '${(numCount / 1000000).toStringAsFixed(1)}M';
    } else if (numCount >= 1000) {
      return '${(numCount / 1000).toStringAsFixed(1)}K';
    }
    return numCount.toString();
  }

  void _showMoreOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildOptionTile(
                        icon: Icons.share_rounded,
                        title: 'Share via other apps',
                        color: Colors.blue.shade600,
                        onTap: () async {
                          // Generate news link and share via share_plus
                          final newsLink = _generateNewsLink(widget.id ?? '');
                          await _shareToWhatsApp(
                            widget.title ?? 'Check out this news',
                            newsLink,
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          return Divider(
                            height: 1,
                            thickness: 0.5,
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          );
                        },
                      ),
                      _buildOptionTile(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Save post',
                        color: Colors.purple.shade600,
                        onTap: () {
                          // Show message that feature is not implemented yet
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'This feature is not implemented yet. Very soon will be added.',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.orange.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          return Divider(
                            height: 1,
                            thickness: 0.5,
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          );
                        },
                      ),
                      _buildOptionTile(
                        icon: Icons.link_rounded,
                        title: 'Copy link',
                        color: Colors.green.shade600,
                        onTap: () async {
                          // Generate news link and copy to clipboard
                          final newsLink = _generateNewsLink(widget.id ?? '');
                          await Clipboard.setData(ClipboardData(text: newsLink));
                          
                          // Show confirmation snackbar
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Link copied to clipboard',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          return Divider(
                            height: 1,
                            thickness: 0.5,
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          );
                        },
                      ),
                      _buildOptionTile(
                        icon: Icons.flag_outlined,
                        title: 'Report post',
                        color: Colors.red.shade600,
                        onTap: () {
                          // Show message that feature is not implemented yet
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'This feature is not implemented yet. Very soon will be added.',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.orange.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
      ),
      onTap: () {
        Navigator.pop(context);
        // Handle option selection
        onTap?.call();
      },
    );
  }

  Future<void> _handleLikeDislike(int value) async {
    // Check if user is logged in using Riverpod provider (more reliable)
    final userId = ref.read(userIdProvider);
    final isLoggedIn = userId.isNotEmpty && userId != '0' && userId != 'null';
    
    AppLogger.logInfo(
      'Like/dislike check - userId=$userId, isLoggedIn=$isLoggedIn',
      tag: 'legacyNewsView',
    );
    
    if (isLoggedIn) {
      if (widget.single!) {
        await ref
            .read(postIndividualControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      } else {
        AppLogger.logInfo(
          'Legacy like/dislike action value=$value post=${widget.id} userId=$userId',
          tag: 'legacyNewsView',
        );
        await ref
            .read(legacyPostPaginationControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      }
    } else {
      AppLogger.logWarning(
        'Like/dislike blocked - user not logged in. userId=$userId',
        tag: 'legacyNewsView',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You must Login to ${value == 1 ? 'Like' : 'Dislike'} this Post",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              // Handle login navigation
            },
          ),
        ),
      );
    }
  }

  /// Generate news article link
  String _generateNewsLink(String postId) {
    // Generate the news article link
    // Format: https://localguru.in/news/post/{id}
    return 'https://localguru.in/news/post/$postId';
  }

  /// Share news using share_plus (opens native share sheet)
  Future<void> _shareToWhatsApp(String title, String url) async {
    try {
      final text = "$title\n\nRead more: $url";
      await Share.share(
        text,
        subject: title,
      );
      
      // Increment share count after successful share
      final id = widget.id ?? '';
      final whatsCount = widget.whatsCount ?? '0';
      widget.single!
          ? await ref
              .read(postIndividualControllerProvider.notifier)
              .whatsShare(id, whatsCount, widget.index!)
          : await ref
              .read(legacyPostPaginationControllerProvider.notifier)
              .whatsShare(id, whatsCount, widget.index!);
    } catch (e) {
      AppLogger.logError(
        'Error sharing via share_plus: $e',
        tag: 'legacyNewsView',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Show WhatsApp share options dialog
  Future<void> _showWhatsAppShareOptions(BuildContext context, String postId) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Generate news link
    final newsLink = _generateNewsLink(postId);
    final shareMessage = '${widget.title ?? "Check out this news"}\n\n$newsLink';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF25D366).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/whatsapp.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF25D366),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share via WhatsApp',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Share via apps or open WhatsApp directly',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Open WhatsApp app directly button
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Open WhatsApp app directly (without selecting a number)
                        await _openWhatsAppApp(shareMessage);
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/whatsapp.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        'Open WhatsApp Directly',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Open WhatsApp app directly (user selects contact)
  Future<void> _openWhatsAppApp(String message) async {
    try {
      // Open WhatsApp with message (user will select contact)
      final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
      
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      AppLogger.logError(
        'Error opening WhatsApp app: $e',
        tag: 'legacyNewsView',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}

