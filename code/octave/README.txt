Karkkainen-Sanders suffix array generation in O(n)

Octave version


Functions:

suffixArrayFromFile(inFile, outFile)
  Reads inFile in plain text or FASTA, generates
  one or more suffix arrays (a deprecated FASTA format
  supports multiple entries) and writes the output to
  outFile.

  eg. usage from command line:
    octave -q --eval "suffixArrayFromFile('../../tests/test1.txt', 'out.txt')"


getSuffixArray(inputString)
  generates the suffix array from inputString and
  returns it as a return value.

  eg. usage from command line:
    octave -q --eval "getSuffixArray('BANANA')"


Please refer to the README.txt in the main directory for more read to c/p usage examples
