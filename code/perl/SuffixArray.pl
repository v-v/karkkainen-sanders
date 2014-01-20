#perl implementation of Karkkainen-Sanders algorithm for constructing Suffix arrays
#arguments of the script: names of the input and output files
#supported formats: fasta and plain text (ascii format)

#only global variables are used, therefore no subroutine takes in an argument
#stack is replaced with the following: 
#S - array of suffix arrays through recursion
#s - array of input arrays through recursion
#n - list of lengths of input arrays through recursion
#n0 - list of lengths of mod 3 = 0 suffix arrays
#n1 - list of numbers indicating whether the input length %3 == 1
#K - list of maximum values of inputs through recursive calls of SuffixArray

#rec - counts the number of recursive calls of SuffixArray

#with regards to the C++ Weese implementation of the algorithm, referencing is as follows:
#$S[$rec] == S12, $S[$rec - 1] == SA
#$s[$rec] == s12, $s[$rec - 1] == s
#$K[$rec - 1] == K
#$n[$rec] == n02, $n[$rec - 1] == n
#$n0[$rec] == n0
#$n1[$rec]== n1

#generates SA12 - an array of indexes of triplets at mod 3 = 1 & mod 3 = 2 positions
#the array is stored into an array of SA12 arrays
sub get12Pos
{
	for $i (0..$n[$rec - 1] + ($n0[$rec] - $n1[$rec] - 1))
	{
		if ($i%3 != 0)
		{
			push @{$s[$rec]}, $i;
		}
	}
}

#uses counting sort algorithm to sort triplets
sub radixPass
{
	@c = ();
	
	#creates a counter
	for (0..$K[$rec - 1])
	{
		push @c, 0;
	}
	
	#counts the number of occurrences of character at a given index 
	for $i (0..$loop)
	{
		$index = $indices -> [$i] + $offset;
		$c[$s[$rec - 1][$index]] ++;
	}
	
	#calculates the beginning positions in the resulting string
	#for each character 
	$start = 0;
	for $i (0..$K[$rec - 1])
	{
		$temp = shift @c;
		push @c, $start;
		$start += $temp;
	}
	
	#inserts the indices at a specified positions
	for $i (0..$loop)
	{
		$indexString = $indices -> [$i] + $offset;
		$indexResult = $c[$s[$rec - 1][$indexString]];
		$result -> [$indexResult] = $indices -> [$i];
		$c[$s[$rec - 1][$indexString]] ++;
	}	
}

#sorts S12 using three radixPasses
sub radixSort
{
	$loop = $n[$rec] - 1;
	$offset = 2;
	$indices = \@{$s[$rec]};
	$result = \@{$S[$rec]};	
	&radixPass();
	$offset = 1;
	$indices = \@{$S[$rec]};
	$result = \@{$s[$rec]};
	&radixPass();
	$offset = 0;
	$indices = \@{$s[$rec]};
	$result = \@{$S[$rec]};
	&radixPass();	
}

#names the sorted triplets of the S12 array
#returns true if equal triplets exist
sub nameTriplets
{
	push @s, [];
	$name = 0;
	$c0 = -1;
	$c1 = -1;
	$c2 = -1;

	
	for $i (@{$S[$rec]})
	{
		#increase number of different triplets if a new triplet is found
		if ($s[$rec - 1][$i] != $c0 || $s[$rec - 1][$i + 1] != $c1 || $s[$rec - 1][$i + 2] != $c2)
		{
			$name ++;
			$c0 = $s[$rec - 1][$i];
			$c1 = $s[$rec - 1][$i + 1];
			$c2 = $s[$rec - 1][$i + 2];
		}
		
		#insert the name in s12
		#if index mod 3 == 2 put the triplet in the second half of S12
		if ($i % 3 == 1)
		{
			$s[$rec][($i - 1)/3] = $name;
		}
		else
		{
			$s[$rec][($i - 2)/3 + $n0[$rec]] = $name;
		}
	}
	$name < $n[$rec];
}

#creates and then sorts S0 using the sorted suffixes at mod 3 = 1 positions
#and one radixPass
sub sortN0
{  
    @s0 = ();
	@S0 = ();
	for $i (@{$S[$rec]})
	{
		if ($i < $n0[$rec])
		{
			push @s0, 3 * $i;
		}
	}
	$offset = 0;
	$indices = \@s0;
	$result = \@S0;
	$loop = $n0[$rec] - 1;
	&radixPass();
}

#compares a triplet from S0 with a triplet from S12
sub compare
{
	if ($S[$rec][$t] < $n0[$rec])
	{
		#compares an S0 triplet with suffixes at mod 3 = 1 positions
		$s[$rec - 1][$o1]  < $s[$rec - 1][$o2] ||
			$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec][$S[$rec][$t] + $n0[$rec]] < $s[$rec][$o2 / 3 ];
	}
	else
	{
		#compares an S0 triplet with suffixes at mod 3 = 2 positions
		($s[$rec - 1][$o1] < $s[$rec - 1][$o2]) || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] < $s[$rec - 1][$o2 + 1] || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] == $s[$rec - 1][$o2 + 1] && $s[$rec][$S[$rec][$t] - $n0[$rec] + 1] < $s[$rec][$o2/3 + $n0[$rec]];
	}
}

