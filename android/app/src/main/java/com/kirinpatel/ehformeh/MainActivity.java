package com.kirinpatel.ehformeh;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.Theme;

public class MainActivity extends AppCompatActivity {

    private DatabaseReference databaseReference;
    private ValueEventListener dealEventListener;
    private Deal deal;
    private boolean hasAnimated = false;

    private ConstraintLayout mainLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mainLayout = findViewById(R.id.mainLayout);

        databaseReference = FirebaseDatabase.getInstance().getReference("currentDeal/deal");
    }

    @Override
    protected void onResume() {
        super.onResume();

        setupCurrentDealListener();
    }

    @Override
    protected void onPause() {
        super.onPause();

        databaseReference.removeEventListener(dealEventListener);
    }

    private void animateStart() {
        if (deal != null && !hasAnimated) {
            hasAnimated = true;
            final ConstraintLayout loadingBackground = findViewById(R.id.loadingLayout);
            final TextView loadingTitle = findViewById(R.id.titleTextView);

            ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                    getResources().getColor(R.color.white),
                    Color.parseColor(deal.getTheme().getBackgroundColor()));
            backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingBackground.setBackgroundColor((int) animation.getAnimatedValue());
                }
            });
            backgroundColorAnimation.setDuration(500);

            ValueAnimator titleAlphaAnimation = ValueAnimator.ofFloat(1.0f, 0.0f);
            titleAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingTitle.setAlpha((float) animation.getAnimatedValue());
                }
            });
            titleAlphaAnimation.setDuration(500);

            backgroundColorAnimation.start();
            titleAlphaAnimation.start();

            titleAlphaAnimation.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationCancel(Animator animation) {
                    super.onAnimationCancel(animation);
                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    super.onAnimationEnd(animation);

                    loadingBackground.setVisibility(View.GONE);
                    mainLayout.setBackgroundColor(Color.parseColor(deal.getTheme().getBackgroundColor()));
                    mainLayout.setVisibility(View.VISIBLE);
                }

                @Override
                public void onAnimationRepeat(Animator animation) {
                    super.onAnimationRepeat(animation);
                }

                @Override
                public void onAnimationStart(Animator animation) {
                    super.onAnimationStart(animation);
                }

                @Override
                public void onAnimationPause(Animator animation) {
                    super.onAnimationPause(animation);
                }

                @Override
                public void onAnimationResume(Animator animation) {
                    super.onAnimationResume(animation);
                }
            });
        }
    }

    private void setupCurrentDealListener() {
        dealEventListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                try {
                    Theme dealTheme = new Theme(dataSnapshot.child("theme").child("backgroundColor").getValue().toString(),
                            dataSnapshot.child("theme").child("accentColor").getValue().toString(),
                            dataSnapshot.child("theme").child("foreground").getValue().toString().equals("dark"));

                    deal = new Deal(dataSnapshot.child("id").getValue().toString(),
                            dataSnapshot.child("features").getValue().toString(),
                            false,
                            null,
                            null,
                            dataSnapshot.child("soldOut").exists(),
                            null,
                            null,
                            dealTheme,
                            dataSnapshot.child("title").getValue().toString(),
                            null,
                            null);

                    animateStart();
                } catch (NullPointerException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        databaseReference.addValueEventListener(dealEventListener);
    }
}
