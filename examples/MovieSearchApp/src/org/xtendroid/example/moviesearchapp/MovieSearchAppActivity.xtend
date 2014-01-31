package org.xtendroid.example.moviesearchapp

import android.widget.EditText
import org.xtendroid.app.OnCreate

import static extension org.xtendroid.utils.AlertUtils.*
import org.xtendroid.app.AndroidActivity

/**
 * This activity covers what is described in http://www.javacodegeeks.com/2010/10/android-full-app-part-1-main-activity.html
 */
@AndroidActivity("main") class MovieSearchAppActivity {
   
   val Strings strings = [|resources]
   
   @OnCreate def initializeOnCreate() {
      movieSearchRadioButton.onClickListener = [
         searchTypeTextView.text = strings.movies
      ]
      peopleSearchRadioButton.onClickListener =  [
         searchTypeTextView.text = strings.people
      ]
      searchButton.onClickListener = [
         val query = searchEditText.text.toString
         if (movieSearchRadioButton.isChecked) {
            toastLong(movieSearchRadioButton.text + " " + query)
         } else if (peopleSearchRadioButton.isChecked) {
            toastLong(peopleSearchRadioButton.text + " " + query)
         }
      ]
      searchEditText.onFocusChangeListener = [ view, hasFocus |
         switch focusedEditText : view {
            EditText: {
               // handle obtaining focus
               if (hasFocus) {
                  if (focusedEditText.text.toString == strings.search) {
                     focusedEditText.text = ""
                  }
               }
                // handle losing focus
               else {
                  if (focusedEditText.text.toString == "") {
                     focusedEditText.text = strings.search
                  }
               }
            }
         }
      ]
   }

}
