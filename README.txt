code - contains the source code implementations in various languages

tests - contains tests of different sizes and formats

Running examples:
====================

Assmuption: running from current directory where this file is located

Java:
java -jar code/java/Bioinformatika.jar tests/test1.txt out.txt

Octave:
octave -q --path code/octave/ --eval "suffixArrayFromFile('tests/test1.txt', 'out.txt')"

C#:
code/c#/Bioinf-labos.exe tests/test1.txt out.txt

Python:
python code/python/projekt_v4.py tests/test1.txt out.txt

Perl:
perl code/perl/SuffixArrayAgain.pl tests/test1.txt out.txt


About tests:
-----------

testsBigXYZ.txt
- are tests of XYZ uniformly sampled random characters.
- They are used for testing the speeds and memory usages of the various
  implementations (time(1) and the script memusg are used for so)

test1.txt and test2.txt
- They tests the algorithms for correct output given a FASTA input
- the output of the program shell be compared to output1.txt or
  output2.txt accordingly.

test-deprecated-fastaX.txt
- Those tests are for some deprecated FASTA features like supporting 
  multiple entries in one file, comments, possibility of * indicating
  a termination character in the end etc.
- Please not that only the octave version supports this.
- Eg: octave -q --path code/octave/ --eval "suffixArrayFromFile('tests/test-deprecated-fasta3.txt', 'out.txt')"
