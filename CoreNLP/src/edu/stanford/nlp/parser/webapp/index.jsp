<?xml version="1.0" encoding="UTF-8"?>
<%@ page pageEncoding="UTF-8" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<% /*
   -------------------- WARNING --------------------------------
     Do not edit this file unless your editor knows how to
                  properly handle UTF-8.
   -------------------------------------------------------------
*/ %>

<%@ page session="false" %>
<%@ page import="edu.stanford.nlp.ie.crf.CRFClassifier" %>
<%@ page import="edu.stanford.nlp.ling.HasWord" %>
<%@ page import="edu.stanford.nlp.ling.SentenceUtils" %>
<%@ page import="edu.stanford.nlp.ling.Word" %>
<%@ page import="edu.stanford.nlp.ling.CoreLabel" %>
<%@ page import="edu.stanford.nlp.parser.lexparser.LexicalizedParser" %>
<%@ page import="edu.stanford.nlp.process.DocumentPreprocessor" %>
<%@ page import="edu.stanford.nlp.sequences.SeqClassifierFlags" %>
<%@ page import="edu.stanford.nlp.trees.Tree" %>
<%@ page import="edu.stanford.nlp.trees.TreePrint" %>
<%@ page import="edu.stanford.nlp.trees.TreebankLanguagePack" %>
<%@ page import="edu.stanford.nlp.util.StringUtils" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.function.Function" %>
<%@ page import="java.util.zip.GZIPInputStream" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Date" %>

<%!
private static final int MAXWORDS = 70;
private static final String DEFAULT_LANG = "English";
static final boolean DEBUG = false;
// WARNING: this is tomcat specific
private static final String BASE_DIR = System.getProperty("catalina.base");
private static final String BASE_LOG_FILENAME = "/logs/parser.sentences";
private static final String LOG_FILENAME = BASE_DIR + BASE_LOG_FILENAME;

private static class ParserPack {
  CRFClassifier<CoreLabel> segmenter;
  LexicalizedParser parser;
  TreebankLanguagePack tLP;
  TreePrint tagPrint, pennPrint, typDepPrint, typDepColPrint;
  Function<List<HasWord>, List<HasWord>> escaper;
  String modelName;
}

private static ParserPack loadParserPack(String parser, ServletContext application)
   throws Exception {
  String serializedParserPath =
     application.getRealPath("/WEB-INF/data") + File.separator +
     nameToParserSer.get(parser);

  // load parser
  ParserPack pp = new ParserPack();
  pp.escaper = (Function<List<HasWord>, List<HasWord>>)
     Class.forName(nameToEscaper.get(parser)).newInstance();
  pp.parser = LexicalizedParser.loadModel(serializedParserPath);
  pp.tLP = pp.parser.getOp().tlpParams.treebankLanguagePack();
  pp.tagPrint = new TreePrint("wordsAndTags", pp.tLP);
  pp.pennPrint = new TreePrint("penn", pp.tLP);
  pp.modelName = nameToParserSer.get(parser);

  // Enable typed dependencies if supported
  if (pp.tLP.supportsGrammaticalStructures()) {
     pp.typDepPrint = new TreePrint("typedDependencies", "basicDependencies", pp.tLP);
     pp.typDepColPrint = new TreePrint("typedDependencies", pp.tLP);  // default is now CCprocessed
  }

  // todo: Update Chinese Segmenter version (2008!)
  // todo: Add Arabic segmenter
  // if appropriate, load segmenter
  if (parser.equals("Chinese")) {
    Properties props = new Properties();
    String dataDir = application.getRealPath("/WEB-INF/data/chinesesegmenter");
    CRFClassifier<CoreLabel> classifier = new CRFClassifier<>(props);
    BufferedInputStream bis = new BufferedInputStream(new GZIPInputStream(
      new FileInputStream(dataDir + File.separator + "05202008-ctb6.processed-chris6.lex.gz")));
    classifier.loadClassifier(bis,null); bis.close();

    // configure segmenter
    SeqClassifierFlags flags = classifier.flags;
    flags.sighanCorporaDict = dataDir;
    flags.normalizationTable = dataDir + File.separator + "norm.simp.utf8";
    flags.normTableEncoding = "UTF-8";
    flags.inputEncoding = "UTF-8";
    flags.keepAllWhitespaces = true;
    flags.keepEnglishWhitespaces = true;
    flags.sighanPostProcessing = true;

    pp.segmenter = classifier;
  }
  List<String> defaultQueryPieces;
  if (pp.segmenter != null) {
    defaultQueryPieces = pp.segmenter.segmentString(defaultQuery.get(parser));
  } else {
    defaultQueryPieces = Arrays.asList(defaultQuery.get(parser).split("\\s+"));
  }
  List<HasWord> defaultQueryWords = new ArrayList<>();
  for (String s : defaultQueryPieces) {
    defaultQueryWords.add(new Word(s));
  }
  pp.parser.parseTree(defaultQueryWords);
  return pp;
}

