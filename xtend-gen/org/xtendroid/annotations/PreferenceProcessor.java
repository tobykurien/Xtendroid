package org.xtendroid.annotations;

import com.google.common.base.Objects;
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor;
import org.eclipse.xtend.lib.macro.TransformationContext;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy;
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext;
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration;
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration;
import org.eclipse.xtend.lib.macro.declaration.TypeReference;
import org.eclipse.xtend.lib.macro.declaration.Visibility;
import org.eclipse.xtend.lib.macro.expression.Expression;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.xtendroid.utils.Utils;

@SuppressWarnings("all")
public class PreferenceProcessor extends AbstractFieldProcessor {
  public void doTransform(final MutableFieldDeclaration field, @Extension final TransformationContext context) {
    Expression _initializer = field.getInitializer();
    boolean _equals = Objects.equal(_initializer, null);
    if (_equals) {
      context.addError(field, "A Preference field must have an initializer.");
    }
    String _xifexpression = null;
    TypeReference _type = field.getType();
    String _simpleName = _type.getSimpleName();
    boolean _equalsIgnoreCase = _simpleName.equalsIgnoreCase("Boolean");
    if (_equalsIgnoreCase) {
      _xifexpression = "is";
    } else {
      _xifexpression = "get";
    }
    String getter = _xifexpression;
    MutableTypeDeclaration _declaringType = field.getDeclaringType();
    String _simpleName_1 = field.getSimpleName();
    String _upperCaseFirst = Utils.upperCaseFirst(_simpleName_1);
    String _plus = (getter + _upperCaseFirst);
    final Procedure1<MutableMethodDeclaration> _function = new Procedure1<MutableMethodDeclaration>() {
      public void apply(final MutableMethodDeclaration it) {
        it.setVisibility(Visibility.PUBLIC);
        TypeReference _type = field.getType();
        it.setReturnType(_type);
        TypeReference _returnType = it.getReturnType();
        String _prefMethodName = PreferenceProcessor.this.getPrefMethodName(_returnType);
        final String methodName = ("get" + _prefMethodName);
        final CompilationStrategy _function = new CompilationStrategy() {
          public CharSequence compile(final CompilationContext it) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("return pref.");
            _builder.append(methodName, "");
            _builder.append("(\"");
            String _simpleName = field.getSimpleName();
            String _resourceName = Utils.toResourceName(_simpleName);
            _builder.append(_resourceName, "");
            _builder.append("\", ");
            String _simpleName_1 = field.getSimpleName();
            _builder.append(_simpleName_1, "");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            return _builder;
          }
        };
        it.setBody(_function);
      }
    };
    _declaringType.addMethod(_plus, _function);
    MutableTypeDeclaration _declaringType_1 = field.getDeclaringType();
    String _simpleName_2 = field.getSimpleName();
    String _upperCaseFirst_1 = Utils.upperCaseFirst(_simpleName_2);
    String _plus_1 = ("set" + _upperCaseFirst_1);
    final Procedure1<MutableMethodDeclaration> _function_1 = new Procedure1<MutableMethodDeclaration>() {
      public void apply(final MutableMethodDeclaration it) {
        it.setVisibility(Visibility.PUBLIC);
        TypeReference _primitiveBoolean = context.getPrimitiveBoolean();
        it.setReturnType(_primitiveBoolean);
        TypeReference _type = field.getType();
        it.addParameter("value", _type);
        TypeReference _type_1 = field.getType();
        String _prefMethodName = PreferenceProcessor.this.getPrefMethodName(_type_1);
        final String methodName = ("put" + _prefMethodName);
        final CompilationStrategy _function = new CompilationStrategy() {
          public CharSequence compile(final CompilationContext it) {
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("pref.edit().");
            _builder.append(methodName, "");
            _builder.append("(\"");
            String _simpleName = field.getSimpleName();
            String _resourceName = Utils.toResourceName(_simpleName);
            _builder.append(_resourceName, "");
            _builder.append("\", value).commit();");
            _builder.newLineIfNotEmpty();
            _builder.append("return true;");
            _builder.newLine();
            return _builder;
          }
        };
        it.setBody(_function);
      }
    };
    _declaringType_1.addMethod(_plus_1, _function_1);
  }
  
  /**
   * Convert from Java type to SharedPreference method name
   */
  public String getPrefMethodName(final TypeReference returnType) {
    String _switchResult = null;
    String _simpleName = returnType.getSimpleName();
    String _lowerCase = _simpleName.toLowerCase();
    final String _switchValue = _lowerCase;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_switchValue,"boolean")) {
        _matched=true;
        _switchResult = "Boolean";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"long")) {
        _matched=true;
        _switchResult = "Long";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"int")) {
        _matched=true;
        _switchResult = "Int";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"string")) {
        _matched=true;
        _switchResult = "String";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,"set")) {
        _matched=true;
        _switchResult = "StringSet";
      }
    }
    if (!_matched) {
      String _plus = ("Invalid preference type " + returnType);
      IllegalStateException _illegalStateException = new IllegalStateException(_plus);
      throw _illegalStateException;
    }
    return _switchResult;
  }
}
