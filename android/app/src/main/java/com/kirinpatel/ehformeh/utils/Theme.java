package com.kirinpatel.ehformeh.utils;

import java.io.Serializable;

public class Theme implements Serializable {

    private String backgroundColor;
    private String accentColor;
    private boolean dark;

    public Theme(String backgroundColor, String accentColor, boolean dark) {
        this.backgroundColor = backgroundColor;
        this.accentColor = accentColor;
        this.dark = dark;
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    public String getAccentColor() {
        return accentColor;
    }

    public boolean isDark() {
        return dark;
    }
}
