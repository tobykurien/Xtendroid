package com.example.xtendroid.sample1;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.text.Html;
import android.text.Spanned;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import com.example.xtendroid.sample1.R.layout;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.xtendroid.utils.AlertUtils;
import org.xtendroid.utils.BgTask;

/**
 * Sample 1 - simple sample to show the usage of basic UI helpers as well as
 * asynchronous processing
 */
@SuppressWarnings("all")
public class MainActivity extends Activity {
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    this.setContentView(layout.activity_main);
    Button _mainLoadQuote = this.getMainLoadQuote();
    final OnClickListener _function = new OnClickListener() {
      public void onClick(final View it) {
        ProgressDialog _progressDialog = new ProgressDialog(MainActivity.this);
        final ProgressDialog pd = _progressDialog;
        pd.setMessage("Loading quote...");
        BgTask<String> _bgTask = new BgTask<String>();
        final Function0<String> _function = new Function0<String>() {
          public String apply() {
            String _xtrycatchfinallyexpression = null;
            try {
              String _data = MainActivity.this.getData("http://www.iheartquotes.com/api/v1/random");
              _xtrycatchfinallyexpression = _data;
            } catch (final Throwable _t) {
              if (_t instanceof Exception) {
                final Exception e = (Exception)_t;
                String _xblockexpression = null;
                {
                  final Runnable _function = new Runnable() {
                    public void run() {
                      String _message = e.getMessage();
                      String _plus = ("Error: " + _message);
                      AlertUtils.toast(MainActivity.this, _plus);
                    }
                  };
                  MainActivity.this.runOnUiThread(_function);
                  String _message = e.getMessage();
                  String _plus = ("ERROR: " + _message);
                  _xblockexpression = (_plus);
                }
                _xtrycatchfinallyexpression = _xblockexpression;
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
            return _xtrycatchfinallyexpression;
          }
        };
        final Procedure1<String> _function_1 = new Procedure1<String>() {
          public void apply(final String result) {
            TextView _mainQuote = MainActivity.this.getMainQuote();
            Spanned _fromHtml = Html.fromHtml(result);
            _mainQuote.setText(_fromHtml);
          }
        };
        _bgTask.runInBgWithProgress(pd, _function, _function_1);
      }
    };
    _mainLoadQuote.setOnClickListener(_function);
  }
  
  /**
   * Get data from the internet
   * 
   * @param url
   * @return
   * @throws IOException
   */
  public String getData(final String url) {
    try {
      URL _uRL = new URL(url);
      URL u = _uRL;
      URLConnection _openConnection = u.openConnection();
      HttpURLConnection c = ((HttpURLConnection) _openConnection);
      c.connect();
      int _responseCode = c.getResponseCode();
      boolean _equals = (_responseCode == HttpURLConnection.HTTP_OK);
      if (_equals) {
        InputStream is = c.getInputStream();
        int oneChar = 0;
        ByteArrayOutputStream _byteArrayOutputStream = new ByteArrayOutputStream();
        ByteArrayOutputStream os = _byteArrayOutputStream;
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
        return os.toString();
      }
      return null;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  private TextView _init_mainQuote() {
    return (TextView) findViewById(R.id.main_quote);
  }
  
  public TextView getMainQuote() {
    if (_mainQuote==null)
    _mainQuote = _init_mainQuote();
    return _mainQuote;
  }
  
  private TextView _mainQuote;
  
  private Button _init_mainLoadQuote() {
    return (Button) findViewById(R.id.main_load_quote);
  }
  
  public Button getMainLoadQuote() {
    if (_mainLoadQuote==null)
    _mainLoadQuote = _init_mainLoadQuote();
    return _mainLoadQuote;
  }
  
  private Button _mainLoadQuote;
}
