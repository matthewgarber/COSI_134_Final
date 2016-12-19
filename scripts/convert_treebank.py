#!/bin/python3

"""
Author: Matthew Garber
Class: COSI 134
Semester: Fall 2016
Final Project

This program fills in the XPOSTAG field (the language specific tag field) with
the UPOSTAG field (the universal tag field), which is left as an '_' in the
UD_Spanish treebank. See <http://universaldependencies.org/format.html> for more
information on the CoNLL-U dependency format.

To run:
    python convert_treebank.py <original-treebank-filepath> <altered-treebank-filepath>
"""

import sys

def convert_corpus(corpus_path, new_path):

    new_lines = []
    with open(corpus_path) as corpus:
        lines = list(corpus.readlines())
        for line in lines:
            # Keep newlines and commented lines
            if line.startswith('#') or line.startswith('\n'):
                new_lines.append(line)
            else:
            # Set XPOSTAG as UPOSTAG
                fields = line.split('\t')
                fields[4] = fields[3]
                new_line = '\t'.join(fields)
                new_lines.append(new_line)

    with open(new_path, 'w') as new_corpus:
        # Write the altered treebank file.
        new_corpus.writelines(new_lines)

if __name__ == '__main__':
    corpus_path = sys.argv[1]
    new_path = sys.argv[2]
    convert_corpus(corpus_path, new_path)
