class LRUCache<K, V> {
  final int capacity;
  final _cache = <K, V>{};

  LRUCache(this.capacity);

  V? get(K key) {
    if(!_cache.containsKey(key))
      return null;
    
    final value = _cache[key]!;
    _cache.remove(key);
    _cache[key] = value;
    return value;
  }

  void put(K key, V value) {
    if(_cache.containsKey(key)) {
      _cache.remove(key);
    } else if(_cache.length >= capacity) {
      _cache.remove(_cache.keys.first);
    }
    
    _cache[key] = value;
  }

  void clear() {
    _cache.clear();
  }

  int get length => _cache.length;
}
