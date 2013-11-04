package org.xtendroid.widget

import android.content.Context
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.view.View

/**
 * Extension methods for use as static extension import :
 * 
 * import static extension org.xtendroid.widget.AndroidUiBuilderExtensions.*
 * 
 */
class AndroidUiBuilderExtensions {

   def static verticalLayout(Context ctx, (LinearLayout)=>void initializer) {
      val result = new LinearLayout(ctx)
      result.orientation = LinearLayout.VERTICAL
      initializer.apply(result)
      return result;
   }

   def static horizontalLayout(Context ctx, (LinearLayout)=>void initializer) {
      val result = new LinearLayout(ctx)
      result.orientation = LinearLayout.HORIZONTAL
      initializer.apply(result)
      return result;
   }

   def static addVerticalLayout(ViewGroup container, (LinearLayout)=>void initializer) {
      val result = verticalLayout(container.context, initializer)
      container.addView(result)
      return result;
   }

   def static addHorizontalLayout(ViewGroup container, (LinearLayout)=>void initializer) {
      val result = horizontalLayout(container.context, initializer)
      container.addView(result)
      return result;
   }

   def static addTextView(ViewGroup container, String text) {
      val textView = new TextView(container.context) => [
         it.text = text
      ]
      container.addView(textView)
      return textView
   }

   def static addButton(ViewGroup container, String text, View.OnClickListener listener) {
      val button = new Button(container.context) => [
         it.text = text
         it.onClickListener = listener
      ]
      container.addView(button)
      return button
   }
}
