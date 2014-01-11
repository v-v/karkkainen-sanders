% generira suffix array od s koji je duljine n
% i integer abecede 0..K

% funkcija se po potrebi poziva rekurzivno

% generates the suffix array of s which is of length n
% and based on an integer alphabet 0..K

% if needed, this function is called recursively

function SA = suffixArray(s, n, K)
	
	% initialize the pointers to the 3 segments
	n0 = floor((n+2)/3);
	n1 = floor((n+1)/3);
	n2 = floor(n/3);
	n02 = n0 + n2; 

	s12 = zeros([1, n02 + 3]);
	SA12 = zeros([1, n02 + 3]);
	s0 = zeros([1, n0]);
	SA0 = zeros([1, n0]);

	% generate positions of % 3 == 1 and % 3 == 2 suffixes
	j = 0; 
	for i = 0:(n+(n0-n1)-1) % if n % 3 == 1 -> additional % 1
		if (mod(i,3) ~= 0)
			s12(1+j) = i;
			j += 1;
		end
	end
	
	% three radix sort passes - sorting groups 1 and 2
	% by their third, second and first character
	SA12 = radixPass(s12 , SA12, s(3:end), n02, K);
	s12  = radixPass(SA12, s12,  s(2:end), n02, K);  
	SA12 = radixPass(s12 , SA12, s(1:end), n02, K);

	% labeling triplets inside a group
	name = 0;
	c0 = c1 = c2 = -1;

	for i = 0:(n02-1)
		if (s(1+SA12(1+i)) != c0 || s(1+SA12(1+i)+1) ~= c1 || s(1+SA12(1+i)+2) != c2) 
			name += 1;
			c0 = s(1+SA12(1+i));
			c1 = s(1+SA12(1+i)+1);
			c2 = s(1+SA12(1+i)+2);
		end 

		if (mod(SA12(1+i),3) == 1)
			s12(1+floor(SA12(1+i)/3)) = name; % left part
		else
			s12(1+floor(SA12(1+i)/3) + n0) = name; % right part
		end
	end % for


	% if we have duplicats then we have to recursively compute the SA of
	% the given array - if there are no duplicates, we're done
	if (name < n02) 
		SA12 = suffixArray(s12, n02, name);

		% saving the received uniqued values to s12
		for i = 0:(n02-1)
			s12(1+SA12(1+i)) = i + 1;
		end
	else
		% there were no duplicats -> groups 1 & 2 are finished
		for i = 0:(n02-1)
			SA12(1+s12(1+i) - 1) = i; 
		end

	end
	
	% using SA12 to sort the first group (% 3 == 0)
	j = 0;
	for i = 0:(n02-1)
		if (SA12(1+i) < n0)
			s0(1+j) = 3*SA12(1+i);
			j += 1;
		end
	end
	SA0 = radixPass(s0, SA0, s, n0, K);

	% merging the suffices of the three groups
	p = 0;
	t = n0 - n1;

	for k = 0:(n-1)
		if t == n02 
			break
		end

		% offset of the group 12 suffix
		if (SA12(1+t) < n0)
			i = SA12(1+t) * 3 + 1;
		else
			i = (SA12(1+t) - n0) * 3 + 2;
		end

		j = SA0(1+p); % group zero suffix offset

		% comparing the triplets
		if ( ((SA12(1+t) <  n0) && leq1(s(1+i), s12(1+SA12(1+t) + n0), s(1+j), s12(1+floor(j/3)))) ||
		     ((SA12(1+t) >= n0) && leq2(s(1+i),s(1+i+1),s12(1+SA12(1+t)-n0+1), s(1+j),s(1+j+1),s12(1+j/3+n0)) ) )

			SA(1+k) = i;
			t += 1;
			if (t == n02)
				k += 1;
				while(p < n0)
					SA(1+k) = SA0(1+p);
					p += 1;
					k += 1;
				end
	      		end
		else
			SA(1+k) = j; 
			p += 1; 

			if (p == n0) 
				k += 1;
				while(t < n02)
					if (SA12(1+t) < n0)
						SA(1+k) = SA12(1+t) * 3 + 1;
					else
						SA(1+k) = (SA12(1+t) - n0) * 3 + 2;
					end
					t += 1;
					k += 1;
				end
			end
	    	end % else

	end % for
