% performs one radix sort pass
% sorts indices from src in dst by
% using the values from v of length n
% of an integer alphabet from 0 to K
function dst = radixPass(src, dst, v, n, K)

	% temporary array for counting occurrences
	% of characters - a so called "counting sort"
	% variant of radis sort
	c = zeros([1, K+1]);

	% adding occurrences
	for i = 1:n
		c(v(src(i)+1)+1) += 1;
	end
	
	% sum of prefixes
	s = 0;
	for i = 0:K
		t = c(1+i);
		c(1+i) = s; 
		s += t;
	end

	% sorting the indices
	for i = 1:n
		dst(c(v(src(i)+1)+1)+1) = src(i);
		c(v(src(i)+1)+1) += 1;
	end
