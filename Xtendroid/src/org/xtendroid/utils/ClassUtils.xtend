package org.xtendroid.utils

import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

/**
 * Work out class heirarchies, use reflection, etc.
 */
class ClassUtils {
    def static boolean isExtending(Class clazz, String qualifiedName) {
        if (clazz == null) return false;
        if (clazz.name.equals(qualifiedName)) {
            return true
        }

        // may be parameterized
        if (clazz.name.startsWith(qualifiedName + "<")) {
            return true
        }

        var superClazz = clazz.superclass
        while (superClazz != clazz && superClazz != null) {
            if (ClassUtils.isExtending(superClazz, qualifiedName)) {
                return true
            }
            superClazz = superClazz.superclass
        }

        return false
    }

    def static boolean isExtending(MutableClassDeclaration clazz, String qualifiedName) {
        if (clazz == null) return false;
        if (clazz.qualifiedName.equals(qualifiedName)) {
            return true
        }

        // may be parameterized
        if (clazz.qualifiedName.startsWith(qualifiedName + "<")) {
            return true
        }

        val t = clazz.extendedClass
        if (t != null) {
            if (ClassUtils.isExtending(t, qualifiedName)) {
                return true
            }
        }
    }

    def static boolean isExtending(TypeReference type, String qualifiedName) {
        if (type == null) return false;
        if (type.name.equals(qualifiedName)) {
            return true
        }

        // may be parameterized
        if (type.name.startsWith(qualifiedName + "<")) {
            return true
        }

        for (c: type.declaredSuperTypes) {
            if (isExtending(c, qualifiedName)) {
                return true
            }
        }

        return false
    }

    def static boolean isExtending(MutableTypeDeclaration type, String qualifiedName) {
        if (type == null) return false;
        var clazz = type
        if (clazz.qualifiedName.equals(qualifiedName)) {
            return true
        }

        // may be parameterized
        if (clazz.qualifiedName.startsWith(qualifiedName + "<")) {
            return true
        }

        for (t: clazz.declaredTypes) {
            if (ClassUtils.isExtending(t, qualifiedName)) {
                return true
            }
        }

        return false
    }
}