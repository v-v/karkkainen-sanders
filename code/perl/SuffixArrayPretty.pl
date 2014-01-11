sub get12Pos
{
	for $i (0..($n[$rec - 1] + ($n0[$rec] - $n1[$rec]) - 1))
	{
		if ($i%3 != 0)
		{
			push @{$S[$rec]}, $i;
		}
	}	
	push @{$S[$rec]}, 0, 0, 0;
}

sub radixSort
{
	for $offset (0..2)
	{
		for $i (0..$K[$rec - 1])
		{
			$c[$i] = 0;
		}

		for $i (0..$n[$rec] - 1)
		{
			$c[$s[$rec - 1][$S[$rec][$i] + (2 - $offset)]] ++;
		}

		$start = 0;
		for $i (0..$K[$rec - 1])
		{
			$temp = $c[$i];
			$c[$i] = $start;
			$start += $temp;
		}            
		for $i (0..($n[$rec] - 1))
		{
			$s[$rec][$c[$s[$rec - 1][$S[$rec][$i] + (2 - $offset)]]] = $S[$rec][$i];
			$c[$s[$rec - 1][$S[$rec][$i] + (2 - $offset)]] ++;
		}
		$S[$rec] = [@{$s[$rec]}];
	}
	
}

sub nameTriplets
{
	$name = 0;
	$c0 = -1;
	$c1 = -1;
	$c2 = -1;

	for $i (0..($n[$rec] - 1))
	{
		if ($s[$rec - 1][$S[$rec][$i]] != $c0 || $s[$rec - 1][$S[$rec][$i] + 1] != $c1 || $s[$rec - 1][$S[$rec][$i] + 2] != $c2)
		{
			$name ++;
			$c0 = $s[$rec - 1][$S[$rec][$i]];
			$c1 = $s[$rec - 1][$S[$rec][$i] + 1];
			$c2 = $s[$rec - 1][$S[$rec][$i] + 2];
		}
		
		if ($S[$rec][$i] % 3 == 1)
		{
			$s[$rec][($S[$rec][$i] - 1)/3] = $name;
		}
		else
		{
			$s[$rec][($S[$rec][$i]- 2)/3 + $n0[$rec]] = $name;
		}
	}
	$name < $n[$rec];
}

sub sortN0
{  
    @s0 = ();
	for $i (0..($n[$rec] - 1))
	{
		if ($S[$rec][$i] < $n0[$rec])
		{
			push @s0, 3 * $S[$rec][$i];
		}
	}
	@c = ();
	for $i (0..$K[$rec - 1])
	{
		push @c, 0;
	}
	
	for $i (0..$n0[$rec] - 1)
	{
		$c[$s[$rec - 1][$s0[$i]]] ++; 
	}
	
	$start = 0;
	for $i (0..$K[$rec - 1])
	{
		$temp = $c[$i];
		$c[$i] = $start;
		$start += $temp;
	}
	
	for $i (0..$n0[$rec] - 1)
	{
		$S0[$c[$s[$rec - 1][$s0[$i]]]] = $s0[$i];
		$c[$s[$rec - 1][$s0[$i]]] ++;	
	}
}

sub compare
{
	if ($S[$rec][$t] < $n0[$rec])
	{
		$s[$rec - 1][$o1]  < $s[$rec - 1][$o2] ||
			$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec][$S[$rec][$t] + $n0[$rec]] < $s[$rec][$S[$rec][$o2 / 3] ];
	}
	else
	{
		$s[$rec - 1][$o1] < $s[$rec - 1][$o2] || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] < $s[$rec - 1][$o2 + 1] || 
		$s[$rec - 1][$o1] == $s[$rec - 1][$o2] && $s[$rec - 1][$o1 + 1] == $s[$rec - 1][$o2 + 1] && $s[$rec][$S[$rec][$t - $n0[$rec] + 1]] < $s[$rec][$o2/3 + $n0[$rec]];
	}
}

