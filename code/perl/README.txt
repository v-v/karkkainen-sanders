prerequisites - perl

running the script:
	perl SuffixArray.pl inputfile outputfile

	
input can be
 - a text containing only printable ascii characters (between 32 and 126) and one sequence
		- newline is ignored
 - a file in fasta format containing only uppercased letters and hyphens
        - newline is ignored
		- line with sequence description is ignored
		- multiple sequences are possible

output
 - plain text - single line with a suffix array represented as a sequence of numbers divided with space
 - fasta - sequence description and then a line with the suffix array

please refer to the examples of the input and output files:
  - regular.txt, regularSA.tx
  - fasta.txt, fastaSA.txt
 
 
script terminates with an error
 - if the number input string is in the incorrect format
 - if the number of input arguments is not equal to 2
 
 