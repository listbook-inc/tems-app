package com.example.listbook

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    		GeneratedPluginRegistrant.registerWith(flutterEngine)
	}
}
