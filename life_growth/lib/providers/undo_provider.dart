import 'package:flutter/material.dart';
import '../models/daily_task.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class UndoAction {
  final String id;
  final String type; // 'delete', 'edit', 'create'
  final DailyTask? previousState;
  final DailyTask? currentState;
  final DateTime timestamp;
  final String description;

  UndoAction({
    required this.id,
    required this.type,
    this.previousState,
    this.currentState,
    required this.timestamp,
    required this.description,
  });
}

class UndoProvider extends ChangeNotifier {
  final List<UndoAction> _undoStack = [];
  final int _maxUndoActions = 10;
  final DatabaseService _databaseService = DatabaseService();

  List<UndoAction> get undoStack => List.unmodifiable(_undoStack);
  bool get canUndo => _undoStack.isNotEmpty;
  UndoAction? get lastAction => _undoStack.isNotEmpty ? _undoStack.last : null;

  /// Add an action to the undo stack
  void addAction(UndoAction action) {
    _undoStack.add(action);
    
    // Keep only the last N actions to prevent memory issues
    if (_undoStack.length > _maxUndoActions) {
      _undoStack.removeAt(0);
    }
    
    notifyListeners();
  }

  /// Record a delete action
  void recordDelete(DailyTask deletedTask) {
    final action = UndoAction(
      id: '${deletedTask.userId}_${deletedTask.date.millisecondsSinceEpoch}',
      type: 'delete',
      previousState: deletedTask,
      timestamp: DateTime.now(),
      description: 'Deleted task for ${_formatDate(deletedTask.date)}',
    );
    addAction(action);
  }

  /// Record an edit action
  void recordEdit(DailyTask previousTask, DailyTask updatedTask) {
    final action = UndoAction(
      id: '${updatedTask.userId}_${updatedTask.date.millisecondsSinceEpoch}',
      type: 'edit',
      previousState: previousTask,
      currentState: updatedTask,
      timestamp: DateTime.now(),
      description: 'Edited task for ${_formatDate(updatedTask.date)}',
    );
    addAction(action);
  }

  /// Record a create action
  void recordCreate(DailyTask createdTask) {
    final action = UndoAction(
      id: '${createdTask.userId}_${createdTask.date.millisecondsSinceEpoch}',
      type: 'create',
      currentState: createdTask,
      timestamp: DateTime.now(),
      description: 'Created task for ${_formatDate(createdTask.date)}',
    );
    addAction(action);
  }

  /// Undo the last action
  Future<bool> undoLastAction() async {
    if (!canUndo) return false;

    final action = _undoStack.removeLast();
    
    try {
      switch (action.type) {
        case 'delete':
          // Restore the deleted task
          if (action.previousState != null) {
            await _databaseService.restoreDailyTask(
              action.previousState!.userId!,
              action.previousState!.date,
            );
          }
          break;
          
        case 'edit':
          // Restore the previous state
          if (action.previousState != null) {
            await _databaseService.upsertDailyTask(action.previousState!);
          }
          break;
          
        case 'create':
          // Delete the created task
          if (action.currentState != null) {
            await _databaseService.softDeleteDailyTask(
              action.currentState!.userId!,
              action.currentState!.date,
            );
          }
          break;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      // If undo fails, put the action back
      _undoStack.add(action);
      notifyListeners();
      return false;
    }
  }

  /// Clear all undo actions
  void clearUndoStack() {
    _undoStack.clear();
    notifyListeners();
  }

  /// Remove actions older than specified duration
  void cleanupOldActions({Duration maxAge = const Duration(hours: 24)}) {
    final cutoffTime = DateTime.now().subtract(maxAge);
    _undoStack.removeWhere((action) => action.timestamp.isBefore(cutoffTime));
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get description of what would be undone
  String? getUndoDescription() {
    return lastAction?.description;
  }
}