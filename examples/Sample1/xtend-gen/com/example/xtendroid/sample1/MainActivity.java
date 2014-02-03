package com.example.xtendroid.sample1;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.text.Html;
import android.text.Spanned;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.example.xtendroid.sample1.MainActivity_CallBacks;
import com.example.xtendroid.sample1.R;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.xtendroid.app.AndroidActivity;
import org.xtendroid.app.OnCreate;
import org.xtendroid.utils.AlertUtils;
import org.xtendroid.utils.BgTask;

/**
 * Sample 2 - simple sample to show the usage of basic UI helpers as well as
 * asynchronous processing. This example fetches a random quote from the internet
 * when a button is pressed, and displays it in a TextView. Unlike Sample 1,
 * this example uses the @AndroidActivity annotation rather than individual
 * @AndroidView annotations.
 */
@AndroidActivity(layout = R.layout.activity_main)
@SuppressWarnings("all")
public class MainActivity extends Activity implements MainActivity_CallBacks {
  @OnCreate
  public void init(final Bundle savedInstanceState) {
    Button _mainLoadQuote = this.getMainLoadQuote();
    final View.OnClickListener _function = new View.OnClickListener() {
      public void onClick(final View it) {
        ProgressDialog _progressDialog = new ProgressDialog(MainActivity.this);
        final ProgressDialog pd = _progressDialog;
        pd.setMessage("Loading quote...");
        BgTask<String> _bgTask = new BgTask<String>();
        final Function0<String> _function = new Function0<String>() {
          public String apply() {
            String _data = MainActivity.getData("http://www.iheartquotes.com/api/v1/random");
            return _data;
          }
        };
        final Procedure1<String> _function_1 = new Procedure1<String>() {
          public void apply(final String result) {
            TextView _mainQuote = MainActivity.this.getMainQuote();
            Spanned _fromHtml = Html.fromHtml(result);
            _mainQuote.setText(_fromHtml);
          }
        };
        final Procedure1<Exception> _function_2 = new Procedure1<Exception>() {
          public void apply(final Exception error) {
            String _message = error.getMessage();
            String _plus = ("Error: " + _message);
            AlertUtils.toast(MainActivity.this, _plus);
          }
        };
        _bgTask.runInBgWithProgress(pd, _function, _function_1, _function_2);
      }
    };
    _mainLoadQuote.setOnClickListener(_function);
  }
  
  /**
   * Utility function to get data from the internet. In production code,
   * you should rather use something like the Volley library.
   * 
   * @param url
   * @return
   * @throws IOException
   */
  public static String getData(final String url) {
    try {
      URL _uRL = new URL(url);
      URLConnection _openConnection = _uRL.openConnection();
      HttpURLConnection c = ((HttpURLConnection) _openConnection);
      c.connect();
      int _responseCode = c.getResponseCode();
      boolean _equals = (_responseCode == HttpURLConnection.HTTP_OK);
      if (_equals) {
        ByteArrayOutputStream _byteArrayOutputStream = new ByteArrayOutputStream();
        ByteArrayOutputStream os = _byteArrayOutputStream;
        InputStream is = c.getInputStream();
        int oneChar = 0;
        int _read = is.read();
        int _oneChar = oneChar = _read;
        boolean _greaterThan = (_oneChar > 0);
        boolean _while = _greaterThan;
        while (_while) {
          os.write(oneChar);
          int _read_1 = is.read();
          int _oneChar_1 = oneChar = _read_1;
          boolean _greaterThan_1 = (_oneChar_1 > 0);
          _while = _greaterThan_1;
        }
        is.close();
        os.close();
        return os.toString();
      }
      return null;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    init(savedInstanceState);
  }
  
  public TextView getMainQuote() {
    return (TextView) findViewById(R.id.main_quote);
  }
  
  public Button getMainLoadQuote() {
    return (Button) findViewById(R.id.main_load_quote);
  }
}
