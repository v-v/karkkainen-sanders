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

sub radixPass
{
	@c = ();
	
	for (0..$K[$rec - 1])
	{
		push @c, 0;
	}
	
	for $i (0..$loop)
	{
		$index = $indices -> [$i] + $offset;
		$c[$s[$rec - 1][$index]] ++;
	}
	
	$start = 0;
	for $i (0..$K[$rec - 1])
	{
		$temp = shift @c;
		push @c, $start;
		$start += $temp;
	}
	
	for $i (0..$loop)
	{
		$indexString = $indices -> [$i] + $offset;
		$indexResult = $c[$s[$rec - 1][$indexString]];
		$result -> [$indexResult] = $indices -> [$i];
		$c[$s[$rec - 1][$indexString]] ++;
	}	
}

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

sub nameTriplets
{
	push @s, [];
	$name = 0;
	$c0 = -1;
	$c1 = -1;
	$c2 = -1;

	
	for $i (@{$S[$rec]})
	{
		if ($s[$rec - 1][$i] != $c0 || $s[$rec - 1][$i + 1] != $c1 || $s[$rec - 1][$i + 2] != $c2)
		{
			$name ++;
			$c0 = $s[$rec - 1][$i];
			$c1 = $s[$rec - 1][$i + 1];
			$c2 = $s[$rec - 1][$i + 2];
		}
		
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

sub compare
{
	if ($S[$rec][$t] < $n0[$rec])
	{
		$s[$rec - 1][$o1]  < $s[$rec - 1][$o2] ||
			$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec][$S[$rec][$t] + $n0[$rec]] < $s[$rec][$o2 / 3 ];
	}
	else
	{
		($s[$rec - 1][$o1] < $s[$rec - 1][$o2]) || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] < $s[$rec - 1][$o2 + 1] || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] == $s[$rec - 1][$o2 + 1] && $s[$rec][$S[$rec][$t] - $n0[$rec] + 1] < $s[$rec][$o2/3 + $n0[$rec]];
	}
}

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
			$S[$rec - 1][$j] = $o1;
			$t ++;
			$j ++;
			
			if ($t == $n[$rec])
			{				
				while ($p < $n0[$rec])
				{
					$S[$rec - 1][$j] = $S0[$p];
					$p ++;
					$j ++;
				}
			}
			else
			{
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
				while ($t < $n[$rec])
				{
					$S[$rec - 1][$j] = ($S[$rec][$t] < $n0[$rec]) ? ($S[$rec][$t] * 3 + 1) : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
					$t ++;
					$j ++;
				}
			}
			else
			{
				$o2 = $S0[$p];
			}
		}
	}
}

sub suffixArray
{
	push @n0, int (($n[$rec - 1] + 2) / 3);
	push @n1, int (($n[$rec - 1] + 1) / 3);
	push @n, $n0[$rec] + int($n[$rec - 1] / 3);

	
	&get12Pos();

	&radixSort();
	
	
	if (&nameTriplets())
	{		
		push @{$s[$rec]}, 0, 0, 0;
		push @K, $name;
		$rec ++;		
		&suffixArray();
		$rec --;
		pop @K;
		for $i (0..$n[$rec] - 1)
		{
			$s[$rec][$S[$rec][$i]] = $i + 1;
		}
	}
	else
	{
		for $i (0..$n[$rec] - 1)
		{
			$S[$rec][$s[$rec][$i] - 1] = $i;
		}
	}
	&sortN0();	
	&merge();
}

sub printToFile
{
	print OUTFILE $stringName;
	for $j (@{$S[0]})
	{
		print OUTFILE $j, " ";
	}
	print OUTFILE "\n";
}

sub fastaCall
{
	$string = uc $string;
	
	@s = ();
	@n0 = ();
	@n1 = ();
	@n = ();
	@S = ();
	@K = ();
	
	push @s, [unpack("C*", $string)];
	push @n0, 0;
	push @n1, 0;
	push @n, $#{$s[0]} + 1;
	
	$max = 0;
	$count = 0;
	for $i (@{$s[0]})
	{
		$count ++;
		if (!($i >= 65 && $i <= 90 || $i == 55 || $i == 45))
		{
			die "Error: incorrect fasta - only alpha characters, a dash and a star allowed\n";
		}				
		if ($i > $max)
		{
			$max = $i;
		}
	}
	
	push @K, $max;
	push @{$s[0]}, 0, 0, 0;
	push @S, [(1)];
	$rec = 1;

	&suffixArray();	
	&printToFile();
}

sub doFasta
{
	$string = "";
	$stringName = $firstLine;
	while (<INFILE>) 
	{
		if (substr($_, 0, 1) eq ">")
		{
			&fastaCall();
			$stringName = $_;
			$string = <INFILE>;
		}
		else
		{
			chomp ($string .= $_);
		}
	} 
	continue 
	{
        close INFILE if eof;
    }
	&fastaCall();
}

sub doRegular
{
	
	$string = $firstLine;
	chomp $string;
	while (<INFILE>) 
	{
		$string .= $_;
		chomp $string;
	} 
	continue 
	{
        close INFILE if eof;
    }
	
	push @s, [unpack("C*", $string)];
	
	$nPrev = $#{$s[0]} + 1;
	push @n, $nPrev;
	push @n0, 0;
	push @n1, 0;
	$max = 0;
	for $i (@{$s[0]})
	{
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

if ($#ARGV != 1)
{
	die "Error: input and output file required\n";
}
open INFILE, "<", $ARGV[0];
open OUTFILE, ">", $ARGV[1];
$firstLine = <INFILE>;

if ( substr($firstLine, 0, 1) eq ">")
{
	&doFasta();
}
else
{
	&doRegular();
}

close OUTFILE;