sub merge
{
	$p = 0;
	$t = $n0[$rec] - $n1[$rec];

	$j = 0;
	$o1 = $S[$rec][$t] < $n0[$rec] ? $S[$rec][$t] * 3 + 1 : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
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
				$o1 = $S[$rec][$t] < $n0[$rec] ? $S[$rec][$t] * 3 + 1 : (($S[$rec][$t] - $n0[$rec]) * 3 + 2);
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
					$S[$rec - 1][$j] = $S[$rec][$t] < $n0[$rec] ? $S[$rec][$t] * 3 + 1 : ($S[$rec][$t] - $n0[$rec]) * 3 + 2;
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
	$n0[$rec] = int (($n[$rec - 1] + 2) / 3);
	$n1[$rec] = int (($n[$rec - 1] + 1) / 3);
	$n[$rec] = $n0[$rec] + int($n[$rec - 1] / 3);

	
	&get12Pos();
	
	&radixSort();
	
	
	if (&nameTriplets())
	{
		$K[$rec] = $name;
		$rec ++;		
		&suffixArray();
		$rec --;
	}
	else
	{
		for $i (0..($n[$rec] - 1))
		{
			$S[$rec][$s[$rec][$i] - 1] = $i;
		}
	}
	
	&sortN0();
	&merge();
	
	$s0 = [];
	$s[$rec] = [];
	$S[$rec] = [];
}

sub printToFile
{
	print OUTFILE $stringName;
	for $j (0..$n[0] - 1)
	{
		print OUTFILE $S[0][$j], " ";
	}
	print OUTFILE "\n";
}

sub doFasta
{
	$string = "";
	$stringName = $firstLine;
	while (<INFILE>) 
	{
		if (substr($_, 0, 1) eq ">")
		{
			$string = uc $string;
			@s[0] = [split //, $string];
			$n[0] = $#{$s[0]} + 1;
	
			$max = 0;
			for $i (0..$#{$s[0]})
			{
				$s[0][$i] = ord($s[0][$i]);
				if (!($s[0][$i] >= 65 && $s[0][$i] <= 90 || $s[0][$i] == 55 || $s[0][$i] == 42))
				{
					die "Error: incorrect fasta";
				}				
				if ($s[0][$i] > $max)
				{
					$max = $s[0][$i];
				}
			}
			$K[0] = $max;
			push @{$s[0]}, 0, 0, 0;
			$S = [];
			$rec = 1;

			&suffixArray();
			
			&printToFile();
			
			$stringName = $_;
			$string = "";
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
	
	$string = uc $string;
	@s[0] = [split //, $string];
	$n[0] = $#{$s[0]} + 1;

	$max = 0;
	for $i (0..$#{$s[0]})
	{
		$s[0][$i] = ord($s[0][$i]);
		if (!($s[0][$i] >= 65 && $s[0][$i] <= 90 || $s[0][$i] == 55 || $s[0][$i] == 42))
		{
			die "Error: incorrect fasta";
		}				
		if ($s[0][$i] > $max)
		{
			$max = $s[0][$i];
		}
	}
	$K[0] = $max;
	push @{$s[0]}, 0, 0, 0;
	$S = [];
	$rec = 1;

	&suffixArray();
	
	&printToFile();
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
	
	push @s, [split //, $string];
	
	$n[0] = $#{$s[0]} + 1;
	
	$max = 0;
	for $i (0..$#{$s[0]})
	{
		$s[0][$i] = ord($s[0][$i]);
		if (!($s[0][$i] >= 32 && $s[0][$i] <= 126))
		{
			die "Error: incorrect regular";
		}			
		if ($s[0][$i] > $max)
		{
			$max = $s[0][$i];
		}
	}

	$K[0] = $max;
	push @{$s[0]}, 0, 0, 0;
	$S = [];
	$rec = 1;
	
	&suffixArray();
	&printToFile();
	
	$name = $_;
	$string = "";
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
