package com.example.dropp_mobile_app;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.widget.ImageView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        ImageView logo = findViewById(R.id.imageView);

        logo.setScaleX(0f);
        logo.setScaleY(0f);
        logo.setAlpha(0f);

        logo.animate().alpha(1f).scaleX(1.1f).scaleY(1.1f).setDuration(800)
                .withEndAction(() -> {
                    logo.animate().scaleX(1f).scaleY(1f).setDuration(200).start();}).start();

        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            startActivity(new Intent(MainActivity.this, SignInActivity.class));
            finish();
        }, 1500);
    }
}