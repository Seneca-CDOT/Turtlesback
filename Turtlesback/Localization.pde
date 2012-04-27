//Wrapper to handle changing languages
static class Localization{   
  static Language language = null;
  
  static void setLanguage(Language locale){
    language = locale;
  }
  
  static String get(String key){
    return (String)language.get(key);
  }
  
}

//Language class that extends HashMap
//Used to simplify the Langauge creation process.
class Language<K,V> extends HashMap<K, V> {
  public Language(K[] keys, V[] values)	{
    int i = 0;
    int keyLength = keys.length, valLength = values.length;
    if (keyLength > 0 && valLength > 0)	 {
      while (i < keyLength && i < valLength)	 {
        K key = keys[i];
        V value = values[i];
        
        this.put(key, value);
        
        i++;
      }
    }
  }
}


