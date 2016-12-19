#!/bin/python2

"""
Author: Matthew Garber
Class: COSI 134
Semester: Fall 2016
Final Project

This program converts Polyglot word embedding files from their pickle (.pkl)
format into a text (.txt) format.

To run:
    python convert_embeddings.py <pickle-filename> <text-filename>
"""

import codecs
import sys
import pickle

def main(words, vectors, converted_path):
    with codecs.open(converted_path, 'w', encoding='utf8') as converted_file:
        for w, v in zip(words, vectors):
            vector_string = ' '.join(str(x) for x in list(v))
            line = ' '.join([w, vector_string]) + '\n'
            converted_file.write(line)

if __name__ == '__main__':
    f = open(sys.argv[1])
    words, vectors = pickle.load(f)
    converted_path = sys.argv[2]
    main(words, vectors, converted_path)
