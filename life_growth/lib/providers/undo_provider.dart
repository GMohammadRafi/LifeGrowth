import 'package:flutter/material.dart';
import '../models/daily_task.dart' as model;
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class UndoAction {
  final String id;
  final String type; // 'delete', 'edit', 'create'
  final model.DailyTask? previousState;
  final model.DailyTask? currentState;
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
  final DatabaseService _databaseService = DatabaseService.instance;

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
  void recordDelete(model.DailyTask deletedTask) {
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
  void recordEdit(model.DailyTask previousTask, model.DailyTask updatedTask) {
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
  void recordCreate(model.DailyTask createdTask) {
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
          // Restore the deleted task using SupabaseService for proper sync
          if (action.previousState != null) {
            await SupabaseService.restoreDailyTask(
              userId: action.previousState!.userId!,
              date: action.previousState!.date,
            );
          }
          break;
          
        case 'edit':
          // Restore the previous state using SupabaseService for proper sync
          if (action.previousState != null) {
            await SupabaseService.upsertDailyTask(action.previousState!);
          }
          break;
          
        case 'create':
          // Delete the created task using SupabaseService for proper sync
          if (action.currentState != null) {
            await SupabaseService.softDeleteDailyTask(
              userId: action.currentState!.userId!,
              date: action.currentState!.date,
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