#merges S0 and S12 to create the final suffix array
sub merge
{
	$p = 0;
	$t = $n0[$rec] - $n1[$rec];

	$j = 0;
	$o1 = ($S[$rec][$t] < $n0[$rec]) ? ($S[$rec][$t] * 3 + 1) : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
	$o2 = $S0[$p];
	while($j < $n[$rec - 1])
	{
		if (&compare())
		{
			#inserts S12 suffix
			$S[$rec - 1][$j] = $o1;
			$t ++;
			$j ++;
			
			
			if ($t == $n[$rec])
			{
				#if all the S12 suffixes have been inserted, insert remaining S0 suffixes
				while ($p < $n0[$rec])
				{
					$S[$rec - 1][$j] = $S0[$p];
					$p ++;
					$j ++;
				}
			}
			else
			{
				#otherwise, take a new S12 triplet 
				$o1 = ($S[$rec][$t] < $n0[$rec]) ? ($S[$rec][$t] * 3 + 1) : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
			}
		}
		else
		{
			$S[$rec - 1][$j] = $o2;
			$p ++;
			$j ++;
			if ($p == $n0[$rec])
			{
				#if all the S0 suffixes have been inserted, insert remaining S12 suffixes
				while ($t < $n[$rec])
				{
					$S[$rec - 1][$j] = ($S[$rec][$t] < $n0[$rec]) ? ($S[$rec][$t] * 3 + 1) : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
					$t ++;
					$j ++;
				}
			}
			else
			{
				#otherwise, take a new S12 triplet
				$o2 = $S0[$p];
			}
		}
	}
}

#calculates the suffix array
sub suffixArray
{
	push @n0, int (($n[$rec - 1] + 2) / 3);
	push @n1, int (($n[$rec - 1] + 1) / 3);
	push @n, $n0[$rec] + int($n[$rec - 1] / 3);

	
	&get12Pos();
	&radixSort();
	
	
	if (&nameTriplets())
	{
		#if equal triplets exist, recurse 
		push @{$s[$rec]}, 0, 0, 0;
		push @K, $name;
		$rec ++;		
		&suffixArray();
		$rec --;
		pop @K;
		#create names for a resulting suffix array
		for $i (0..$n[$rec] - 1)
		{
			$s[$rec][$S[$rec][$i]] = $i + 1;
		}
	}
	else
	{
		#if all of the names are unique create the S12 suffix array
		for $i (0..$n[$rec] - 1)
		{
			$S[$rec][$s[$rec][$i] - 1] = $i;
		}
	}
	&sortN0();	
	&merge();
}

#prints the rcalculated suffix array to output file
sub printToFile
{
	print OUTFILE $stringName;
	for $j (@{$S[0]})
	{
		print OUTFILE $j, " ";
	}
	print OUTFILE "\n";
}

#calculates the suffix array for one sequence in fasta format in the input file
sub fastaCall
{
	$string = uc $string;
	
	#initializes the stack
	@s = ();
	@n0 = ();
	@n1 = ();
	@n = ();
	@S = ();
	@K = ();
	
	#gets the input sequence, and converts it to an array of integers
	push @s, [unpack("C*", $string)];
	push @n0, 0;
	push @n1, 0;
	#calculates the length of the original string
	push @n, $#{$s[0]} + 1;
	
	$max = 0;
	$count = 0;
	#gets the maximum value in a sequence
	for $i (@{$s[0]})
	{
		$count ++;
		#a fasta file can only contain uppercased letters or a minus (-)
		if (!($i >= 65 && $i <= 90 || $i == 45))
		{
			die "Error: incorrect fasta - only alpha characters, a dash and a star allowed\n";
		}				
		if ($i > $max)
		{
			$max = $i;
		}
	}
	
	push @K, $max;
	#adds required additional zeros
	push @{$s[0]}, 0, 0, 0;
	push @S, [(1)];
	$rec = 1;

	&suffixArray();	
	&printToFile();
}

#calculates the suffix arrays for all of the sequences in fasta format in the input file
sub doFasta
{
	$string = "";
	$stringName = $firstLine;
	while (<INFILE>) 
	{
		if (substr($_, 0, 1) eq ">")
		{
			#if a line is a fasta comment calculate the suffix array for the previous sequence
			&fastaCall();
			#reinitialize the variables
			$stringName = $_;
			$string = <INFILE>;
		}
		else
		{
			#otherwise, concatenate the string and remove and remove newline
			chomp ($string .= $_);
		}
	} 
	continue 
	{
        close INFILE if eof;
    }
	#calculate suffixArray for the last sequence
	&fastaCall();
}

#calculates the suffix array for a regular text file
sub doRegular
{
	
	$string = $firstLine;
	chomp $string;
	#reads in a sequence
	while (<INFILE>) 
	{
		$string .= $_;
		chomp $string;
	} 
	continue 
	{
        close INFILE if eof;
    }
	#gets the input sequence, and converts it to an array of integers
	push @s, [unpack("C*", $string)];
	
	#initialize the stack
	$nPrev = $#{$s[0]} + 1;
	push @n, $nPrev;
	push @n0, 0;
	push @n1, 0;
	$max = 0;
	#find the maximum value in the input string
	for $i (@{$s[0]})
	{
		#only printable characters and whitespace are allowed in the plain text
		if (!($i >= 32 && $i <= 126))
		{
			die "Error: incorrect regular file - only Ascii characters between 32 and 126 allowed\n";
		}			
		if ($i > $max)
		{
			$max = $i;
		}
	}
	
	push @K, $max;
	push @{$s[0]}, 0, 0, 0;
	push @S, [];
	$rec = 1;
	
	&suffixArray();
	&printToFile();
}

#the programme requires 2 arguments
if ($#ARGV != 1)
{
	die "Error: input and output file required\n";
}
#open the required files
open INFILE, "<", $ARGV[0];
open OUTFILE, ">", $ARGV[1];
$firstLine = <INFILE>;

#check format
if ( substr($firstLine, 0, 1) eq ">")
{
	&doFasta();
}
else
{
	&doRegular();
}

close OUTFILE;