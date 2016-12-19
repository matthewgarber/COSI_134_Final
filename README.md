# COSI_134_Final

Author: Matthew Garber
Class: COSI 134
Semester: Fall 2016
Final Project

This file provides description of the several subdirectories and files. It
assumes that all compressed folders have been unzipped.

== CoreNLP ==

Contains the source .java files for the Stanford CoreNLP suite. Minor edits
have been made to these files, as described in the paper. See the CoreNLP
documentation for more information on the various subdirectories and java files.

== Compiled_CoreNLP ==

Contains the compiled .class files for the Stanford CoreNLP suite. These have
been compiled from the edited source files.

== embeddings ==
  - english_embeddings.txt
  - spanish_embeddings.txt
  
Contains 64-dimensional word embedding files for English and Spanish which are
used in training the dependency parser models.

== models ==

Contains 10 model files for Stanford neural network dependency parser.
Each file name is in the format
  nndep.h<XXX>-<tagset>.txt.gz
where <XXX> is the size of the hidden layer of the neural network and <tagset>
is name of the tagset used in the model. All tagsets are for Spanish except for
'eng-baseline'. Please refer to Appendix A in the paper for more information
regarding the tagsets.

== paper ==
  - StatNLP_final_paper.pdf

Contains the final paper.

== scripts ==
  - convert_embeddings.py
  - convert_tags.py
  - convert_to_stanford_tags.py
  - convert_treebank.py

Contains scripts used to convert the raw word embedding files and the original
treebanks to their current forms. Please refer to the individual files on how
to use them from the command line.

== ud-treebanks-v1.4 ==
  = EN-Baseline =
    Contains the converted English baseline treebanks.
  = ES-Basline =
    Contains the converted Spanish baseline treebanks.
  = Low =
    Contains the Spanish treebanks using the 'Low' tagset.
  = Mid =
    Contains the Spanish treebanks using the 'Mid' tagset.
  = Stanford =
    Contains the Spanish treebanks using the 'Stanford' tagset.
  
Contains the treebanks used to train the various dependency parser models. Each
treebank subdirectory contains a train, dev, and test set.

COSI 134 Final Project
