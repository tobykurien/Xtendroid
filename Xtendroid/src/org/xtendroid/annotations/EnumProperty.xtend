package org.xtendroid.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.Arrays
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableEnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(EnumPropertyProcessor)
@Target(ElementType.FIELD)
annotation EnumProperty {
	// Use this to explicitly state the key value (String) of the JSON Object
	// and define the expected String for DateFormat for Date fields
	String name = ""// enum type to generate
	String[] values = #[] // enum type values to generate
	Class enumType = typeof(Object) // pre-defined
}

class EnumPropertyProcessor extends AbstractFieldProcessor {
	
	val annotationName = "EnumProperty"
	
    override doRegisterGlobals(FieldDeclaration field, extension RegisterGlobalsContext context) {
    	
    	val annotation = field.annotations.findFirst[a | annotationName.equals(a.annotationTypeDeclaration.simpleName) ]
    	
    	val fieldTypeName = field.type.name
    	if (notAStringType(fieldTypeName))
    	{
    		return
    	}
    	
    	val preDefinedEnumTypeName = annotation
    		?.getExpression("enumType")
    	if (preDefinedEnumTypeName != null) // nothing to generate here
    	{
    		return
    	}
    	
    	val generatedName = annotation.getStringValue("name")?.toString
    	val generatedValues = annotation.getStringArrayValue("values");

		if (generatedName.nullOrEmpty) {
			return // do the error/warning in the other method
		}
		
		if (generatedValues.nullOrEmpty)
		{
			return // do the error/warning in the other method
		}

		val package = getPackageNameFromField(field) // last . included
		
		context.registerEnumerationType(package + generatedName)
   }
			
	def notAStringType(String fieldTypeName) {
		!(
		    			fieldTypeName.equals('java.lang.String') ||
		    			fieldTypeName.equals('java.lang.String[]') ||
		    			(fieldTypeName.startsWith('java.util.List<') && fieldTypeName.endsWith('String>'))
		    		)
	}
			
	def getPackageNameFromField(FieldDeclaration field) {
		val fieldTypeSimpleName = field.declaringType.simpleName
		val fieldTypeName = field.declaringType.qualifiedName
		val package = fieldTypeName.replace(fieldTypeSimpleName, '')
		package
	}
   
    override doTransform(MutableFieldDeclaration field, extension TransformationContext context) {
    	val fieldTypeName = field.type.name
    	if (notAStringType(fieldTypeName))
    	{
    		field.addError('The type of this field must be a String-based type, scalar String, List<String> or a String array')
    	}
    	
    	val annotation = field.annotations.findFirst[a | annotationName.equals(a.annotationTypeDeclaration.simpleName) ]

    	val preDefinedEnumType = annotation?.getClassValue("enumType")
    	var MutableEnumerationTypeDeclaration undefinedEnumType = null
    	if (preDefinedEnumType.name.endsWith('Object')) // not using pre-defined enum type
    	{
    		val generatedName = annotation.getStringValue("name").toString
    	    val generatedValues = annotation.getStringArrayValue("values");
    	    
			if (generatedName.nullOrEmpty) {
				annotation.addError("Missing enum type name in the annotation in parameter \"name\".")
			}
			
			if (generatedValues.nullOrEmpty)
			{
				annotation.addError("Missing enum type values in the annotation in parameter \"values\".")
			}
			
			// find the enum type
			val enumTypeName = field.packageNameFromField + generatedName
			val enumType = findEnumerationType(enumTypeName)
			if (enumType == null)
			{
				field.declaringType.addError(enumType.qualifiedName + " was probably not generated properly.")
			}
			undefinedEnumType = enumType
			
			// generate enum values
			generatedValues.forEach[s|
				enumType.addValue(s) [] 
			]
			
		}else
		{
			// find the enum type
			undefinedEnumType = preDefinedEnumType.name?.findEnumerationType
			if (undefinedEnumType == null)
			{
				field.declaringType.addError(preDefinedEnumType.simpleName + " is most likely not a proper enum type.")
			}
		}
		
		val enumType = undefinedEnumType
		enumType.addValue('PREVENT_NPE') []
		if (enumType.findDeclaredMethod('fromString') == null)
		{
			enumType.addMethod('fromString') [
				addParameter('s', String.newTypeReference)
				visibility = Visibility.PUBLIC
				returnType = enumType.newTypeReference
				body = ['''
					«enumType.newTypeReference» e = «toJavaCode(enumType.newTypeReference)».valueOf(s);
					return e != null ? e : PREVENT_NPE;
				''']
			]
		}
		
		if (enumType?.findDeclaredMethod('fromStringArray') == null)
		{
			val arrayEnumType = enumType.newTypeReference.newArrayTypeReference
			enumType.addMethod('fromStringArray') [
				addParameter('s', String.newTypeReference.newArrayTypeReference)
				visibility = Visibility.PUBLIC
				returnType = enumType.newTypeReference.newArrayTypeReference
				body = ['''
					if (s == null)
					{
						throw new IllegalArgumentException();
					}
					«toJavaCode(arrayEnumType)» enumArray = new «enumType.simpleName»[s.length];
					for (int i=0; i<s.length; i++)
					{
						enumArray[i] = fromString(s[i]);
					}
					return enumArray;
				''']
			]
		}

		if (enumType?.findDeclaredMethod('fromStringList') == null)
		{
			val arrayEnumType = enumType.newTypeReference.newArrayTypeReference
			enumType.addMethod('fromStringList') [
				addParameter('s', List.newTypeReference(String.newTypeReference))
				visibility = Visibility.PUBLIC
				returnType = List.newTypeReference(enumType.newTypeReference)
				body = ['''
					if (s == null)
					{
						throw new IllegalArgumentException();
					}
					return «toJavaCode(Arrays.newTypeReference)».asList(fromStringArray((String[]) s.toArray()));
				''']
			]
		}
    }
}