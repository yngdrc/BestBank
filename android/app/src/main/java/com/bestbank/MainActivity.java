package com.bestbank;

import android.support.design.widget.TabItem;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

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
