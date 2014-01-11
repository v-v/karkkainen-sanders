% function to determine the order
function res = leq1(a1, a2, b1, b2)
	res =  ((a1 < b1) || ((a1 == b1) && (a2 <= b2)));
