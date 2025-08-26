import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../models/task_entry.dart';
import '../services/supabase_service_v2.dart';

class UndoAction {
  final String id;
  final String type; // 'delete_entry', 'edit_entry', 'create_entry', 'delete_task_entry', 'edit_task_entry', 'create_task_entry'
  final DailyEntry? previousDailyEntry;
  final DailyEntry? currentDailyEntry;
  final TaskEntry? previousTaskEntry;
  final TaskEntry? currentTaskEntry;
  final List<TaskEntry>? previousTaskEntries;
  final List<TaskEntry>? currentTaskEntries;
  final DateTime timestamp;
  final String description;

  UndoAction({
    required this.id,
    required this.type,
    this.previousDailyEntry,
    this.currentDailyEntry,
    this.previousTaskEntry,
    this.currentTaskEntry,
    this.previousTaskEntries,
    this.currentTaskEntries,
    required this.timestamp,
    required this.description,
  });
}

class UndoProvider extends ChangeNotifier {
  final List<UndoAction> _undoStack = [];
  final int _maxUndoActions = 10;
  final SupabaseServiceV2 _supabaseService = SupabaseServiceV2();

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

  /// Record a delete action for daily entry
  void recordDeleteDailyEntry(DailyEntry deletedEntry, List<TaskEntry> deletedTaskEntries) {
    final action = UndoAction(
      id: '${deletedEntry.userId}_${deletedEntry.date.millisecondsSinceEpoch}',
      type: 'delete_entry',
      previousDailyEntry: deletedEntry,
      previousTaskEntries: deletedTaskEntries,
      timestamp: DateTime.now(),
      description: 'Deleted daily entry for ${_formatDate(deletedEntry.date)}',
    );
    addAction(action);
  }

  /// Record an edit action for daily entry
  void recordEditDailyEntry(DailyEntry previousEntry, DailyEntry updatedEntry, 
                           List<TaskEntry> previousTaskEntries, List<TaskEntry> updatedTaskEntries) {
    final action = UndoAction(
      id: '${updatedEntry.userId}_${updatedEntry.date.millisecondsSinceEpoch}',
      type: 'edit_entry',
      previousDailyEntry: previousEntry,
      currentDailyEntry: updatedEntry,
      previousTaskEntries: previousTaskEntries,
      currentTaskEntries: updatedTaskEntries,
      timestamp: DateTime.now(),
      description: 'Edited daily entry for ${_formatDate(updatedEntry.date)}',
    );
    addAction(action);
  }

  /// Record a create action for daily entry
  void recordCreateDailyEntry(DailyEntry createdEntry, List<TaskEntry> createdTaskEntries) {
    final action = UndoAction(
      id: '${createdEntry.userId}_${createdEntry.date.millisecondsSinceEpoch}',
      type: 'create_entry',
      currentDailyEntry: createdEntry,
      currentTaskEntries: createdTaskEntries,
      timestamp: DateTime.now(),
      description: 'Created daily entry for ${_formatDate(createdEntry.date)}',
    );
    addAction(action);
  }

  /// Record a delete action for individual task entry
  void recordDeleteTaskEntry(TaskEntry deletedTaskEntry) {
    final action = UndoAction(
      id: '${deletedTaskEntry.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'delete_task_entry',
      previousTaskEntry: deletedTaskEntry,
      timestamp: DateTime.now(),
      description: 'Deleted task completion',
    );
    addAction(action);
  }

  /// Record an edit action for individual task entry
  void recordEditTaskEntry(TaskEntry previousTaskEntry, TaskEntry updatedTaskEntry) {
    final action = UndoAction(
      id: '${updatedTaskEntry.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'edit_task_entry',
      previousTaskEntry: previousTaskEntry,
      currentTaskEntry: updatedTaskEntry,
      timestamp: DateTime.now(),
      description: 'Edited task completion',
    );
    addAction(action);
  }

  /// Record a create action for individual task entry
  void recordCreateTaskEntry(TaskEntry createdTaskEntry) {
    final action = UndoAction(
      id: '${createdTaskEntry.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'create_task_entry',
      currentTaskEntry: createdTaskEntry,
      timestamp: DateTime.now(),
      description: 'Created task completion',
    );
    addAction(action);
  }

  /// Undo the last action
  Future<bool> undoLastAction() async {
    if (!canUndo) return false;

    final action = _undoStack.removeLast();
    
    try {
      switch (action.type) {
        case 'delete_entry':
          // Restore the deleted daily entry and its task entries
          if (action.previousDailyEntry != null) {
            await SupabaseServiceV2.restoreDailyEntry(
              action.previousDailyEntry!,
              action.previousTaskEntries ?? [],
            );
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
          
        case 'edit_entry':
          // Restore the previous state of daily entry and task entries
          if (action.previousDailyEntry != null) {
            await SupabaseServiceV2.updateDailyEntry(
              action.previousDailyEntry!,
              action.previousTaskEntries ?? [],
            );
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
          
        case 'create_entry':
          // Delete the created daily entry and its task entries
          if (action.currentDailyEntry != null) {
            await SupabaseServiceV2.softDeleteDailyEntry(
              action.currentDailyEntry!.userId,
              action.currentDailyEntry!.date,
            );
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;

        case 'delete_task_entry':
          // Restore the deleted task entry
          if (action.previousTaskEntry != null) {
            await SupabaseServiceV2.restoreTaskEntry(action.previousTaskEntry!);
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
          
        case 'edit_task_entry':
          // Restore the previous state of task entry
          if (action.previousTaskEntry != null) {
            await SupabaseServiceV2.updateTaskEntry(action.previousTaskEntry!);
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
          
        case 'create_task_entry':
          // Delete the created task entry
          if (action.currentTaskEntry != null) {
            await SupabaseServiceV2.deleteTaskEntry(action.currentTaskEntry!.id);
            await Future.delayed(const Duration(milliseconds: 150));
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