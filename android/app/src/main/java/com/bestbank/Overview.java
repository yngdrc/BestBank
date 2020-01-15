package com.bestbank;


import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.LayerDrawable;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import java.text.DecimalFormat;

import androidx.fragment.app.Fragment;

import static android.content.Context.CLIPBOARD_SERVICE;

/**
 * A simple {@link Fragment} subclass.
 */
public class Overview extends Fragment {

    int swipe_count = 0;
    int h_per;

    public Overview() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final SharedPreferences prefs = getContext().getSharedPreferences("prefs", 0);
        final int accounts = prefs.getInt("accounts", 0);

        final View root = inflater.inflate(R.layout.fragment_overview, container,    false);
        final LinearLayout linearLayout = root.findViewById(R.id.overview_accountsContainer);
        final HorizontalScrollView horizontalScrollView = root.findViewById(R.id.overview_scrollview);
        DecimalFormat decim = new DecimalFormat("#.##");

        //final TextView tv_accountName = root.findViewById(R.id.overview_accountName);
        //final TextView tv_accountType = root.findViewById(R.id.overview_accountType);
        //final TextView tv_accountNumber = root.findViewById(R.id.overview_accountNumber);
        final String username = prefs.getString("username", "");
        //tv_accountName.setText(getResources().getString(R.string.account_name) + " " + prefs.getString(username+"accountName0", ""));
        //tv_accountType.setText(getResources().getString(R.string.account_type) + " " + prefs.getString(username+"accountType0", ""));
        //tv_accountNumber.setText(getResources().getString(R.string.account_number) + " " + prefs.getString(username+"token", ""));

        DisplayMetrics displaymetrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(displaymetrics);
        final int height = displaymetrics.heightPixels;
        final int width = displaymetrics.widthPixels;

        final int w_per = (int)Math.floor(width*0.08);

        FrameLayout.LayoutParams main = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        //main.setMargins(0,0,0,0);
        linearLayout.setGravity(Gravity.CENTER_VERTICAL);
        linearLayout.setLayoutParams(main);

        ViewTreeObserver vto = linearLayout.getViewTreeObserver();
        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {

            @Override
            public void onGlobalLayout() {
                h_per = (int)Math.floor(linearLayout.getHeight()*0.7);
                final float scale = getContext().getResources().getDisplayMetrics().density;
                int pixels = (int) (20 * scale + 0.5f);
                View space = new View(getContext());
                space.setLayoutParams(new LinearLayout.LayoutParams(pixels, ViewGroup.LayoutParams.MATCH_PARENT));
                linearLayout.addView(space);

                for (int x = 0; x<accounts; x++) {
                    String balance = prefs.getString(username+"balance"+x, "");
                    final String accountNumber = prefs.getString(username+"accountNumber"+x, "");
                    //Log.d("acc2", accountNumber);
                    final String accountType = prefs.getString(username+"accountType"+x, "");
                    final String accountName = prefs.getString(username+"accountName"+x, "");

                    final RelativeLayout overview_accountsContainer = new RelativeLayout(getContext());
                    RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(width-(4*w_per), h_per);
                    //layoutParams.setMarginEnd(w_per*2);
                    assert accountType != null;
                    switch (accountType) {
                        case "Comfort":
                            overview_accountsContainer.setBackgroundResource(R.drawable.overview_accounts_comfort);
                            break;
                        case "Personal account":
                            overview_accountsContainer.setBackgroundResource(R.drawable.overview_accounts_personal);
                            break;
                        case "Savings account":
                            overview_accountsContainer.setBackgroundResource(R.drawable.overview_accounts_savings);
                            break;

                    }
                    overview_accountsContainer.setElevation(25 * getContext().getResources().getDisplayMetrics().density);
                    overview_accountsContainer.setTranslationZ(0 * getContext().getResources().getDisplayMetrics().density);
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

                    TextView acc_number = new TextView(getContext());
                    acc_number.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT, 3));
                    acc_number.setTextColor(Color.WHITE);
                    acc_number.setGravity(Gravity.CENTER_VERTICAL);
                    acc_number.setTextSize(15);
                    acc_number.setText(accountNumber);

                    TextView textView1 = new TextView(getContext());
                    textView1.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT, 1));
                    textView1.setTextColor(Color.WHITE);
                    textView1.setGravity(Gravity.BOTTOM);
                    textView1.setTextSize(20);
                    textView1.setText("$" + String.valueOf(Double.parseDouble(balance)));

                    View space2 = new View(getContext());
                    space2.setLayoutParams(new LinearLayout.LayoutParams(pixels, ViewGroup.LayoutParams.MATCH_PARENT));

                    linearLayout1.addView(textView);
                    linearLayout1.addView(textView2);
                    linearLayout1.addView(view);
                    linearLayout1.addView(acc_number);
                    linearLayout1.addView(textView1);
                    overview_accountsContainer.addView(linearLayout1);
                    linearLayout.addView(overview_accountsContainer);
                    linearLayout.addView(space2);

                    overview_accountsContainer.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            ClipboardManager clipboard = (ClipboardManager) getContext().getSystemService(CLIPBOARD_SERVICE);
                            ClipData clip = ClipData.newPlainText("Account number", accountNumber);
                            clipboard.setPrimaryClip(clip);
                            MainActivity.showSnackbar();
                        }
                    });
                }
                ViewTreeObserver obs = linearLayout.getViewTreeObserver();

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                    obs.removeOnGlobalLayoutListener(this);
                } else {
                    obs.removeGlobalOnLayoutListener(this);
                }
            }

        });

        //TextView tv_lsl = root.findViewById(R.id.overview_lastSuccessfulLogin);
        //tv_lsl.setText(getResources().getString(R.string.lastSuccessfulLogin));

        return root;
    }
}
