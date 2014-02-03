package org.xtendroid.example.handlerexample

import android.view.View
import org.xtendroid.app.AndroidActivity

@AndroidActivity(layout=R.layout.main) class ProgressTestActivity {

   override startProgress(View element) {
      // Using Thread for demo, never use Thread in production code
      new Thread(
         [ |
            for (i : 1 .. 10) {
               doFakeWork
               progress.post [ |
                  text.text = "Updating"
                  progress.progress = i;
               ]
            }
         ]).start
   }

   def void doFakeWork() {
      Thread.sleep(2000);
   }

}

/*
 // The equivalent Java Code

public class ProgressTestActivity extends Activity {
  private ProgressBar progress;
  private TextView text;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
    progress = (ProgressBar) findViewById(R.id.progressBar1);
    text = (TextView) findViewById(R.id.textView1);

  }

  public void startProgress(View view) {
    // do something long
    Runnable runnable = new Runnable() {
      @Override
      public void run() {
        for (int i = 0; i <= 10; i++) {
          final int value = i;
           doFakeWork();
          progress.post(new Runnable() {
            @Override
            public void run() {
              text.setText("Updating");
              progress.setProgress(value);
            }
          });
        }
      }
    };
    new Thread(runnable).start();
  }

  // Simulating something time consuming
  private void doFakeWork() {
    try {
      Thread.sleep(2000);
    } catch (InterruptedException e) {
      throw new RuntimeException(e);
    }
  }

} 
 */