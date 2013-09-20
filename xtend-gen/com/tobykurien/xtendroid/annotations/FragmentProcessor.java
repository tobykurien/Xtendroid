package com.tobykurien.xtendroid.annotations;

import android.view.View;
import org.eclipse.xtend.lib.macro.AbstractClassProcessor;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext;
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class FragmentProcessor extends AbstractClassProcessor {
  public void doTransform(final MutableClassDeclaration clazz, @Extension final TransformationContext context) {
    final Procedure1<MutableMethodDeclaration> _function = new Procedure1<MutableMethodDeclaration>() {
      public void apply(final MutableMethodDeclaration it) {
        it.setVisibility(Visibility.PUBLIC);
        TypeReference _primitiveInt = context.getPrimitiveInt();
        it.addParameter("resId", _primitiveInt);
        TypeReference _newTypeReference = context.newTypeReference(View.class);
        it.setReturnType(_newTypeReference);
        final CompilationStrategy _function = new CompilationStrategy() {
          public CharSequence compile(final CompilationContext it) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("return getView().findViewById(resId);");
            _builder.newLine();
            return _builder;
          }
        };
        it.setBody(_function);
      }
    };
    clazz.addMethod("findViewById", _function);
  }
}
