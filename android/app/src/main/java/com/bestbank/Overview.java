package com.bestbank;


import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.Html;
import android.text.Layout;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.amulyakhare.textdrawable.TextDrawable;

import org.json.JSONObject;

import java.text.DecimalFormat;

/**
 * A simple {@link Fragment} subclass.
 */
public class Overview extends Fragment {


    public Overview() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final SharedPreferences prefs = getContext().getSharedPreferences("prefs", 0);
        int accounts = prefs.getInt("accounts", 0);

        View root = inflater.inflate(R.layout.fragment_overview, container,    false);
        LinearLayout linearLayout = root.findViewById(R.id.overview_accountsContainer);
        DecimalFormat decim = new DecimalFormat("#.##");

        for (int x = 0; x<accounts; x++) {
            String balance = prefs.getString("balance"+x, "");
            String accountNumber = prefs.getString("accountNumber"+x, "");
            String accountType = prefs.getString("accountType"+x, "");
            String accountName = prefs.getString("accountName"+x, "");

            LinearLayout singleAccountContainer = new LinearLayout(getContext());
            singleAccountContainer.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT));
            singleAccountContainer.setGravity(Gravity.CENTER);
            singleAccountContainer.setOrientation(LinearLayout.VERTICAL);

            ImageView imageView = new ImageView(getContext());
            RelativeLayout.LayoutParams iv_params = new RelativeLayout.LayoutParams((int) getResources().getDimension(R.dimen.overviewAccountCircleWidth), (int) getResources().getDimension(R.dimen.overviewAccountCircleHeight));
            iv_params.setMarginStart(25);
            iv_params.setMarginEnd(25);
            imageView.setBackgroundResource(R.drawable.accounts_circle);
            imageView.setLayoutParams(iv_params);

            TextView textView = new TextView(getContext());
            textView.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            textView.setTextColor(Color.parseColor("#FD7C53"));
            textView.setText(accountName);
            textView.setTextSize(12);
            textView.setPadding(0, 7, 0, 0);
            textView.setGravity(Gravity.CENTER);

            singleAccountContainer.addView(imageView);
            singleAccountContainer.addView(textView);
            linearLayout.addView(singleAccountContainer);

            TextDrawable drawable = TextDrawable.builder()
                    .beginConfig()
                    .textColor(Color.parseColor("#FD7C53"))
                    .fontSize(20)
                    .endConfig()
                    .buildRound(Double.parseDouble(decim.format(balance))+" USD", Color.TRANSPARENT);

            imageView.setImageDrawable(drawable);
        }
        //TextView tv = root.findViewById(R.id.tvBalance);
        //tv.setText(prefs.getString("balance", ""));
        return root;
    }

}
