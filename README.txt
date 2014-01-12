code - contains the source code implementations in various languages

tests - contains tests of different sizes and formats

Running examples:
====================

Assmuption: running from current directory where this file is located

Java:
time java -jar code/java/suffixArray.jar tests/testBig100000.txt out.txt

Octave:
time ./memusg octave -q --path code/octave/ --eval "suffixArrayFromFile('tests/testBig10000.txt', 'out.txt')"

C#:
time ./memusg code/c#/Bioinf-labos.exe tests/testBig1000000.txt out.txt

Python:
time ./memusg python code/python/projekt_v3.py tests/testBig1000000.txt out.txt

Perl:
time ./memusg perl code/perl/SuffixArrayPretty.pl tests/testBig1000000.txt out.txt


About tests:

testsBigXYZ.txt
- are tests of XYZ uniformly sampled random characters.
- They are used for testing the speeds and memory usages of the various
  implementations.

test1.txt and test2.txt
- They tests the algorithms for correct output given a FASTA input
- the output of the program shell be compared to output1.txt or
  output2.txt accordingly.
