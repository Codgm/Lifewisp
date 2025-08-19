import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

// 프리미엄 업그레이드 유도 위젯
class CloudBackupUpgradePrompt extends StatelessWidget {
  const CloudBackupUpgradePrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        if (subscription.canUseCloudStorage) {
          return SizedBox.shrink(); // 이미 프리미엄이면 표시 안함
        }

        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '클라우드 백업으로 안전하게 보관하세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '현재 감정 기록이 기기에만 저장됩니다.\n프리미엄으로 업그레이드하면:',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                _buildBenefit('자동 클라우드 백업'),
                _buildBenefit('여러 기기에서 동기화'),
                _buildBenefit('데이터 손실 방지'),
                _buildBenefit('무제한 AI 채팅'),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showUpgradeDialog(context, subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '프리미엄으로 업그레이드',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildBenefit(String benefit) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 8),
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Text(benefit, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, SubscriptionProvider subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('프리미엄으로 업그레이드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프리미엄 구독으로 다음 혜택을 받으세요:'),
            SizedBox(height: 16),
            _buildBenefit('무제한 클라우드 저장'),
            _buildBenefit('자동 백업 및 동기화'),
            _buildBenefit('여러 기기에서 접근'),
            _buildBenefit('무제한 AI 채팅'),
            _buildBenefit('고급 분석 기능'),
            SizedBox(height: 16),
            Text(
              '월 ₩9,900',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // 업그레이드 로직
              final success = await subscription.upgradeToPremium();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('프리미엄 구독이 활성화되었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('구독하기'),
          ),
        ],
      ),
    );
  }
}