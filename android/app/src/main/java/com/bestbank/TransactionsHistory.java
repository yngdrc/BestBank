package com.bestbank;


import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.Volley;
import com.google.android.material.snackbar.Snackbar;

import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Text;

import androidx.fragment.app.Fragment;

/**
 * A simple {@link Fragment} subclass.
 */
public class TransactionsHistory extends Fragment {

    TextView transactionName;

    public TransactionsHistory() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final SharedPreferences prefs = getContext().getSharedPreferences("prefs", 0);
        final String username = prefs.getString("username", "");
        final View root = inflater.inflate(R.layout.fragment_transactions_history, container,    false);
        final int accounts = prefs.getInt("accounts", 0);

        final SharedPreferences.Editor edit = prefs.edit();

        final ScrollView scrollView = root.findViewById(R.id.transactions_scrollview);

        Response.Listener<String> responseListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                try {
                    Log.d("response", response);
                    JSONObject jsonResponse = new JSONObject(response);
                    //Log.d("response", response);
                    boolean success = jsonResponse.getBoolean("success");
                    int rows = jsonResponse.getInt("rows");
                    final float scale = getContext().getResources().getDisplayMetrics().density;

                    if (success) {
                        LinearLayout linearLayout = new LinearLayout(getContext());
                        //linearLayout.setPadding(0,60,0,0);
                        linearLayout.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
                        linearLayout.setOrientation(LinearLayout.VERTICAL);

                        for (int x = rows-1; x>=0; x--) {
//                            String accountDetails = jsonResponse.getString("accountDetails"+x);
//                            JSONObject jsonObject = new JSONObject(accountDetails);
//                            int balance = jsonObject.getInt("balance"+x);
                            String transactionDate = jsonResponse.getString("TransactionDate"+x);
                            String payerName = jsonResponse.getString("PayerName"+x);
                            String payerAcc = jsonResponse.getString("PayerAccountNumber"+x);
                            String recName = jsonResponse.getString("RecipientName"+x);
                            String recAcc = jsonResponse.getString("RecipientAccountNumber"+x);
                            String transactionTitle = jsonResponse.getString("TransactionTitle"+x);
                            String payerAccountName = jsonResponse.getString("PayerAccountName"+x);
                            String recipientAccountName = jsonResponse.getString("RecipientAccountName"+x);
                            double transactionAmount = jsonResponse.getDouble("Amount"+x);


                            LinearLayout linearLayout1 = new LinearLayout(getContext());
                            linearLayout1.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                            linearLayout1.setOrientation(LinearLayout.HORIZONTAL);
                            linearLayout1.setWeightSum(2);

                            LinearLayout linearLayout2 = new LinearLayout(getContext());
                            linearLayout2.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT, 1));
                            linearLayout.setPadding((int) (15*scale),(int) (15*scale),(int) (15*scale),(int) (15*scale));
                            linearLayout2.setOrientation(LinearLayout.VERTICAL);

                            TextView date = new TextView(getContext());
                            date.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                            date.setText(transactionDate);
                            date.setPadding((int) (5*scale),(int) (15*scale),(int) (5*scale),(int) (5*scale));
                            date.setTextColor(Color.BLACK);

                            TextView name = new TextView(getContext());
                            name.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                            name.setPadding((int) (5*scale),(int) (5*scale),(int) (5*scale),(int) (5*scale));
                            name.setTextColor(Color.BLACK);

                            TextView title = new TextView(getContext());
                            title.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                            title.setText(transactionTitle);
                            title.setPadding((int) (5*scale),(int) (5*scale),(int) (5*scale),(int) (5*scale));
                            title.setTextColor(Color.BLACK);

                            TextView currBalance = new TextView(getContext());
                            currBalance.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                            currBalance.setPadding((int) (5*scale),(int) (5*scale),(int) (5*scale),(int) (25*scale));
                            currBalance.setTextColor(Color.BLACK);
                            //currBalance.setTypeface(getResources().getFont(R.));

                            LinearLayout linearLayout3 = new LinearLayout(getContext());
                            linearLayout3.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT, 1));
                            linearLayout3.setPadding((int) (5*scale),(int) (5*scale),(int) (5*scale),(int) (5*scale));

                            TextView amount = new TextView(getContext());
                            amount.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                                if (prefs.getStringSet("arr", null).contains(payerAcc) && !prefs.getStringSet("arr", null).contains(recAcc)) {
                                    amount.setText("- $"+String.valueOf(transactionAmount));
                                    name.setText(recName);
                                    currBalance.setText(payerAccountName);
                                } else if (prefs.getStringSet("arr", null).contains(payerAcc) && prefs.getStringSet("arr", null).contains(recAcc)) {
                                    amount.setText("Internal transaction: $"+transactionAmount);
                                    name.setText(payerAccountName);
                                    currBalance.setText(recipientAccountName);
                                } else if (!prefs.getStringSet("arr", null).contains(payerAcc) && prefs.getStringSet("arr", null).contains(recAcc)) {
                                    amount.setText("+ $"+String.valueOf(transactionAmount));
                                    name.setText(payerName);
                                    currBalance.setText(recipientAccountName);
                                }
                            amount.setGravity(Gravity.CENTER_VERTICAL|Gravity.RIGHT);
                            amount.setTextColor(Color.BLACK);

                            View view = new View(getContext());
                            LinearLayout.LayoutParams viewParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (int) (1*scale));
                            view.setBackgroundColor(Color.DKGRAY);
                            viewParams.setMargins((int) (5*scale),(int) (15*scale),(int) (5*scale),(int) (15*scale));
                            view.setLayoutParams(viewParams);

                            linearLayout2.addView(date);
                            linearLayout2.addView(name);
                            linearLayout2.addView(title);
                            linearLayout2.addView(currBalance);
                            linearLayout3.addView(amount);
                            linearLayout1.addView(linearLayout2);
                            linearLayout1.addView(linearLayout3);
                            linearLayout.addView(linearLayout1);
                            //linearLayout.addView(view);
                        }
                        scrollView.addView(linearLayout);
                    }

                    scrollView.setFillViewport(true);
                    scrollView.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, 1120));

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        };

        Requests history = new Requests(prefs.getString(username+"identityNumber", ""), responseListener);
        RequestQueue queue = Volley.newRequestQueue(getContext());
        queue.add(history);

        return root;
    }

}
