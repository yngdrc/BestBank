package com.bestbank;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.Volley;
import com.google.android.material.snackbar.Snackbar;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class Transaction extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_transaction);

        final SharedPreferences prefs = getApplicationContext().getSharedPreferences("prefs", 0);
        final int accounts = prefs.getInt("accounts", 0);
        final SharedPreferences.Editor edit = prefs.edit();
        final String username = prefs.getString("username", "");
        final String identityNumber = prefs.getString(username+"identityNumber", "");

        ArrayList<String> accountsArray = new ArrayList<>();

        final Spinner from = findViewById(R.id.transaction_from);
        for (int x = 0; x<accounts; x++) {
            accountsArray.add(prefs.getString(username+"accountName"+x, ""));
        }

        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, accountsArray);
        from.setAdapter(adapter);

        final EditText toAccount = findViewById(R.id.transaction_to);
        final EditText amountEt = findViewById(R.id.transaction_amount);
        final EditText toFirstName = findViewById(R.id.transaction_to_firstName);
        final EditText toLastName = findViewById(R.id.transaction_to_lastName);
        final EditText toTitle = findViewById(R.id.transaction_title);

        final Button button = findViewById(R.id.transaction_send);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                final String accountNumber = prefs.getString(username+"accountNumber"+(from.getAdapter().getCount()-1), "");
                String toAccountNumber = toAccount.getText().toString();
                final String amount = amountEt.getText().toString();
                final String firstName = toFirstName.getText().toString();
                final String lastName = toLastName.getText().toString();
                final String title = toTitle.getText().toString();

                        Response.Listener<String> responseListener = new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {
                                try {
                                    JSONObject jsonResponse = new JSONObject(response);
                                    boolean success = jsonResponse.getBoolean("success");

                                    if (success) {
                                        //int accounts = jsonResponse.getInt("accounts");
                                            Snackbar snackbar = Snackbar.make(button.getRootView(), "Transfer succeded", Snackbar.LENGTH_LONG);
                                            snackbar.getView().setBackgroundColor(getColor(R.color.snackbarGreen));
                                            snackbar.setActionTextColor(Color.WHITE);
                                            snackbar.setAction("Action", null).show();
                                        //edit.commit();
                                        //finish();
                                    } else {
                                        Snackbar snackbar = Snackbar.make(button.getRootView(), "Couldn't send money", Snackbar.LENGTH_LONG);
                                        snackbar.getView().setBackgroundColor(getColor(R.color.loginButton));
                                        snackbar.setActionTextColor(Color.WHITE);
                                        snackbar.setAction("Action", null).show();
                                    }

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        };

                        Requests loginRequest = new Requests(accountNumber, toAccountNumber, amount, identityNumber, firstName, lastName, title, responseListener);
                        RequestQueue queue = Volley.newRequestQueue(Transaction.this);
                        queue.add(loginRequest);
            }
        });
    }
}
