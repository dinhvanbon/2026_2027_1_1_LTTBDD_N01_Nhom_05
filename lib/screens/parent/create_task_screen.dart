import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/activity_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/task_service.dart';
import 'parent_main_navigation_screen.dart';

import '../../providers/language_provider.dart';
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();
  final expController = TextEditingController();
  final rewardController = TextEditingController();

  String difficulty = 'Trung bình';
  String category = 'Study';
  String? selectedChildId;
  bool isLoading = false;

  DateTime? selectedDeadline;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    expController.dispose();
    rewardController.dispose();
    super.dispose();
  }

  Future<void> pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      selectedDeadline = result;
      deadlineController.text =
          '${result.day.toString().padLeft(2, '0')}/'
          '${result.month.toString().padLeft(2, '0')}/'
          '${result.year} '
          '${result.hour.toString().padLeft(2, '0')}:'
          '${result.minute.toString().padLeft(2, '0')}';
    });
  }

  DateTime? parseDeadline(String input) {
    final value = input.trim();

    if (value.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})\s+(\d{2}):(\d{2})$');
    final match = regex.firstMatch(value);

    if (match == null) {
      return null;
    }

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);

    return DateTime(year, month, day, hour, minute);
  }

  Future<void> createTask() async {
    if (isLoading) return;

    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final expReward = int.tryParse(expController.text.trim()) ?? 0;
    final rewardAmount = int.tryParse(rewardController.text.trim()) ?? 0;
    final deadlineAt = parseDeadline(deadlineController.text);

    if (selectedChildId == null || selectedChildId!.isEmpty) {
      _showMessage(tr('Vui lòng chọn Child', 'Please choose a child'));
      return;
    }

    if (title.isEmpty) {
      _showMessage(tr('Vui lòng nhập tên nhiệm vụ', 'Please enter the quest name'));
      return;
    }

    if (title.length > 50) {
      _showMessage(tr('Tên nhiệm vụ tối đa 50 ký tự', 'Quest name must be at most 50 characters'));
      return;
    }

    if (description.isEmpty) {
      _showMessage(tr('Vui lòng nhập mô tả nhiệm vụ', 'Please enter the quest description'));
      return;
    }

    if (expReward <= 0) {
      _showMessage(tr('EXP phải lớn hơn 0', 'EXP must be greater than 0'));
      return;
    }

    if (expReward > 1000) {
      _showMessage(tr('EXP tối đa 1000', 'EXP must be at most 1000'));
      return;
    }

    if (rewardAmount < 0) {
      _showMessage(tr('Tiền thưởng không được âm', 'Reward cannot be negative'));
      return;
    }

    if (rewardAmount > 10000) {
      _showMessage(tr('Coin tối đa 10000', 'Coins must be at most 10000'));
      return;
    }

    if (deadlineController.text.trim().isNotEmpty && deadlineAt == null) {
      _showMessage(tr('Deadline phải có dạng dd/MM/yyyy HH:mm', 'Deadline must be in dd/MM/yyyy HH:mm format'));
      return;
    }

    if (deadlineAt != null && deadlineAt.isBefore(DateTime.now())) {
      _showMessage(tr('Deadline không được ở quá khứ', 'Deadline cannot be in the past'));
      return;
    }

    setState(() => isLoading = true);

    try {
      await TaskService().createTask(
        title: title,
        description: description,
        difficulty: difficulty,
        expReward: expReward,
        rewardAmount: rewardAmount,
        childId: selectedChildId!,
        deadlineAt: deadlineAt,
      );

      if (!mounted) return;

      await context.read<ActivityProvider>().addActivity(
        childId: selectedChildId!,
        title: 'Tạo nhiệm vụ',
        description: 'Parent đã tạo nhiệm vụ: $title',
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      titleController.clear();
      descriptionController.clear();
      deadlineController.clear();
      expController.clear();
      rewardController.clear();

      messenger.showSnackBar(
        SnackBar(content: Text(tr('Tạo nhiệm vụ thành công', 'Quest created successfully'))),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ParentMainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(tr('Lỗi tạo nhiệm vụ: $e', 'Create quest error: $e'));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, dynamic>? get selectedChild {
    final children = context.read<FamilyProvider>().children;
    for (final child in children) {
      if (child['uid'] == selectedChildId) return child;
    }
    return null;
  }

  String get selectedChildName {
    final child = selectedChild;
    if (child == null) return tr('Chưa chọn bé', 'No child selected');

    final username = child['username']?.toString() ?? '';
    if (username.isNotEmpty) return username;

    final email = child['email']?.toString() ?? '';
    if (email.isNotEmpty) return email;

    return child['uid']?.toString() ?? tr('Bé', 'Child');
  }

  void _showAddOrSelectChildDialog() {
    final linkCodeController = TextEditingController();
    final quickNameController = TextEditingController(text: 'Bé Bi');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(tr('Chọn hoặc Thêm Bé', 'Select or Add Child')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(
                    'Cách 1: Tạo nhanh hồ sơ Bé để giao việc ngay',
                    'Option 1: Quickly create a Child profile to assign quests immediately',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: quickNameController,
                  decoration: InputDecoration(
                    labelText: tr('Tên của bé', 'Child name'),
                    hintText: tr('Ví dụ: Bé Bi, Bé Bông...', 'e.g. Little Hero'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final name = quickNameController.text.trim();
                      try {
                        await context.read<FamilyProvider>().createQuickChild(
                          name,
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        final children =
                            context.read<FamilyProvider>().children;
                        if (children.isNotEmpty) {
                          setState(() {
                            selectedChildId =
                                children.first['uid']?.toString();
                          });
                        }
                        _showMessage(
                          tr(
                            'Đã thêm bé "$name" và chọn làm người nhận!',
                            'Added "$name" and selected as recipient!',
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        _showMessage(tr('Lỗi: $e', 'Error: $e'));
                      }
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: Text(
                      tr('Tạo nhanh & Chọn bé này', 'Quick Create & Select'),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(),
                ),
                Text(
                  tr(
                    'Cách 2: Nhập mã liên kết từ tài khoản Child có sẵn',
                    'Option 2: Enter link code from an existing Child account',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: linkCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: tr('Mã liên kết', 'Link code'),
                    hintText: tr('Ví dụ: KQFPX5UF', 'e.g. KQFPX5UF'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final code = linkCodeController.text.trim();
                      if (code.isEmpty) return;
                      try {
                        await context.read<FamilyProvider>().linkChildByCode(
                          code,
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        final children =
                            context.read<FamilyProvider>().children;
                        if (children.isNotEmpty) {
                          setState(() {
                            selectedChildId =
                                children.first['uid']?.toString();
                          });
                        }
                        _showMessage(
                          tr(
                            'Liên kết Child thành công!',
                            'Child linked successfully!',
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        _showMessage(tr('Lỗi: $e', 'Error: $e'));
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: Text(tr('Liên kết bằng mã', 'Link by code')),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(tr('Đóng', 'Close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final familyProvider = context.watch<FamilyProvider>();

    if (familyProvider.children.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<FamilyProvider>().listenToLinkedChildren();
      });
    } else if (selectedChildId == null || selectedChildId!.isEmpty) {
      selectedChildId = familyProvider.children.first['uid']?.toString();
    }

    final previewTitle = titleController.text.trim().isEmpty
        ? tr('Làm bài tập toán', 'Do math homework')
        : titleController.text.trim();

    final previewDeadline = deadlineController.text.trim().isEmpty
        ? '04/06/2026 20:00'
        : deadlineController.text.trim();

    final previewExp = int.tryParse(expController.text.trim()) ?? 50;
    final previewCoin = int.tryParse(rewardController.text.trim()) ?? 20;

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 22),
              _hero(),
              _formCard(
                children: [
                  _inputField(
                    label: tr('Tên nhiệm vụ', 'Quest name'),
                    icon: '📋',
                    controller: titleController,
                    hint: tr('Ví dụ: Làm bài tập toán', 'Example: Do math homework'),
                    onChanged: (_) => setState(() {}),
                  ),
                  _inputField(
                    label: tr('Mô tả nhiệm vụ', 'Quest description'),
                    icon: '📝',
                    controller: descriptionController,
                    hint: tr('Mô tả chi tiết nhiệm vụ cần hoàn thành...', 'Describe the quest to complete in detail...'),
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                  ),
                  _inputField(
                    label: tr('Hạn chót (Deadline)', 'Deadline'),
                    icon: '⏰',
                    controller: deadlineController,
                    readOnly: true,
                    onTap: pickDeadline,
                    hint: '04/06/2026 20:00',
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              _sectionTitle(
                tr('Giao cho bé', 'Assign to child'),
                tr('Chọn / Thêm bé', 'Select / Add child'),
                _showAddOrSelectChildDialog,
              ),
              _childGrid(familyProvider.children),
              _sectionTitle(tr('Độ khó', 'Difficulty'), tr('Mức độ thử thách', 'Challenge level')),
              _difficultyRow(),
              _sectionTitle(tr('Phần thưởng', 'Rewards'), tr('Kinh nghiệm & Vàng', 'Experience & Gold')),
              _formCard(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          label: tr('Kinh nghiệm (EXP)', 'Experience (EXP)'),
                          icon: '⭐',
                          controller: expController,
                          hint: '50',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _inputField(
                          label: tr('Vàng thưởng', 'Gold reward'),
                          icon: '🎁',
                          controller: rewardController,
                          hint: '20',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  _categoryDropdown(),
                ],
              ),
              _sectionTitle(tr('Xem trước nhiệm vụ', 'Quest preview'), tr('Trước khi tạo', 'Before creating')),
              _previewCard(
                title: previewTitle,
                deadline: previewDeadline,
                exp: previewExp,
                coin: previewCoin,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      text: tr('Hủy bỏ', 'Cancel'),
                      isPrimary: false,
                      onTap: isLoading ? null : () => Navigator.maybePop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _actionButton(
                      text: isLoading ? tr('Đang tạo...', 'Creating...') : tr('Giao nhiệm vụ ngay', 'Assign quest now'),
                      isPrimary: true,
                      onTap: isLoading ? null : createTask,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _topIconButton(Icons.arrow_back, () => Navigator.maybePop(context)),
        Column(
          children: [
            Text(
              tr('Tạo nhiệm vụ', 'Create quest'),
              style: TextStyle(
                color: Color(0xff2d243b),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              tr('Tạo nhiệm vụ mới cho bé', 'Create a new quest for your child'),
              style: TextStyle(color: Color(0xff8b7c99), fontSize: 13),
            ),
          ],
        ),
        _topIconButton(Icons.save, isLoading ? () {} : createTask),
      ],
    );
  }

  Widget _topIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff502d82).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: const Color(0xff2d243b)),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff7048ff), Color(0xff9d72ff)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff7048ff).withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Giao nhiệm vụ mới', 'Assign a new quest'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            tr('Tạo nhiệm vụ cho con, đặt EXP, vàng thưởng và theo dõi tiến độ hoàn thành.', 'Create quests for your child, set EXP and gold rewards, and track progress.'),
            style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _formCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xfff0e7fb)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _inputField({
    required String label,
    required String icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xfffaf7ff),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffeee3fb)),
            ),
            child: Row(
              crossAxisAlignment: maxLines > 1
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: maxLines > 1 ? 16 : 0),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !isLoading,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    onTap: onTap,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String actionText, [
    VoidCallback? onActionTap,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff2d243b),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Color(0xff7048ff),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childGrid(List<Map<String, dynamic>> children) {
    if (children.isEmpty) {
      return InkWell(
        onTap: _showAddOrSelectChildDialog,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffd8c7ff), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xfff1e9ff),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: Color(0xff7048ff),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        'Chưa có bé nào được liên kết',
                        'No child linked yet',
                      ),
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr(
                        'Nhấn vào đây để Tạo nhanh bé hoặc nhập Mã liên kết',
                        'Tap here to quickly create a child or enter link code',
                      ),
                      style: const TextStyle(
                        color: Color(0xff7048ff),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xff7048ff)),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: children.map((child) {
        final childId = child['uid']?.toString() ?? '';
        final name = child['username']?.toString().isNotEmpty == true
            ? child['username'].toString()
            : child['email']?.toString() ?? childId;
        final level = child['level'] ?? 1;
        final exp = child['exp'] ?? 0;
        final active = selectedChildId == childId;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  setState(() {
                    selectedChildId = childId;
                  });
                },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? const Color(0xfff5efff) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: active
                    ? const Color(0xff7048ff)
                    : const Color(0xffeee3fb),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff502d82).withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffffb347), Color(0xffff7b54)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text('🧒', style: TextStyle(fontSize: 27)),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff2d243b),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('Cấp $level • $exp EXP', 'Level $level • $exp EXP'),
                  style: const TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _difficultyRow() {
    final items = {'Dễ': 'Dễ', 'Trung bình': 'Vừa', 'Khó': 'Khó'};

    return Row(
      children: items.entries.map((entry) {
        final active = difficulty == entry.key;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          difficulty = entry.key;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  elevation: active ? 8 : 0,
                  backgroundColor: active
                      ? const Color(0xff7048ff)
                      : Colors.white,
                  foregroundColor: active
                      ? Colors.white
                      : const Color(0xff7d708d),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: active
                          ? const Color(0xff7048ff)
                          : const Color(0xffeee3fb),
                    ),
                  ),
                ),
                child: Text(
                  trv(entry.value),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Danh mục nhiệm vụ', 'Quest category'),
            style: TextStyle(
              color: Color(0xff2d243b),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xfffaf7ff),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffeee3fb)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'Study', child: Text(tr('📚 Học tập', '📚 Study'))),
                  DropdownMenuItem(
                    value: 'Housework',
                    child: Text(tr('🏠 Việc nhà', '🏠 Housework')),
                  ),
                  DropdownMenuItem(value: 'Health', child: Text(tr('💪 Rèn luyện sức khỏe', '💪 Health training'))),
                  DropdownMenuItem(
                    value: 'Daily Quest',
                    child: Text(tr('⚔️ Nhiệm vụ hàng ngày', '⚔️ Daily quest')),
                  ),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          category = value;
                        });
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewCard({
    required String title,
    required String deadline,
    required int exp,
    required int coin,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xfffff7e8), Colors.white],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xffffe0a9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff502d82).withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xfffff0cf),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category == 'Study'
                      ? '📚'
                      : category == 'Housework'
                      ? '🏠'
                      : category == 'Health'
                      ? '💪'
                      : '⚔️',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff2d243b),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('Giao cho: $selectedChildName • Hạn chót: $deadline', 'Assigned to: $selectedChildName • Deadline: $deadline'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff8b7c99),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tag(
                '⭐ +$exp EXP',
                const Color(0xffefe7ff),
                const Color(0xff7048ff),
              ),
              _tag(
                tr('🎁 +$coin Vàng', '🎁 +$coin Gold'),
                const Color(0xfffff3df),
                const Color(0xffff8a00),
              ),
              _tag(
                trv(difficulty),
                const Color(0xffe8f0ff),
                const Color(0xff2b6bd6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required bool isPrimary,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: isPrimary ? 10 : 0,
          backgroundColor: isPrimary
              ? const Color(0xff7048ff)
              : const Color(0xfff1edf5),
          foregroundColor: isPrimary ? Colors.white : const Color(0xff8b7c99),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading && isPrimary
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
