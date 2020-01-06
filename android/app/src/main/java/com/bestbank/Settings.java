package com.bestbank;


import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

/**
 * A simple {@link Fragment} subclass.
 */
public class Settings extends Fragment {

    TextView transactionName;

    public Settings() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final SharedPreferences prefs = getContext().getSharedPreferences("prefs", 0);
        Log.d("username", prefs.getString("username", ""));
        View root = inflater.inflate(R.layout.fragment_settings, container,    false);
        //TextView tv = root.findViewById(R.id.transactionName);
        //tv.setText(prefs.getString("username", ""));
        return root;
    }

}
