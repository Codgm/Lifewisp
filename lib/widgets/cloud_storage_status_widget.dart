import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

// 클라우드 저장 상태를 보여주는 위젯
class CloudStorageStatusWidget extends StatelessWidget {
  const CloudStorageStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        if (subscription.canUseCloudStorage) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '클라우드 백업 활성',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  '로컬 저장만',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}