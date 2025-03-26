import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/models/class_model.dart';
import 'package:student_management/models/result_model.dart';
import 'package:student_management/view_models/auth_view_model.dart';
import 'package:student_management/view_models/student_view_model.dart';

class StudentSubjectResultsView extends StatefulWidget {
  final ClassModel classModel;
  
  const StudentSubjectResultsView({
    Key? key,
    required this.classModel,
  }) : super(key: key);

  @override
  State<StudentSubjectResultsView> createState() => _StudentSubjectResultsViewState();
}

class _StudentSubjectResultsViewState extends State<StudentSubjectResultsView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final studentViewModel = Provider.of<StudentViewModel>(context, listen: false);
    studentViewModel.selectClass(widget.classModel);
    await studentViewModel.loadResultRecords(widget.classModel.id);
  }
  
  String _getLetterGrade(double? score) {
    if (score == null) return 'N/A';
    
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
  
  @override
  Widget build(BuildContext context) {
    final studentViewModel = Provider.of<StudentViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classModel.subject} Results'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.classModel.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subject: ${widget.classModel.subject}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Teacher: ${widget.classModel.teacherName}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule: ${widget.classModel.schedule}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Results
              const Text(
                'Exam Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              studentViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : studentViewModel.resultRecords.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No results available for this subject yet.'),
                          ),
                        )
                      : _buildResultsCard(studentViewModel.resultRecords.first),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildResultsCard(ResultModel result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Grade
            if (result.overallScore != null) ...[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getGradeColor(result.overallScore!),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getLetterGrade(result.overallScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Grade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.overallScore!.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
            ],
            
            // Individual Scores
            const Text(
              'Score Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Midterm
            _buildScoreRow(
              'Midterm Exam (30%)',
              result.midtermScore,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            
            // Final
            _buildScoreRow(
              'Final Exam (40%)',
              result.finalScore,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            
            // Group Work
            _buildScoreRow(
              'Group Work (20%)',
              result.groupWorkScore,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            
            // Participation
            _buildScoreRow(
              'Participation (10%)',
              result.participationScore,
              Colors.green,
            ),
            
            // Feedback
            if (result.feedback != null && result.feedback!.isNotEmpty) ...[
              const Divider(height: 32),
              const Text(
                'Teacher Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(result.feedback!),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreRow(String label, double? score, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label),
        ),
        Expanded(
          flex: 7,
          child: score != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / 100,
                              backgroundColor: color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${score.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Text(
                  'Not graded yet',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
        ),
      ],
    );
  }
  
  Color _getGradeColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }
}

