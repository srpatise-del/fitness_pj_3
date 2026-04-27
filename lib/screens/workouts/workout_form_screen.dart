import 'package:fitness_pj_3/models/workout.dart';
import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:fitness_pj_3/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WorkoutFormScreen extends StatefulWidget {
  const WorkoutFormScreen({super.key});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();

  String _selectedType = 'Running';
  DateTime _selectedDate = DateTime.now();
  Workout? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Workout && _editing == null) {
      _editing = args;
      _selectedType = args.type;
      _durationCtrl.text = '${args.duration}';
      _frequencyCtrl.text = '${args.frequencyPerWeek}';
      _selectedDate = args.date;
    }
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final user = auth.user!;

    final workout = Workout(
      id: _editing?.id ?? 0,
      userId: user.id,
      type: _selectedType,
      duration: int.parse(_durationCtrl.text),
      frequencyPerWeek: int.parse(_frequencyCtrl.text),
      date: _selectedDate,
    );

    bool ok;
    if (_editing == null) {
      ok = await workoutProvider.addWorkout(workout, user.token ?? '');
    } else {
      ok = await workoutProvider.updateWorkout(workout, user.token ?? '');
    }

    if (!mounted) return;
    if (ok) {
      await workoutProvider.loadWorkouts(userId: user.id, token: user.token ?? '');
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(workoutProvider.error ?? 'บันทึกไม่สำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final types = workoutProvider.workoutTypes.isEmpty
        ? ['Running', 'Weight Training', 'Yoga']
        : workoutProvider.workoutTypes;

    if (!types.contains(_selectedType)) {
      _selectedType = types.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'เพิ่ม Workout' : 'แก้ไข Workout'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: types
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      decoration: const InputDecoration(labelText: 'ประเภทการออกกำลังกาย'),
                      onChanged: (value) => setState(() => _selectedType = value ?? types.first),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ระยะเวลา (นาที)'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'กรอกระยะเวลาให้ถูกต้อง';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _frequencyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ความถี่ (ครั้ง/สัปดาห์)'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'กรอกความถี่ให้ถูกต้อง';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'วันที่: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _pickDate,
                          child: const Text('เลือกวันที่'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: workoutProvider.isLoading ? null : _submit,
                        child: const Text('บันทึก'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (workoutProvider.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
