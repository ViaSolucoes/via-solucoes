import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://gmhrlbuirrkqaoqovjvo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtaHJsYnVpcnJrcWFvcW92anZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NjIwOTQsImV4cCI6MjA3OTMzODA5NH0.Q3B-fSUH9p2AQqdQJQdqXGGofozSc0ySRamu5OHQ8RQ',
    );
  }
}
