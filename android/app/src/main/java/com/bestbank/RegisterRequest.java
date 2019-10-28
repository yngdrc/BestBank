package com.bestbank;

import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;

import java.util.HashMap;
import java.util.Map;

public class RegisterRequest extends StringRequest {
    private static final String REGISTER_REQUEST_URL = "http://bestbank.cba.pl/android/register.php";
    private Map<String, String> params;

    public RegisterRequest(String username, String password1, String password2, Response.Listener<String> listener) {
        super(Method.POST, REGISTER_REQUEST_URL, listener, null);
        params = new HashMap<>();
        params.put("username", username);
        params.put("password1", password1);
        params.put("password2", password2);
    }

    @Override
    public Map<String, String> getParams() {
        return params;
    }
}
