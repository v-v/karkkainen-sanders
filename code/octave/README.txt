Karkkainen-Sanders suffix array generation in O(n)

Octave version

copyright (C) 2014  Vedran Vukotic


Functions:

suffixArrayFromFile(inFile, outFile)
  Reads inFile in plain text or FASTA, generates
  one or more suffix arrays (a deprecated FASTA format
  supports multiple entries) and writes the output to
  outFile.

  eg. usage from command line:
    octave -q --eval "suffixArrayFromFile('../../tests/test1.txt', '../../tests/out.txt')"


getSuffixArray(inputString)
  generates the suffix array from inputString and
  returns it as a return value.

  eg. usage from command line:
    octave -q --eval "getSuffixArray('BANANA')"