private static final Map<String, String> nameToParserSer = new HashMap<>();
private static final Map<String, String> nameToEscaper = new HashMap<>();
private static final Map<String, ParserPack> parsers = new HashMap<>();
private static final Map<String, String> defaultQuery = new HashMap<>();

// todo: add German
static {
  nameToParserSer.put("English", "englishPCFG.ser.gz");
  nameToParserSer.put("Arabic",  "arabicFactored.ser.gz");
  nameToParserSer.put("Chinese", "chineseFactored.ser.gz");
  nameToParserSer.put("French", "frenchFactored.ser.gz");
  nameToParserSer.put("Spanish", "spanishPCFG.ser.gz");
  nameToEscaper.put("English", "edu.stanford.nlp.process.PTBEscapingProcessor");
  nameToEscaper.put("Arabic", "edu.stanford.nlp.process.PTBEscapingProcessor");
  nameToEscaper.put("Chinese", "edu.stanford.nlp.trees.international.pennchinese.ChineseEscaper");
  nameToEscaper.put("French", "edu.stanford.nlp.process.PTBEscapingProcessor");
  nameToEscaper.put("Spanish", "edu.stanford.nlp.process.PTBEscapingProcessor");
  defaultQuery.put("English", "My dog also likes eating sausage.");
  defaultQuery.put("Arabic", "هذا الرجل هو سعيد.");
  defaultQuery.put("Chinese", "猴子喜欢吃香蕉。");
  defaultQuery.put("French", "Au fond, les choses sont assez simples.");
  defaultQuery.put("Spanish", "El reino canta muy bien.");
}

private static String treeToString(Tree t, TreePrint tp) {
  StringWriter sw = new StringWriter();
  tp.printTree(t, (new PrintWriter(sw)));
  return sw.toString();
}

%>

<%

request.setCharacterEncoding("UTF-8");

String parserSelect = request.getParameter("parserSelect");
if (parserSelect == null) { parserSelect = DEFAULT_LANG; }

