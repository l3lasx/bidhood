import 'package:bidhood/providers/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserLayout extends ConsumerWidget {
  final Widget bodyWidget;
  final Color mainColor = const Color(0xFF0A9830);
  final bool showBackButton;
  const UserLayout(
      {super.key, required this.bodyWidget, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.userData == null) {
      return const Scaffold(
        body: Center(child: Text('User data not available')),
      );
    }

    final userData = authState.userData!;
    final bool isRider = userData['role'] == 'Rider';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: context.canPop() && showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => {
                  if (context.canPop())
                    {context.pop()}
                  else
                    {GoRouter.of(context).go('/onboarding')}
                },
              )
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (!context.canPop()) ...[
                  const Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BidHood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
            GestureDetector(
              onTap: () {
                // ตรวจสอบว่าเป็น Rider หรือ User แล้ว route ไปยังหน้า Profile ที่เหมาะสม
                if (isRider) {
                  context.go('/profilerider');
                } else {
                  context.go('/profile');
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userData['fullname'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: userData['avatar_picture'] ?? '',
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 16,
                        backgroundImage: imageProvider,
                        backgroundColor: Colors.white,
                      ),
                      placeholder: (context, url) => const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A9830),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Row(
              children: [
                if (!isRider)
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                if (!isRider) const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    isRider ? 'Rider' : (userData['address'] ?? ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          bodyWidget,
        ],
      ),
    );
  }
}
