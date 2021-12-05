package com.example.batterylevel;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.embedding.FlutterEngine;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "connectionTest";

    // @Override
    // protected void onCreate(Bundle savedInstanceState) {
    //     super.onCreate(savedInstanceState);
    //     GeneratedPluginRegistrant.registerWith(MainActivity.this);

    //     // new MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
    //     //     call, result ->
    //     //     // Note: this method is invoked on the main thread.
    //     //     // TODO
    //     //     result.success("HI FROM JAVA");
    //     //     }

    //     new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
    //         if(call.method.equals("printy")){
    //             result.success("HI FROM JAVA");
    //         }
    //     });

    //     new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler(){
    //         @Override
    //         public void onMethodCall(MethodCall methodCall, MethodChannel.Result result){
    //             if(methodCall.method.equals("printy")){
    //                 result.success("HI FROM JAVA");
    //             }
    //         }
    //     });
    // }

    @Override
    protected void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
            if(call.method.equals("printy")){
                result.success("HI FROM JAVA");
            }
        });
    }



}
