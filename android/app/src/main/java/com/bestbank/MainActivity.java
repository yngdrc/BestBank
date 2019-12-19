package com.bestbank;

import android.content.pm.ActivityInfo;
import android.os.Bundle;

import com.google.android.material.tabs.TabItem;
import com.google.android.material.tabs.TabLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager.widget.ViewPager;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setRequestedOrientation (ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        TabLayout mTabLayout = findViewById(R.id.tabLayout);
        TabItem overviewTab = findViewById(R.id.overviewTab);
        TabItem historyTab = findViewById(R.id.historyTab);
        ViewPager viewPager = findViewById(R.id.viewpager);
        PagerController mPagerController;

        mPagerController = new PagerController(getSupportFragmentManager(), mTabLayout.getTabCount());
        viewPager.setAdapter(mPagerController);

        viewPager.addOnPageChangeListener(new TabLayout.TabLayoutOnPageChangeListener(mTabLayout));
    }
}
