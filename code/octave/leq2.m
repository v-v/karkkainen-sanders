 % function to determine the order of triplets
function res = leq2(a1, a2, a3, b1, b2, b3)
	res =  ((a1 < b1) || ((a1 == b1) && leq1(a2, a3, b2, b3)));
