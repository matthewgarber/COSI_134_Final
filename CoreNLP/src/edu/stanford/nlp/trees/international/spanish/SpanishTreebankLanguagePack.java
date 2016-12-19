package edu.stanford.nlp.trees.international.spanish;

import edu.stanford.nlp.international.morph.MorphoFeatureSpecification;
import edu.stanford.nlp.international.spanish.process.SpanishTokenizer;
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.process.CoreLabelTokenFactory;
import edu.stanford.nlp.process.TokenizerFactory;
import edu.stanford.nlp.trees.AbstractTreebankLanguagePack;
import edu.stanford.nlp.trees.CollinsHeadFinder;
import edu.stanford.nlp.trees.HeadFinder;


/**
 * Language pack for the Spanish treebank.
 *
 * @author mcdm
 */
public class SpanishTreebankLanguagePack extends AbstractTreebankLanguagePack {

  private static final long serialVersionUID = -7059939700276532428L;

  // The AnCora treebank is distributed in ISO 8859-1 XML, but the
  // processed treebank (PTB-style) is UTF-8
  public static final String STB_ENCODING = "ISO8859_1";

  private static final String[] punctTags = {
    "PUNCT"
  };

  private static final String[] sentenceFinalPunctTags = {
    "PUNCT"
  };

  private static final String[] punctWords = {
    "¡", "!", ",", "[", "]", ":", "\"", "-", "/", "¿", "?", "{", "}", ".",
    "=LRB=", "=RRB=", "«", "»", "…", "...", "%", ";", "_", "+", "=", "&", "@"
  };

  private static final String[] sentenceFinalPunctWords = {
    "!", "?", ".", "…", "..."
  };

  private static final String[] startSymbols = {"ROOT"};

  private static final char[] annotationIntroducingChars = {'^', '[', '-'};

  /**
   * Return the input Charset encoding for the Treebank. See
   * documentation for the <code>Charset</code> class.
   *
   * @return Name of Charset
   */
  @Override
  public String getEncoding() {
    return STB_ENCODING;
  }

  /**
   * Return a tokenizer which might be suitable for tokenizing text that will be used with this
   * Treebank/Language pair, without tokenizing carriage returns (i.e., treating them as white
   * space).  The implementation in AbstractTreebankLanguagePack returns a factory for {@link
   * edu.stanford.nlp.process.WhitespaceTokenizer}.
   *
   * @return A tokenizer
   */
  @Override
  public TokenizerFactory<? extends HasWord> getTokenizerFactory() {
    return SpanishTokenizer.factory(new CoreLabelTokenFactory(),
        "invertible,ptb3Escaping=true,splitAll=true");
  }

  /**
   * Returns a String array of punctuation tags for this treebank/language.
   *
   * @return The punctuation tags
   */
  @Override
  public String[] punctuationTags() {
    return punctTags;
  }


  /**
   * Returns a String array of punctuation words for this treebank/language.
   *
   * @return The punctuation words
   */
  @Override
  public String[] punctuationWords() {
    return punctWords;
  }


  /**
   * Returns a String array of sentence final punctuation tags for this
   * treebank/language.
   *
   * @return The sentence final punctuation tags
   */
  @Override
  public String[] sentenceFinalPunctuationTags() {
    return sentenceFinalPunctTags;
  }

  /**
   * Returns a String array of sentence final punctuation words for this
   * treebank/language.
   *
   * @return The sentence final punctuation tags
   */
  public String[] sentenceFinalPunctuationWords() {
    return sentenceFinalPunctWords;
  }

  /**
   * Return an array of characters at which a String should be truncated to give the basic syntactic
   * category of a label. The idea here is that Penn treebank style labels follow a syntactic
   * category with various functional and crossreferencing information introduced by special
   * characters (such as "NP-SBJ=1").  This would be truncated to "NP" by the array containing '-'
   * and "=".
   *
   * @return An array of characters that set off label name suffixes
   */
  @Override
  public char[] labelAnnotationIntroducingCharacters() {
    return annotationIntroducingChars;
  }

  /**
   * Returns a String array of treebank start symbols.
   *
   * @return The start symbols
   */
  @Override
  public String[] startSymbols() {
    return startSymbols;
  }

  /**
   * Returns the extension of treebank files for this treebank.
   */
  public String treebankFileExtension() {
    return "xml";
  }

  /** {@inheritDoc} */
  public HeadFinder headFinder() {
    return new SpanishHeadFinder(this);
  }

  /** {@inheritDoc} */
  public HeadFinder typedDependencyHeadFinder() {
    return new SpanishHeadFinder(this);
  }

}
