import 'package:sapphire_editor/models/timeline/timeline_schedule_model.dart';

class ScheduleDurationCache {
  static final Map<int, ScheduleDurationCache> _cache = {};
  
  final int scheduleHash;
  final String duration;
  final List<int> timeElapsedList;
  
  ScheduleDurationCache._(this.scheduleHash, this.duration, this.timeElapsedList);
  
  factory ScheduleDurationCache.calculate(TimelineScheduleModel schedule) {
    final hash = schedule.id;
    
    if(_cache.containsKey(hash)) {
      final cached = _cache[hash]!;
      if(_isValid(schedule, cached)) {
        return cached;
      }
    }
    
    final result = _calculate(schedule);
    _cache[hash] = result;
    
    if(_cache.length > 100) {
      _cache.remove(_cache.keys.first);
    }
    
    return result;
  }
  
  static bool _isValid(TimelineScheduleModel schedule, ScheduleDurationCache cached) {
    if(schedule.timepoints.length != cached.timeElapsedList.length) return false;
    
    for(int i = 0; i < schedule.timepoints.length; i++) {
      if(schedule.timepoints[i].startTime != 
          (i < schedule.timepoints.length - 1 ? 
           cached.timeElapsedList[i + 1] - cached.timeElapsedList[i] : 
           schedule.timepoints[i].startTime)) {
        return false;
      }
    }
    return true;
  }
  
  static ScheduleDurationCache _calculate(TimelineScheduleModel schedule) {
    final timeElapsedList = List<int>.filled(schedule.timepoints.length, 0);
    int timeElapsedMs = 0;
    
    for(int i = 0; i < schedule.timepoints.length; i++) {
      timeElapsedList[i] = timeElapsedMs;
      timeElapsedMs += schedule.timepoints[i].startTime;
    }
    
    final duration = _formatDuration(timeElapsedMs);
    
    return ScheduleDurationCache._(schedule.id, duration, timeElapsedList);
  }
  
  static String _formatDuration(int durationTotalMs) {
    final duration = Duration(milliseconds: durationTotalMs);
    
    String twoDigits(int n) {
      if(n >= 10) return "$n";
      return "0$n";
    }
    
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if(duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
  
  static void clear() {
    _cache.clear();
  }
}
