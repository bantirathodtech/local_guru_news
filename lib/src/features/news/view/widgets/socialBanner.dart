import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

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
    final likes = widget.likes ?? '0';
    final dislikes = widget.dislikes ?? '0';
    final comments = widget.comments ?? '0';
    final whatsCount = widget.whatsCount ?? '0';
    final liked = widget.liked ?? '';

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
                inactiveColor: Color(0xFF757575), // Material Grey 600
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
                inactiveColor: Color(0xFF757575),
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
                inactiveColor: Color(0xFF757575),
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
                inactiveColor: Color(0xFF757575),
                onTap: () async {
                  widget.single!
                      ? await ref
                          .read(postIndividualControllerProvider.notifier)
                          .whatsShare(id, whatsCount, widget.index!)
                      : await ref
                          .read(postPaginationControllerProvider.notifier)
                          .whatsShare(id, whatsCount, widget.index!);
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
    final isHovered = _currentHoverIndex == index;
    final numCount = int.tryParse(count) ?? 0;
    final hasCount = numCount > 0;

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
                            : AppColors.textSecondary.withOpacity(0.8),
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
    final isHovered = _currentHoverIndex == 4;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMoreOptions(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.05),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? Colors.grey.withOpacity(0.08)
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
                    color: Colors.grey.withOpacity(0.1),
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
                        AppColors.textSecondary.withOpacity(0.8),
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
                    color: AppColors.textSecondary.withOpacity(0.8),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
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
                    color: Colors.grey.shade300,
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
                      ),
                      Divider(height: 1, thickness: 0.5),
                      _buildOptionTile(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Save post',
                        color: Colors.purple.shade600,
                      ),
                      Divider(height: 1, thickness: 0.5),
                      _buildOptionTile(
                        icon: Icons.link_rounded,
                        title: 'Copy link',
                        color: Colors.green.shade600,
                      ),
                      Divider(height: 1, thickness: 0.5),
                      _buildOptionTile(
                        icon: Icons.flag_outlined,
                        title: 'Report post',
                        color: Colors.red.shade600,
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
  }) {
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
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      onTap: () {
        Navigator.pop(context);
        // Handle option selection
      },
    );
  }

  Future<void> _handleLikeDislike(int value) async {
    if (box.containsKey('id') && box.get('id') != null) {
      if (widget.single!) {
        await ref
            .read(postIndividualControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      } else {
        await ref
            .read(postPaginationControllerProvider.notifier)
            .likes(int.parse(widget.id!), 'post', value, widget.index!);
      }
    } else {
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
}
