package edu.stanford.nlp.simple;

import edu.stanford.nlp.io.IOUtils;
import edu.stanford.nlp.io.RuntimeIOException;
import edu.stanford.nlp.pipeline.CoreNLPProtos;

import java.io.IOException;
import java.util.List;
import java.util.Properties;

/**
 * A {@link Sentence}, but in Spanish.
 *
 * @author <a href="mailto:angeli@cs.stanford.edu">Gabor Angeli</a>
 */
public class SpanishSentence extends Sentence {

  /** A properties object for creating a document from a single sentence. Used in the constructor {@link Sentence#Sentence(String)} */
  static Properties SINGLE_SENTENCE_DOCUMENT = new Properties() {{
    try {
      load(IOUtils.getInputStreamFromURLOrClasspathOrFileSystem("edu/stanford/nlp/pipeline/StanfordCoreNLP-spanish.properties"));
    } catch (IOException e) {
      throw new RuntimeIOException(e);
    }
    setProperty("language", "spanish");
    setProperty("annotators", "");
    setProperty("ssplit.isOneSentence", "true");
    setProperty("tokenize.class", "PTBTokenizer");
    setProperty("tokenize.language", "es");
  }};

  /** A properties object for creating a document from a single tokenized sentence. */
  private static Properties SINGLE_SENTENCE_TOKENIZED_DOCUMENT = new Properties() {{
    try {
      load(IOUtils.getInputStreamFromURLOrClasspathOrFileSystem("edu/stanford/nlp/pipeline/StanfordCoreNLP-spanish.properties"));
    } catch (IOException e) {
      throw new RuntimeIOException(e);
    }
    setProperty("language", "spanish");
    setProperty("annotators", "");
    setProperty("ssplit.isOneSentence", "true");
    setProperty("tokenize.class", "WhitespaceTokenizer");
    setProperty("tokenize.language", "es");
    setProperty("tokenize.whitespace", "true");  // redundant?
  }};

  public SpanishSentence(String text) {
    super(new SpanishDocument(text), SINGLE_SENTENCE_DOCUMENT);
  }

  public SpanishSentence(List<String> tokens) {
    super(SpanishDocument::new, tokens, SINGLE_SENTENCE_TOKENIZED_DOCUMENT);
  }

  public SpanishSentence(CoreNLPProtos.Sentence proto) {
    super(SpanishDocument::new, proto, SINGLE_SENTENCE_DOCUMENT);
  }

}
