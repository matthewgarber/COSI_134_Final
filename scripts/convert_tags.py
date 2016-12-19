#!/bin/python3

"""
Author: Matthew Garber
Class: COSI 134
Semester: Fall 2016
Final Project

This program converts the universal POS tags in a CoNLL-U format treebank to a
more finely-grained tagset based on the EAGLES tagset. The XPOSTAG field of the
treebank must use the universal POS tagset, rather than a language-specific
tagset. The granularity of the tagset is taken as a command-line argument.
'0' corresponds to the 'Low' tagset; '1' corresponds to the 'Mid' tagset. See
Appendix A in the paper for more detail on these tagsets.

To run:
    python convert_tags.py <treebank-filepath> <altered-treebank-filepath> <granularity>
"""

import sys

# This dictionary maps values of the morphological features to the character
# used to represent that value in the EAGLES tagset.
value_dict = {'Fem' : 'f',
              'Masc' : 'm',
              'Sing' : 's',
              'Plur' : 'p',
              'Fin' : 'f',
              'Inf' : 'i',
              'Part' : 'p',
              'Ger' : 'g',
              '0' : '0',
              '1' : '1',
              '2' : '2',
              '3' : '3',
              }
              
def add_feat_to_base(base, i, feat, feature_dict):
    """Adds the morphological feature to the base tag.

    Args:
        base: The base POS tag, as a list of characters.
        i: The index of the character in the base tag where this particular
            feature is encoded.
        feat: The morphological feature.
        feature_dict: A dict mapping morphological features to their values.
    """
    raw = feature_dict.get(feat, '0')
    base[i] = value_dict.get(raw, '0')

def feat2tag(word, coarse_tag, feature_string, granularity=0):
    """Converts the given coarse tag into a finer-grained tag.

    Args:
        word: The word the POS tag applies to.
        coarse_tag: The coarse universal POS tag.
        feature_string: The string containing the morphological features.
        granularity: 0 for 'Low', 1 for 'Mid'.
    Returns:
        A finer-grained tag.
    """
    # Convert the feature string into a dict mapping the features to their values.
    features = [feat.split('=') for feat in feature_string.split('|')]
    feature_dict = dict(features)
    base = None
    final_tag = None
    
    if coarse_tag == 'NOUN':
        base = ['n', 'c', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 2, 'Gender', feature_dict)
        add_feat_to_base(base, 3, 'Number', feature_dict)
        
    elif coarse_tag == 'DET':
        base = ['d', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 3, 'Gender', feature_dict)
        add_feat_to_base(base, 4, 'Number', feature_dict)
        if granularity > 0:
            add_feat_to_base(base, 2, 'Person', feature_dict)
        
    elif coarse_tag == 'VERB':
        base = ['v', 'm', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 4, 'Person', feature_dict)
        add_feat_to_base(base, 5, 'Number', feature_dict)
        if granularity > 0:
            add_feat_to_base(base, 2, 'VerbForm', feature_dict)
        
    elif coarse_tag == 'PRON':
        base = ['p', '0', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 3, 'Gender', feature_dict)
        add_feat_to_base(base, 4, 'Number', feature_dict)
        if granularity > 0:
            add_feat_to_base(base, 2, 'Person', feature_dict)
        
    elif coarse_tag == 'ADJ':
        base = ['a', '0', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 3, 'Gender', feature_dict)
        add_feat_to_base(base, 4, 'Number', feature_dict)
        
    elif coarse_tag == 'AUX':
        base = ['v', 'a', '0', '0', '0', '0', '0']
        add_feat_to_base(base, 4, 'Person', feature_dict)
        add_feat_to_base(base, 5, 'Number', feature_dict)
        if granularity > 0:
            add_feat_to_base(base, 2, 'VerbForm', feature_dict)

    elif coarse_tag == 'ADV':
        base = ['r', '0']
        if word.lower() == 'no':
            base[1] = 'n'

    return ''.join(base)

def convert_corpus(corpus_path, new_path, granularity):
    # The types of tags to refine.
    tags_to_refine = {'NOUN', 'DET', 'VERB', 'PRON', 'ADJ', 'ADV', 'AUX'}
    new_lines = []
    with open(corpus_path) as corpus:
        lines = list(corpus.readlines())
        for line in lines:
            if line.startswith('#') or line.startswith('\n'):
                new_lines.append(line)
            else:
                fields = line.split('\t')
                coarse_tag = fields[4]
                if coarse_tag in tags_to_refine:
                    word = fields[1]
                    feature_string = fields[5]
                    if feature_string == '_':
                        feature_string = '_=_'
                    new_tag = feat2tag(word, coarse_tag, feature_string,
                                       granularity=granularity)
                    fields[4] = new_tag
                new_line = '\t'.join(fields)
                new_lines.append(new_line)

    with open(new_path, 'w') as new_corpus:
        # Write the new treebank.
        new_corpus.writelines(new_lines)

if __name__ == '__main__':
    corpus_path = sys.argv[1]
    new_path = sys.argv[2]
    granularity = int(sys.argv[3])
    convert_corpus(corpus_path, new_path, granularity)
