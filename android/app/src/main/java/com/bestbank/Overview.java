package com.bestbank;


import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.graphics.drawable.TransitionDrawable;
import android.os.Bundle;
import android.text.Html;
import android.text.Layout;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.amulyakhare.textdrawable.TextDrawable;

import org.json.JSONObject;

import java.text.DecimalFormat;

import androidx.fragment.app.Fragment;

/**
 * A simple {@link Fragment} subclass.
 */
public class Overview extends Fragment {

    int swipe_count = 0;

    public Overview() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final SharedPreferences prefs = getContext().getSharedPreferences("prefs", 0);
        int accounts = prefs.getInt("accounts", 0);

        final View root = inflater.inflate(R.layout.fragment_overview, container,    false);
        final LinearLayout linearLayout = root.findViewById(R.id.overview_accountsContainer);
        final HorizontalScrollView horizontalScrollView = root.findViewById(R.id.overview_scrollview);
        DecimalFormat decim = new DecimalFormat("#.##");

        final TextView tv_accountName = root.findViewById(R.id.overview_accountName);
        final TextView tv_accountType = root.findViewById(R.id.overview_accountType);
        final TextView tv_accountNumber = root.findViewById(R.id.overview_accountNumber);
        tv_accountName.setText(getResources().getString(R.string.account_name) + " " + prefs.getString("accountName0", ""));
        tv_accountType.setText(getResources().getString(R.string.account_type) + " " + prefs.getString("accountType0", ""));
        tv_accountNumber.setText(getResources().getString(R.string.account_number) + " " + prefs.getString("accountNumber0", ""));

        DisplayMetrics displaymetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        int height = displaymetrics.heightPixels;
        final int width = displaymetrics.widthPixels;

        final int w_per = (int)Math.floor(width*0.08);

        FrameLayout.LayoutParams main = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        main.setMargins(0,w_per,0,w_per);
        linearLayout.setLayoutParams(main);
        int h_per = (int)Math.floor(linearLayout.getHeight()*0.08);

        horizontalScrollView.setOnScrollChangeListener(new View.OnScrollChangeListener() {
            @Override
            public void onScrollChange(View v, int scrollX, int scrollY, int oldScrollX, int oldScrollY) {
                    Log.d("oldx: ", String.valueOf(oldScrollX));
                    Log.d("newx", String.valueOf(scrollX));
                    if (scrollX == (1+swipe_count)*width && swipe_count < 3) {
                        swipe_count++;
                        horizontalScrollView.setScrollX(width*swipe_count);
                    } else if (scrollX == (1+swipe_count*width) && swipe_count > 0) {
                        swipe_count--;
                        horizontalScrollView.setScrollX(width*swipe_count);
                    }
                Log.d("swipe_count", String.valueOf(swipe_count));
            }
        });

        View space = new View(getContext());
        space.setLayoutParams(new LinearLayout.LayoutParams(w_per*2, ViewGroup.LayoutParams.MATCH_PARENT));
        linearLayout.addView(space);

        for (int x = 0; x<accounts; x++) {
            String balance = prefs.getString("balance"+x, "");
            final String accountNumber = prefs.getString("accountNumber"+x, "");
            final String accountType = prefs.getString("accountType"+x, "");
            final String accountName = prefs.getString("accountName"+x, "");

            final RelativeLayout overview_accountsContainer = new RelativeLayout(getContext());
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(width-(4*w_per), ViewGroup.LayoutParams.MATCH_PARENT);
            //layoutParams.setMarginEnd(w_per*2);
            overview_accountsContainer.setBackgroundResource(R.drawable.overview_accounts_container);
            overview_accountsContainer.setLayoutParams(layoutParams);

            LinearLayout linearLayout1 = new LinearLayout(getContext());
            linearLayout1.setPadding(35,35,35,35);
            linearLayout1.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
            linearLayout1.setWeightSum(4);
            linearLayout1.setOrientation(LinearLayout.VERTICAL);

            TextView textView = new TextView(getContext());
            textView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            textView.setTextColor(Color.WHITE);
            textView.setText(accountName);

            TextView textView2 = new TextView(getContext());
            textView2.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            textView2.setTextColor(Color.WHITE);
            textView2.setTextSize(10);
            textView2.setText(accountType);

            View view = new View(getContext());
            LinearLayout.LayoutParams layoutParams1 = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 1 );
            layoutParams1.setMargins(0,15,0,0);
            view.setBackgroundColor(Color.WHITE);
            view.setLayoutParams(layoutParams1);

            TextView textView1 = new TextView(getContext());
            textView1.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT, 4));
            textView1.setTextColor(Color.WHITE);
            textView1.setGravity(Gravity.BOTTOM);
            textView1.setTextSize(20);
            textView1.setText("$" + String.valueOf(Double.parseDouble(balance)));

            View space2 = new View(getContext());
            space2.setLayoutParams(new LinearLayout.LayoutParams(w_per*2, ViewGroup.LayoutParams.MATCH_PARENT));

            linearLayout1.addView(textView);
            linearLayout1.addView(textView2);
            linearLayout1.addView(view);
            linearLayout1.addView(textView1);
            overview_accountsContainer.addView(linearLayout1);
            linearLayout.addView(overview_accountsContainer);
            linearLayout.addView(space2);

            overview_accountsContainer.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    tv_accountName.setText(getResources().getString(R.string.account_name) + " " + accountName);
                    tv_accountType.setText(getResources().getString(R.string.account_type) + " " + accountType);
                    tv_accountNumber.setText(getResources().getString(R.string.account_number) + " " + accountNumber);
                }
            });
        }

        TextView tv_lsl = root.findViewById(R.id.overview_lastSuccessfulLogin);
        tv_lsl.setText(getResources().getString(R.string.lastSuccessfulLogin));

        return root;
    }
}
