package com.bestbank;

import com.android.volley.Response;
import com.android.volley.toolbox.StringRequest;

import java.util.HashMap;
import java.util.Map;

public class Requests extends StringRequest {
    private static final String LOGIN_REQUEST_URL = "http://bestbank.cba.pl/android/login.php";
    private static final String REGISTER_REQUEST_URL = "http://bestbank.cba.pl/android/register.php";
    private static final String TRANSACTION_REQUEST_URL = "http://bestbank.cba.pl/android/transaction.php";
    private Map<String, String> params;

    public Requests(String username, String password, Response.Listener<String> listener) {
        super(Method.POST, LOGIN_REQUEST_URL, listener, null);
        params = new HashMap<>();
        params.put("UserName", username);
        params.put("Password", password);
    }

    public Requests(String identityNumber, String email, String firstName, String lastName, String birthDate, String areaCode, String phoneNumber, String toc, String password, String confirmPassword, Response.Listener<String> listener) {
        super(Method.POST, REGISTER_REQUEST_URL, listener, null);
        params = new HashMap<>();
        params.put("IdentityNumber", identityNumber);
        params.put("Email", email);
        params.put("LastName", lastName);
        params.put("FirstName", firstName);
        params.put("BirthDate", birthDate);
        params.put("AreaCode", areaCode);
        params.put("PhoneNumber", phoneNumber);
        params.put("TitleOfCourtesy", toc);
        params.put("Password1", password);
        params.put("Password2", confirmPassword);
    }

    public Requests(String payerAccountNumber, String recipientAccountNumber, String amount, String identityNumber, Response.Listener<String> listener) {
        super(Method.POST, TRANSACTION_REQUEST_URL, listener, null);
        params = new HashMap<>();
        params.put("PayerAccountNumber", payerAccountNumber);
        params.put("RecipientAccountNumber", recipientAccountNumber);
        params.put("Amount", amount);
        params.put("IdentityNumber", identityNumber);
    }

    @Override
    public Map<String, String> getParams() {
        return params;
    }
}