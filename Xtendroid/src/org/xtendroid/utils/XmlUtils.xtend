package org.xtendroid.utils

import java.io.InputStream
import javax.xml.parsers.DocumentBuilderFactory
import org.w3c.dom.Element
import org.w3c.dom.Document

/**
 * XML utilities
 */
class XmlUtils {
   
   def static Document getDocument(InputStream stream) {
      val dbFactory = DocumentBuilderFactory.newInstance
      val dBuilder = dbFactory.newDocumentBuilder
      return dBuilder.parse(stream)
   }
   
   def static void traverseAllNodes(Document doc, (Element)=>void acceptor) {
      traverseAllNodes(doc.documentElement, acceptor)
   }
   
   def static void traverseAllNodes(Element node, (Element)=>void acceptor) {
      acceptor.apply(node)
      for (i : 0..<node.childNodes.length) {
         switch n : node.childNodes.item(i) {
            Element : traverseAllNodes(n, acceptor) 
         }
      }
   }
}