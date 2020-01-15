package com.bestbank;


import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;

import androidx.appcompat.widget.SwitchCompat;
import androidx.fragment.app.Fragment;

/**
 * A simple {@link Fragment} subclass.
 */
public class Settings extends Fragment implements CompoundButton.OnCheckedChangeListener {

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

        SwitchCompat sw = root.findViewById(R.id.settingsNotif);
        sw.setOnCheckedChangeListener(this);

        return root;
    }

    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if(isChecked) {
            MyFirebaseMessagingService.notifications = true;
            Log.d("true", "true");
        } else {
            MyFirebaseMessagingService.notifications = false;
            Log.d("false", "false");
        }
    }

}
