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


Tests:
------

There are 3 examples of the deprecated FASTA format that this code supports. This includes
accepting multiple sequences, * that can be set (but is not mandatory) at the end of the
sequence and so on.

Example:

Assuming everything is run from this current directory (if not, add --path argument before
--eval)

octave -q --eval "suffixArrayFromFile('test-deprecated-fasta3.txt', 'out.txt')


Please refer to the README.txt in the main directory for more ready to c/p usage examples
and tests from the tests/ directory.
