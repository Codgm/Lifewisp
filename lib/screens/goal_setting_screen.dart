import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/goal.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';
import '../widgets/premium_gate.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({Key? key}) : super(key: key);

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '감정관리';
  double _targetValue = 70.0;
  String _unit = '%';
  DateTime? _targetDate;

  final List<String> _categories = ['감정관리', '습관형성', '성장목표', '자기돌봄'];
  final Map<String, List<String>> _units = {
    '감정관리': ['%', '점수'],
    '습관형성': ['일', '횟수'],
    '성장목표': ['개', '점수'],
    '자기돌봄': ['시간', '횟수'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscription = context.watch<SubscriptionProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final emotionProvider = context.watch<EmotionProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: '목표 설정',
        emoji: '🎯',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // AI 추천 목표 섹션
            if (subscription.isPremium) ...[
              _buildAIRecommendationsSection(goalProvider, emotionProvider, isDark),
              const SizedBox(height: 24),
            ] else ...[
              _buildPremiumGate(),
              const SizedBox(height: 24),
            ],

            // 직접 목표 설정 섹션
            _buildManualGoalSection(isDark),
            const SizedBox(height: 24),

            // 현재 목표 목록
            _buildCurrentGoalsSection(goalProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsSection(GoalProvider goalProvider, EmotionProvider emotionProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 추천 목표',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '당신의 감정 패턴을 분석하여 개인화된 목표를 추천해드려요',
            style: LifewispTextStyles.subtitle.copyWith(
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _generateAIRecommendations(goalProvider, emotionProvider),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI 추천 받기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: LifewispColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGate() {
    return PremiumGate(
      child: Container(), // 사용되지 않지만 필수
      featureName: 'ai_goal_recommendations',
      title: 'AI 추천 목표',
      description: '감정 패턴을 분석하여 개인화된 목표를 추천해드려요',
      features: [
        '🤖 AI 기반 개인화된 목표 추천',
        '📊 감정 패턴 분석을 통한 맞춤형 제안',
        '🎯 구체적인 실행 단계 제시',
        '📈 진행률 자동 추적',
        '💡 지속적인 목표 조정',
        '✨ 프리미엄 전용 기능'
      ],
    );
  }

  Widget _buildManualGoalSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✏️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '직접 목표 설정',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // 목표 제목
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '목표 제목',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목표 제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 목표 설명
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: '목표 설명',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목표 설명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 카테고리 선택
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _unit = _units[value]!.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 목표 수치
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _targetValue.toString(),
                        decoration: InputDecoration(
                          labelText: '목표 수치',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _targetValue = double.tryParse(value) ?? 70.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _unit,
                        decoration: InputDecoration(
                          labelText: '단위',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _units[_selectedCategory]!.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _unit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 목표 날짜 (선택사항)
                ListTile(
                  title: Text('목표 날짜 (선택사항)'),
                  subtitle: Text(_targetDate?.toString().split(' ')[0] ?? '설정하지 않음'),
                  trailing: IconButton(
                    icon: Icon(_targetDate == null ? Icons.add : Icons.edit),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _targetDate = date;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 목표 생성 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LifewispColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('목표 생성'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGoalsSection(GoalProvider goalProvider, bool isDark) {
    final goals = goalProvider.activeGoals;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📋', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '현재 목표 (${goals.length}개)',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 48,
                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 설정된 목표가 없어요',
                    style: LifewispTextStyles.subtitle.copyWith(
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            )
          else
            ...goals.map((goal) => _buildGoalCard(goal, isDark)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? LifewispColors.darkPrimary.withOpacity(0.1)
            : LifewispColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? LifewispColors.darkPrimary.withOpacity(0.3)
              : LifewispColors.accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(goal.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(goal.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '진행률',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: goal.progressPercentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(goal.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '완료':
        return Colors.green;
      case '진행중':
        return Colors.blue;
      case '지연':
        return Colors.orange;
      case '포기':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generateAIRecommendations(GoalProvider goalProvider, EmotionProvider emotionProvider) async {
    try {
      final records = emotionProvider.records;
      final recommendations = await goalProvider.generateAIRecommendedGoals(records);
      
      if (recommendations.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recommendations.length}개의 AI 추천 목표가 생성되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 추천 생성 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _createGoal() {
    if (_formKey.currentState!.validate()) {
      final goalProvider = context.read<GoalProvider>();
      
      goalProvider.createGoal(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        targetValue: _targetValue,
        unit: _unit,
        targetDate: _targetDate,
      );

      // 폼 초기화
      _titleController.clear();
      _descriptionController.clear();
      _targetValue = 70.0;
      _targetDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('목표가 성공적으로 생성되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 