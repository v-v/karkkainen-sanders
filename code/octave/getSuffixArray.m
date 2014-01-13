% getSuffixArray(input_string) generates a suffix array
% input_string - string on wich an SA is computed

% This function is case sensitive - if you want case unsensitivity
% it should be taken care elsewhere (eg. suffixArrayFromFile()
% automatically converts lowercase characters to upper case if
% a FASTA input is detected (fasta supports lowercase inputs)
% but differentiates between cases for a plain text input)

% Note: the termination character is the lowest of the alphabet

function res = getSuffixArray(in)
	len = size(in)(2);

	% convert the string to an array of integers
	s = in - ' ';

	% test if it's alphanumeric
	if (min(s) >= 0 && max(s) <= '~' - ' ')
		% aggregate the alphabet
		% for the input string
		alphabet = unique(s);

		% size of the alphabet
		K = size(alphabet)(2);

		% creating a map of characters so that
		% we can find their order in O(1) -
		% this uses some memory but it's faster
		% Another option would be to do 
		% multiple find() operations, but that
		% would be less efficient
		for i = 1:K
			char_map(alphabet(i)) = i;
		end


		% generating an integer representation
		% of the input string
		% the smallest character becomes a 2
		% in its integer representation, the next
		% one 3 and so on.
		for i = 1:len
			sn(i) = char_map(s(i)) + 1;
		end
		
		% at the end we add a termination character
		% - the smallest one: 1
		% (all the other characters starts from 2
		% uncomment this if you want to include
		% the termination character to the SA
		% sn(len+1) = 1;


		% adding three zeros in the end for the
		% case that the lenghts is not % 3
		sn(len+2:len+4) = 0;


		
		% ucomment this if you want the
		% termination char  to be included
		% res = suffixArray(sn, len+1, K+1);
		res = suffixArray(sn, len, K+1);
		
	else
		disp('getSuffixArray(s): input string s should be alphanumeric');
		res = 0;
	end
