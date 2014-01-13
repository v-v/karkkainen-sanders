% parses a fasta or plain text file and computes the SAs for all the inputs
% fileIn     - path to input file name (plain text or FASTA (determined by format, not extension)
% fileOut - path to output file name where the SA(s) is/are written

% Both the current FASTA standard and some deprecated features are supported (like multiple entries)
% please refer to the README in the main directory for more details and usage examples

function suffixArrayFromFile(fileIn, fileOut)
	% FASTA supports multiple entries, so if we detect it, they're all stored
	% together with their identifier (given after ">")  for later processing
	% We support this although it's actually a deprecated FASTA format
	% and each sequence should be in a separate file according to the
	% newest format
	
	% Note: FASTA is recognized from the content and not from the extension!
	
	c = 0; % counts entries in file
	
	isFasta = false;
	
	% reading the input file
	fdIn = fopen(fileIn);
	
	if fdIn == -1
		disp('Cannot open input file - terminating');
		return;
	end
	
	line = fgets(fdIn);
	input = '';  % stores the input string
	
	while ischar(line)
		if line(1) == ';' || line(1) == '>' % if it's a fasta description line
			isFasta = true;
			if line(1) == '>' % sequence identifier, we store it and increase c
				c += 1;
				identifiers{c} = line(1:end-1);
				if size(input)(1) ~= 0 % if it's not the first sequence, store the previous
					sequences{c-1} = input;
					input = '';
				end
			end
		else
			if (size(line)(2) != 1) % empty lines contain one character (new line)
				line = line(1:end-1); % remove new line char (chomp)
				input = strcat(input, line);
			end
		end
			
		line = fgets(fdIn);
	end

	fclose(fdIn);
	
	% opening output file
	fdOut = fopen(fileOut ,'w'); 
	fprintf(fdOut,'test1');
	fclose(fdOut);
	
	fdOut = fopen(fileOut ,'a'); 
	fprintf(fdOut,'test2');
	fclose(fdOut);
	
	if isFasta
		% in case the FASTA file didn't have a line starting with ">"
		% (multiple entries should have identifiers preceded with ">")
		% but just a ";" line
		if c == 0 % only one sequence with no identifier in FASTA
			
			% FASTA entries can have * as a termination	
			% but it's not mandatory, so we remove it
			% and later the getSuffixArray function adds a termination
			% to the input string
			if input(end) == '*'
				input = input(1:end-1);
			end;
			
			% fasta accepts lowe case characters and they area
			% automatically converted to upper case
			input = upper(input);
			
			for i = 1:size(input)(2)
				if double(input(1,i)) < '-' || (   double(input(1,i))   > '-'  && ( double(input(1,i)) < 'A' || double(input(1,i)) > 'Z' ) )
					disp('Invalid character in FASTA format:');
					disp(uint8(input(1,i)));
					return;
				end
			end
			
			SA = getSuffixArray(input);
			
			% we have to test if the output location is writable since
			% dlmwrite does not return a value but just rises an error
			fdOut = fopen(fileOut ,'w'); 
			if fdOut == -1
				disp('Cannot write to output location - terminating');
				return;
			end
			fclose(fdOut);
		
			% writing the suffix array to the output file
			dlmwrite(fileOut, SA, 'delimiter', ' ')
		
			
		else % one or multiple sequences with identifiers in FASTA
			sequences{c} = input; % add the last one

			% create file (recreate if it already existed)
			fdOut = fopen(fileOut ,'w'); 
			if fdOut == -1
				disp('Cannot write to output location - terminating');
				return;
			end
			fclose(fdOut);			
			
			% iterate over all arrays in the input FASTA file
			for i = 1:c		
				% write description of arrayfun
				fdOut = fopen(fileOut ,'a'); 
					fprintf(fdOut, "%s\n", identifiers{1,i});
				fclose(fdOut);	
				
				input = sequences{1, i};
				% FASTA entries can have * as a termination
				% but it's not mandatory, so we remove it
				% and later the getSuffixArray function adds a termination
				% to the input string
				if input(end) == '*'
					input = input(1:end-1);
				end;
				
				% lowercase chars are accepted and converted to uppercase
				input = upper(input);
				
				for i = 1:size(input)(2)
					if double(input(1,i)) < '-' || (   double(input(1,i))   > '-'  && ( double(input(1,i)) < 'A' || double(input(1,i)) > 'Z' ) )
						disp('Invalid character in FASTA format : ');
						disp(uint8(input(1,i)));
						return;
					end
				end
				
				SA = getSuffixArray(input);
				
				dlmwrite(fileOut, SA, '-append', 'delimiter', ' ')
			end
		end

	else  % plain text fileIn (just one array)
		
		SA = getSuffixArray(input);
		
		
		% we have to test if the output location is writable since
		% dlmwrite does not return a value but just rises an error
		fdOut = fopen(fileOut ,'w'); 
		if fdOut == -1
			disp('Cannot write to output location - terminating');
			return;
		end
		fclose(fdOut);
		
		% writing the suffix array to the output file
		dlmwrite(fileOut, SA, 'delimiter', ' ')
		
	end