ParserPack pp = parsers.get(parserSelect);
if (pp == null) {
  synchronized (parsers) {
    pp = parsers.get(parserSelect);
    if (pp == null) {
      pp = loadParserPack(parserSelect, application);
      parsers.put(parserSelect, pp);
    }
  }
}
%>

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Stanford Parser</title>
    <style type="text/css">
       div.parserOutput { padding-left: 3em;
                          padding-top: 1em; padding-bottom: 0;
                          margin: 0; }
       div.parserOutputMonospace {
                          padding-top: 1em; padding-bottom: 1em; margin: 0;
                          font-family: monospace; padding-left: 3em; }
       .spacingFree { padding: 0; margin: 0; }
    </style>

    <link href="http://nlp.stanford.edu/nlp.css" rel="stylesheet"
          type="text/css" />

    <script type="text/javascript">
    //<![CDATA[
    <% ArrayList<String> langs = new ArrayList<>(nameToParserSer.keySet());
       Collections.sort(langs);  %>

    function showSample() {
      query = document.getElementById("query");
      parserSelect = document.getElementById("parserSelect");
      query.value = document.getElementById("defaultQuery."+
                 parserSelect.selectedIndex).value;
    }

    function handleOnChangeParserSelect() {
      query = document.getElementById("query");
      parserSelect = document.getElementById("parserSelect");
      for (var i = 0; i < <%= langs.size() %>; i++) {
        defaultQuery = document.getElementById("defaultQuery." + i);
        if (query.value == defaultQuery.value) {
          showSample();
          break;
        }
      }
      parseButton = document.getElementById("parseButton");
      chineseParseButton = document.getElementById("chineseParseButton");
      if (parserSelect.value == "Chinese") {
         parseButton.value = chineseParseButton.value;
      } else {
         parseButton.value = "Parse";
      }
    }
    //]]>
    </script>

    <link rel="icon" type="image/x-icon" href="/parser/favicon.ico" />
    <link rel="shortcut icon" type="image/x-icon"
       href="/parser/favicon.ico" />

  </head>

  <body>
    <%
        String query = request.getParameter("query");
        if (query == null) { query = ""; }
        query = query.replaceAll("^\\s*", "").replaceAll("\\s*$", "");
        // Deal with XSS stuff here - we just delete all angle brackets!
        query = query.replaceAll("[<>\uC0BC]", "");

        if (query.isEmpty()) { query = defaultQuery.get(parserSelect); }

        PrintWriter sentenceLog = new PrintWriter(new BufferedWriter(
                                   new FileWriter(LOG_FILENAME, true)));
        sentenceLog.printf("%s:%s: [%s] - ", new Date(), parserSelect, query);
    %>

    <h1>Stanford Parser</h1>

    <div style="margin-top: 2em;">
    <form action="index.jsp" method="post">
    <div style="width: 410px;">
    <% for (int i = 0; i < langs.size(); i++) { %>
       <input type="hidden" name="defaultQuery.<%= i %>"
              id="defaultQuery.<%= i %>"
              value="<%= defaultQuery.get(langs.get(i)).
              replaceAll("\\\\", "\\\\").replaceAll("\"", "\\\"") %>" />
    <% } %>
        <input type="hidden" name="chineseParseButton"  id="chineseParseButton"
               value = "&#21078;&#26512; (Parse)" />
        <div>
        Please enter a sentence to be parsed: <br/>
        <textarea name="query" id="query"
         style="width: 400px; height: 8em"
         rows="31" cols="7"><%= query %></textarea>
        </div>
        <div style="float: left">
        Language:
        <select name="parserSelect" id="parserSelect"
         onchange="handleOnChangeParserSelect();" >
        <% for (String lang : langs) {
             String selected = (lang.equals(parserSelect) ?
               "selected=\"selected\"" : ""); %>
           <option value="<%= lang %>" <%= selected %>><%= lang %></option>
        <% } %>
        </select>
        </div>

        <div style="float: left; padding-left: 2em;">
        <a href="#sample" onclick="showSample();">Sample Sentence</a>
        </div>

        <div style="float: right">
        <% if (parserSelect.equals("Chinese")) { %>
           <input type="submit" value="&#21078;&#26512; (Parse)"
                  name="parse" id="parseButton"/>
        <% } else { %>
           <input type="submit" value="Parse" name="parse" id="parseButton"/>
        <% } %>
        </div>
      </div>
    </form>
    </div>

    <div style="clear: left; margin-top: 3em">
    <% if ( ! StringUtils.isNullOrEmpty(query)) {
         String[] queryWords = query.split("\\s+");
         application.log("Parser query from " + request.getRemoteAddr()
           + ": " + query); %>

      <h3>Your query</h3>
      <div class="parserOutput"><em><%= query %></em></div>

      <% {
        boolean parseSuccessful = true;
        List<String> words = null;
        String toParse = null;
        long time = -System.currentTimeMillis();
        long tokens = 0;
        List<Tree> trees = new ArrayList<Tree>();

        try {
          if (pp.segmenter != null) {
            words = pp.segmenter.segmentString(query);
            toParse= ""; for (String word : words) { toParse += word + " "; }
            if (DEBUG) {
              %>Segmented String<%
              for (String word : words) { %> '<%= word %>'<br/> <% }
            }
          } else {
            toParse = query;
          }
          toParse = toParse.replaceAll("\t", " ");
          // StringReader reader = new StringReader(toParse);
          // TODO: different preprocessor for Chinese and maybe Arabic
          DocumentPreprocessor dp = new DocumentPreprocessor(new StringReader(toParse));
          dp.setTokenizerFactory(pp.tLP.getTokenizerFactory());
      List<List<HasWord>> sentences = new ArrayList<List<HasWord>>();
      for (List<HasWord> sentence : dp) {
            if (sentence.size() > MAXWORDS) {
              %>
                <p>
                  Sorry, can't parse sentences containing more than
                  <%= MAXWORDS %> words. <br/>
                  The sentence <em><%= SentenceUtils.listToString(sentence) %></em> has
                  <%= queryWords.length %> words.
                </p>
              <%
              parseSuccessful = false;
              break;
            }
            sentences.add(sentence);
            tokens += sentence.size();
            Tree tree = pp.parser.parseTree(sentence);
            if (tree == null) {
            %><!-- non-exception parse failure --><%
              parseSuccessful = false;
              break;
            }
            trees.add(tree);
          }
        } catch (Exception e) {
          parseSuccessful = false;
          %><!-- exception occured  --><%
          System.err.printf("------------------%n");
          System.err.printf("Parser Select: '%s'%n", parserSelect);
          System.err.printf("Query: '%s'%n",query);
          if (pp.segmenter != null) {
             System.err.printf("using segmenter....%n");
             System.err.printf("toParse: '%s'%n",toParse);
          }
          e.printStackTrace();
          if (DEBUG) {
            %><%= e %><br/><%
            for (StackTraceElement st : e.getStackTrace()) {
              %><%= st %><br/><%
            }
          }
        }
        time += System.currentTimeMillis();

        if (parseSuccessful) {
          sentenceLog.printf("SUCCESS%n");
          if (words != null) { %>
            <h3>Segmentation</h3>
            <div class="parserOutputMonospace">
            <% for (String word: words) { %>
              <div style="padding-right: 1em; float: left; white-space: nowrap;">
              <%= word %></div>  <% } %>
            </div><div style="clear: left"></div> <%
          }
          %>
          <h3>Tagging</h3>
          <div class="parserOutputMonospace">
          <% for (Tree parse : trees) {
               if (parse != trees.get(0)) {
                 %> <br/> <%
               }
               for (String token :
                    treeToString(parse, pp.tagPrint).split("\\s")) { %>
                 <div style="padding-right: 1em; float: left; white-space: nowrap;">
                 <%= token %></div>
          <%
               }
             }
          %>
          </div>

          <div style="clear: left"> </div>
          <h3>Parse</h3>
          <div class="parserOutput">
          <pre id="parse" class="spacingFree"><%
            for (Tree parse : trees) {
              if (parse != trees.get(0)) {
                %><%= "\n\n" %><%
              }
              %><%=
              treeToString(parse, pp.pennPrint).replaceAll("\n$", "")
              %><%
            }
          %></pre>
          </div>

          <% if (pp.tLP.supportsGrammaticalStructures()) { %>

          <h3>Universal dependencies</h3>
          <div class="parserOutput">
          <pre class="spacingFree"><%
            for (Tree parse : trees) {
              if (parse != trees.get(0)) {
                %><%= "\n\n" %><%
              }
              %><%=
              treeToString(parse, pp.typDepPrint).replaceAll("\n$","")
              %><%
            }
          %></pre>
          </div>

          <h3>Universal dependencies, enhanced</h3>
          <div class="parserOutput">
          <pre class="spacingFree"><%
            for (Tree parse : trees) {
              if (parse != trees.get(0)) {
                %><%= "\n\n" %><%
              }
              %><%=
              treeToString(parse, pp.typDepColPrint).replaceAll("\n$","")
              %><%
            }
          %></pre>
          </div>
          <% } %>

          <h3>Statistics</h3>

          <br />Tokens: <%= tokens %> <br /> Time: <%= String.format("%.3f s", time/1000.0) %> <br />
          Parser: <%= pp.modelName %> <br />

        <% } else {
          sentenceLog.printf("FAILURE%n"); %>
          <p>Sorry, failed to parse query. Is the correct language selected?</p>
        <% }
         }
       } %>
  </div>

  <% sentenceLog.close(); %>

  <p>
    <em><a href="http://nlp.stanford.edu/software/lex-parser.shtml">Back to parser home</a></em>
    <br/>
    <em>Last updated 2016-09-12</em>
  </p>

  <p style="text-align: right">
    <a href="http://validator.w3.org/check?uri=referer"><img
        style="border: 0"
        src="http://www.w3.org/Icons/valid-xhtml10"
        alt="Valid XHTML 1.0 Strict" height="31" width="88" /></a>
  </p>
  </body>
</html>
