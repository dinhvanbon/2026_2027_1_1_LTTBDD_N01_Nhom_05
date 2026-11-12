import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/activity_provider.dart';
import '../../services/task_service.dart';
import 'dart:convert';

class ChildTaskScreen extends StatefulWidget {
  const ChildTaskScreen({super.key});

  @override
  State<ChildTaskScreen> createState() => _ChildTaskScreenState();
}

class _ChildTaskScreenState extends State<ChildTaskScreen> {
  String selectedFilter = 'Tất cả';

  XFile? selectedImage;

  Future<void> pickProofImage(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source, imageQuality: 70);

    if (image == null) return;

    setState(() {
      selectedImage = image;
    });
  }

  Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;

      case TaskStatus.submitted:
        return Colors.blue;

      case TaskStatus.approved:
        return Colors.green;

      case TaskStatus.rejected:
        return Colors.red;
    }
  }

  String getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Cần làm';

      case TaskStatus.submitted:
        return 'Đã nộp';

      case TaskStatus.approved:
        return 'Đã duyệt';

      case TaskStatus.rejected:
        return 'Từ chối';
    }
  }

  List<TaskModel> filterTasks(List<TaskModel> tasks) {
    if (selectedFilter == 'Tất cả') {
      return tasks;
    }

    return tasks.where((task) {
      return getStatusText(task.status) == selectedFilter;
    }).toList();
  }

  Widget buildSummaryCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xfff0e7fb)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterChip(String label) {
    final active = selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xff7048ff) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? const Color(0xff7048ff) : const Color(0xffe5ddea),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xff2d243b),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  void showSubmitDialog(BuildContext context, TaskModel task) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Gửi nhiệm vụ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thêm ghi chú và minh chứng hoàn thành nhiệm vụ.'),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú của trẻ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff3ecff),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffd8c8ff), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      selectedImage == null
                          ? 'Chưa chọn ảnh minh chứng'
                          : 'Đã chọn: ${selectedImage!.name}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                pickProofImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Thư viện'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => pickProofImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Chụp ảnh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedImage = null;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn hoặc chụp ảnh minh chứng.'),
                    ),
                  );
                  return;
                }

                if (noteController.text.trim().length > 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ghi chú tối đa 200 ký tự.')),
                  );
                  return;
                }

                final imageToSubmit = selectedImage;
                final noteText = noteController.text.trim().isEmpty
                    ? 'Con đã hoàn thành nhiệm vụ được giao rồi ạ.'
                    : noteController.text.trim();

                Navigator.of(dialogContext).pop();

                setState(() {
                  selectedImage = null;
                });

                try {
                  final imageBytes = await imageToSubmit!.readAsBytes();

                  final proofImageUrl = base64Encode(imageBytes);

                  await TaskService().submitTask(
                    taskId: task.id,
                    childNote: noteText,
                    proofImage: proofImageUrl,
                  );

                  if (!context.mounted) return;

                  await context.read<ActivityProvider>().addActivity(
                    childId: task.childId,
                    title: 'Nhiệm vụ đã nộp',
                    description: task.title,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi nhiệm vụ')),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi gửi nhiệm vụ: $e')),
                  );
                }
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTaskCard(BuildContext context, TaskModel task) {
    final isExpired = task.isExpired;
    final statusColor = isExpired ? Colors.grey : getStatusColor(task.status);

    String actionText;
    if (isExpired && task.status == TaskStatus.pending) {
      actionText = 'Task Locked - Deadline Expired';
    } else if (task.status == TaskStatus.pending) {
      actionText = 'Submit Task';
    } else if (task.status == TaskStatus.submitted) {
      actionText = 'Waiting for Parent';
    } else if (task.status == TaskStatus.approved) {
      actionText = 'Completed';
    } else {
      actionText = 'Rejected';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xfff0e7fb)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📘 ${task.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff1f1b2d),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff6f6b75),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isExpired ? 'Expired' : getStatusText(task.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isExpired
                ? 'Expired: ${task.deadlineText}'
                : 'Deadline: ${task.deadlineText}',
            style: TextStyle(
              color: isExpired ? Colors.redAccent : const Color(0xff7d7785),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _rewardChip(
                '+${task.expReward} EXP',
                const Color(0xfffff0d8),
                const Color(0xffff8a00),
              ),
              _rewardChip(
                '${task.rewardAmount}đ',
                const Color(0xffe8f7e9),
                const Color(0xff39b54a),
              ),
              _rewardChip(
                'Quest',
                const Color(0xfff1e9ff),
                const Color(0xff7048ff),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: task.status == TaskStatus.pending && !isExpired
                    ? const Color(0xffff9f43)
                    : Colors.grey.shade300,
                foregroundColor: task.status == TaskStatus.pending && !isExpired
                    ? Colors.white
                    : Colors.grey.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: task.status == TaskStatus.pending && !isExpired
                  ? () => showSubmitDialog(context, task)
                  : null,
              child: Text(
                actionText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardChip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    final filteredTasks = filterTasks(tasks);

    return Scaffold(
      backgroundColor: const Color(0xfffffaff),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xffefe5ff), Color(0xfffffaff), Color(0xffffffff)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Management',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff1f1b2d),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Theo dõi tiến độ nhiệm vụ',
                  style: TextStyle(
                    color: Color(0xff8b7c99),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    buildSummaryCard(
                      value: tasks.length.toString(),
                      label: 'Tổng số',
                      icon: Icons.task_alt,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    buildSummaryCard(
                      value: tasks
                          .where((task) => task.status == TaskStatus.pending)
                          .length
                          .toString(),
                      label: 'Cần làm',
                      icon: Icons.hourglass_top,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    buildSummaryCard(
                      value: tasks
                          .where((task) => task.status == TaskStatus.approved)
                          .length
                          .toString(),
                      label: 'Đã xong',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    buildFilterChip('Tất cả'),
                    const SizedBox(width: 8),
                    buildFilterChip('Cần làm'),
                    const SizedBox(width: 8),
                    buildFilterChip('Đã nộp'),
                    const SizedBox(width: 8),
                    buildFilterChip('Đã duyệt'),
                    const SizedBox(width: 8),
                    buildFilterChip('Từ chối'),
                  ],
                ),

                const SizedBox(height: 24),

                if (filteredTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        'Chưa có nhiệm vụ nào',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: filteredTasks
                        .map((task) => buildTaskCard(context, task))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
