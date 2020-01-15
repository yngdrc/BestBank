package com.bestbank;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Space;
import android.widget.TextView;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.toolbox.Volley;
import com.google.android.material.snackbar.Snackbar;

import org.json.JSONException;
import org.json.JSONObject;

public class RegisterActivity extends Activity {

    LinearLayout.LayoutParams params;
    String toc = "Mr.";

    public void setToc(View v) {
        TextView tv = (TextView) v;
        toc = tv.getText().toString();
        LinearLayout tocLayout = findViewById(R.id.tocRegister);
        if ((toc.equals("Mr."))) {
            tocLayout.setBackground(getDrawable(R.drawable.toc_left));
        } else {
            tocLayout.setBackground(getDrawable(R.drawable.toc_right));
        }
    }

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        setRequestedOrientation (ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        final Space space = findViewById(R.id.spaceRegister);

        final RelativeLayout root = findViewById(R.id.activity_register);
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

        final EditText identityNumber_et =   findViewById(R.id.identityNumber_reg);
        final EditText email_et = findViewById(R.id.email_reg);
        final EditText firstName_et = findViewById(R.id.firstName_reg);
        final EditText lastName_et = findViewById(R.id.lastName_reg);
        final EditText birthDate_et = findViewById(R.id.birthDate_reg);
        final EditText areaCode_et = findViewById(R.id.areaCode_reg);
        final EditText phoneNumber_et = findViewById(R.id.phoneNumber_reg);
        final EditText password_et = findViewById(R.id.password_reg);
        final EditText confirmPassword_et = findViewById(R.id.confirmPassword_reg);
        //final EditText toc = "Mr.";

        final Button RegisterButton = findViewById(R.id.RegisterButton);
        final TextView tvLogin = findViewById(R.id.tvLogin);

        RegisterButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final String identityNumber = identityNumber_et.getText().toString();
                final String email = email_et.getText().toString();
                final String firstName = firstName_et.getText().toString();
                final String lastName = lastName_et.getText().toString();
                final String birthDate = birthDate_et.getText().toString();
                final String areaCode = areaCode_et.getText().toString();
                final String phoneNumber = phoneNumber_et.getText().toString();
                final String password = password_et.getText().toString();
                final String confirmPassword = confirmPassword_et.getText().toString();
                final String toc = "Mr.";

                Response.Listener<String> responseListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        try {
                            Log.d("response", response);
                            JSONObject jsonResponse = new JSONObject(response);
                            boolean success = jsonResponse.getBoolean("success");
                            if(success){
                                String usrnm = jsonResponse.getString("username");
                                final SharedPreferences prefs = getApplicationContext().getSharedPreferences("prefs", 0);
                                final SharedPreferences.Editor edit = prefs.edit();
                                edit.putString("username", usrnm);
                                edit.commit();
                                Intent intent = new Intent(RegisterActivity.this, LoginActivity.class);
                                RegisterActivity.this.startActivity(intent);
                            }
                            else {
                                Snackbar snackbar = Snackbar.make(root, "Couldn't create an account", Snackbar.LENGTH_LONG);
                                snackbar.getView().setBackgroundColor(getColor(R.color.loginButton));
                                snackbar.setActionTextColor(Color.WHITE);
                                snackbar.setAction("Action", null).show();
                            }

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                };

                Requests registerRequest = new Requests(identityNumber, email, firstName, lastName, birthDate, areaCode, phoneNumber, toc, password, confirmPassword, responseListener);
                //LoginRequest loginRequest = new LoginRequest(username, email, password, responseListener);
                RequestQueue queue = Volley.newRequestQueue(RegisterActivity.this);
                queue.add(registerRequest);
            }
        });

        tvLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent loginIntent = new Intent(RegisterActivity.this, LoginActivity.class);
                RegisterActivity.this.startActivity(loginIntent);
            }
        });
    }
}
