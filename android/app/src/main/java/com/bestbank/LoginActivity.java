package com.bestbank;

import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Space;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.Volley;
import com.google.android.material.snackbar.Snackbar;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class LoginActivity extends Activity {

    LinearLayout.LayoutParams params;
    Set<String> arrayList;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        setRequestedOrientation (ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        final Space space = findViewById(R.id.spaceLogin);

        final SharedPreferences prefs = getSharedPreferences("prefs", 0);
        final SharedPreferences.Editor edit = prefs.edit();

        final RelativeLayout root = findViewById(R.id.activity_login);
        root.getViewTreeObserver().addOnGlobalLayoutListener(new             ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Rect r = new Rect();
                root.getWindowVisibleDisplayFrame(r);
                int screenHeight = root.getRootView().getHeight();
                int keypadHeight = screenHeight - r.bottom;
                if (keypadHeight > screenHeight * 0.15) {
                    params = new LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            1f
                    );
                    space.setLayoutParams(params);
                } else {
                    params = new LinearLayout.LayoutParams(
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            LinearLayout.LayoutParams.WRAP_CONTENT,
                            1.5f
                    );
                    space.setLayoutParams(params);
                }
            }
        });

        final EditText etUsername = findViewById(R.id.etUsername);
        etUsername.setText(prefs.getString("username", ""));
        final EditText etPassword = findViewById(R.id.etPassword);
        final TextView tvRegisterLink = findViewById(R.id.tvRegister);
        final Button bLogin = findViewById(R.id.LoginButton);

        tvRegisterLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent registerIntent = new Intent(LoginActivity.this, RegisterActivity.class);
                LoginActivity.this.startActivity(registerIntent);
            }
        });

        bLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final String username = etUsername.getText().toString();
                final String password = etPassword.getText().toString();
                hideKeyboard(LoginActivity.this);

                // Response received from the server
                Response.Listener<String> responseListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        try {
                            JSONObject jsonResponse = new JSONObject(response);
                            Log.d("response", response);
                            //arrayList = new ArrayList<>();
                            arrayList = new HashSet<>();
                            boolean success = jsonResponse.getBoolean("success");

                            if (success) {
                                int accounts = jsonResponse.getInt("accounts");
                                edit.putString("username", username);
                                for (int x = 0; x<accounts; x++) {
                                    String accountDetails = jsonResponse.getString("accountDetails"+x);
                                    JSONObject jsonObject = new JSONObject(accountDetails);
                                    int balance = jsonObject.getInt("balance"+x);
                                    String accountNumber = jsonObject.getString("accountNumber"+x);
                                    String accountType = jsonObject.getString("accountType"+x);
                                    String accountName = jsonObject.getString("accountName"+x);
                                    String identityNumber = jsonObject.getString("identityNumber");
                                    edit.putString(username+"balance"+x, String.valueOf(balance));
                                    edit.putString(username+"accountNumber"+x, accountNumber);
                                    arrayList.add(accountNumber);
                                    edit.putString(username+"accountType"+x, accountType);
                                    edit.putString(username+"accountName"+x, accountName);
                                    edit.putString(username+"identityNumber", identityNumber);
                                }

                                Intent intent = new Intent(LoginActivity.this, MainActivity.class);
                                edit.putInt("accounts", accounts);
                                edit.putStringSet("arr", arrayList);
                                edit.commit();
                                Log.d("arr", String.valueOf(prefs.getStringSet("arr", null)));
                                LoginActivity.this.startActivity(intent);
                            } else {
                                Snackbar snackbar = Snackbar.make(root, "Couldn't sign in", Snackbar.LENGTH_LONG);
                                snackbar.getView().setBackgroundColor(getColor(R.color.loginButton));
                                snackbar.setActionTextColor(Color.WHITE);
                                snackbar.setAction("Action", null).show();
                            }

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                };

                Requests loginRequest = new Requests(username, password, responseListener);
                RequestQueue queue = Volley.newRequestQueue(LoginActivity.this);
                queue.add(loginRequest);
            }
        });
    }

    public static void hideKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        //Find the currently focused view, so we can grab the correct window token from it.
        View view = activity.getCurrentFocus();
        //If no view currently has focus, create a new one, just so we can grab a window token from it
        if (view == null) {
            view = new View(activity);
        }
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }
}

