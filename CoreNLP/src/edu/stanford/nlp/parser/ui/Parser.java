// StanfordLexicalizedParser -- a probabilistic lexicalized NL CFG parser
// Copyright (c) 2002, 2003 Leland Stanford Junior University
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
// For more information, bug reports, fixes, contact:
//    Christopher Manning
//    Dept of Computer Science, Gates 4A
//    Stanford CA 94305-9040
//    USA
//    manning@cs.stanford.edu
//    http://nlp.stanford.edu/downloads/lex-parser.shtml

package edu.stanford.nlp.parser.ui;

/**
 * A simple GUI app for Parsing.  Allows a user to load a parser created
 * using lexparser.LexicalizedParser, load a text data file or type in text,
 * parse sentences within the input text, and view the resultant parse tree.
 * <p/>
 * Usage: <code>java edu.stanford.nlp.parser.ui.ParserPanel [parserFilename] [textFilename]</code>
 *
 * @author Huy Nguyen (htnguyen@cs.stanford.edu)
 * @see ParserPanel
 */
public class Parser extends javax.swing.JFrame {
  /**
   * 
   */
  private static final long serialVersionUID = 7179757799978939358L;
  private ParserPanel parserPanel;

  /**
   * Creates a new Parser Frame using {@link #Parser(String, String)}
   * with both arguments being <code>null</code>.
   */
  public Parser() {
    this(null, null);
  }

  /**
   * Creates new Parser Frame.
   *
   * @param parserFilename path to the serialized parser to load during
   *                       initialization
   * @param dataFilename   path to the data file to load during initialization
   */
  public Parser(String parserFilename, String dataFilename) {
    initComponents();

    parserPanel = new ParserPanel();
    getContentPane().add("Center", parserPanel);
    if (parserFilename != null) {
      parserPanel.loadParser(parserFilename);
    }
    if (dataFilename != null) {
      parserPanel.loadFile(dataFilename);
    }
    pack();
  }

  /**
   * This method is called from within the constructor to
   * initialize the form.
   * WARNING: Do NOT modify this code. The content of this method is
   * always regenerated by the Form Editor.
   */
  private void initComponents()//GEN-BEGIN:initComponents
  {
    jMenuBar1 = new javax.swing.JMenuBar();
    jMenu1 = new javax.swing.JMenu();
    loadDataItem = new javax.swing.JMenuItem();
    loadParserItem = new javax.swing.JMenuItem();
    jSeparator1 = new javax.swing.JSeparator();
    exitItem = new javax.swing.JMenuItem();
    jMenu2 = new javax.swing.JMenu();
    untokEngItem = new javax.swing.JCheckBoxMenuItem();
    tokChineseItem = new javax.swing.JCheckBoxMenuItem();
    untokChineseItem = new javax.swing.JCheckBoxMenuItem();

    setTitle("Parser");
    addWindowListener(new java.awt.event.WindowAdapter() {
      @Override
      public void windowClosing(java.awt.event.WindowEvent evt) {
        exitForm(evt);
      }
    });

    jMenu1.setText("File");
    loadDataItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_O, java.awt.event.InputEvent.ALT_MASK));
    loadDataItem.setMnemonic('o');
    loadDataItem.setText("Load File");
    loadDataItem.setToolTipText("Load a data file.");
    loadDataItem.addActionListener(evt -> loadDataItemActionPerformed(evt));

    jMenu1.add(loadDataItem);
    loadParserItem.setText("Load Parser");
    loadParserItem.addActionListener(evt -> loadParserItemActionPerformed(evt));

    jMenu1.add(loadParserItem);
    jMenu1.add(jSeparator1);
    exitItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent.VK_X, java.awt.event.InputEvent.ALT_MASK));
    exitItem.setMnemonic('x');
    exitItem.setText("Exit");
    exitItem.setToolTipText("Exits the program.");
    exitItem.addActionListener(evt -> exitItemActionPerformed(evt));

    jMenu1.add(exitItem);
    jMenuBar1.add(jMenu1);

    setJMenuBar(jMenuBar1);

    pack();
  }//GEN-END:initComponents

  private void exitItemActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_exitItemActionPerformed
  {//GEN-HEADEREND:event_exitItemActionPerformed
    exitForm(null);
  }//GEN-LAST:event_exitItemActionPerformed

  private void loadParserItemActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_loadParserItemActionPerformed
  {//GEN-HEADEREND:event_loadParserItemActionPerformed
    parserPanel.loadParser();
  }//GEN-LAST:event_loadParserItemActionPerformed

  private void loadDataItemActionPerformed(java.awt.event.ActionEvent evt)//GEN-FIRST:event_loadDataItemActionPerformed
  {//GEN-HEADEREND:event_loadDataItemActionPerformed
    parserPanel.loadFile();
  }//GEN-LAST:event_loadDataItemActionPerformed

  /**
   * Exit the Application
   */
  private void exitForm(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_exitForm
    System.exit(0);
  }//GEN-LAST:event_exitForm

  /**
   * @param args the command line arguments
   */
  public static void main(String args[]) {
    edu.stanford.nlp.util.DisabledPreferencesFactory.install();
    String dataFilename = null;
    String parserFilename = null;
    if (args.length > 0) {
      if (args[0].equals("-h")) {
        System.out.println("Usage: java edu.stanford.nlp.parser.ui.Parser [parserfilename] [textFilename]");
      } else {
        parserFilename = args[0];
        if (args.length > 1) {
          dataFilename = args[1];
        }
      }
    }

    Parser parser = new Parser(parserFilename, dataFilename);
    parser.setVisible(true);
  }


  // Variables declaration - do not modify//GEN-BEGIN:variables
  private javax.swing.JCheckBoxMenuItem untokEngItem;
  private javax.swing.JCheckBoxMenuItem tokChineseItem;
  private javax.swing.JCheckBoxMenuItem untokChineseItem;
  private javax.swing.JMenu jMenu2;
  private javax.swing.JMenuItem loadParserItem;
  private javax.swing.JMenuItem loadDataItem;
  private javax.swing.JSeparator jSeparator1;
  private javax.swing.JMenu jMenu1;
  private javax.swing.JMenuItem exitItem;
  private javax.swing.JMenuBar jMenuBar1;
  // End of variables declaration//GEN-END:variables

}
