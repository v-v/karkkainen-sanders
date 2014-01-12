import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;

/*
 * Linear time suffix array construction
 * 
 * The SuffixArray class reads sequences from input file
 * given as the first argument and writes the calculated
 * suffix array of each sequence in output file given as
 * the second argument.
 * 
 * author: Miranda Krekovic
 */

public class SuffixArray {

	/**
	 * This is the main method for calculating the suffix array.
	 * @param sequence		initial string from which we calculate the suffix array
	 * @param K				maximum number of distinct characters
	 * @return resultSA 	suffix array of string s
	 */
	public static int[] constructSuffixArray (int[] sequence, int K) {
		int n = sequence.length;	
		int n0 = (int) Math.ceil(n / 3.0);
		int n1 = (int) Math.ceil((n - 1) / 3.0);
		int n2 = (int) Math.ceil((n - 2) / 3.0);
		int tripletNumber = n0 + n2;
		
		int[] sequence2 = null;

		sequence2 = appendSpecialChars(sequence, sequence2);

		int[] index = new int[tripletNumber];
		for (int i = 0, j = 0; i < sequence2.length - 2; i++)
			if (i % 3 != 0) index[j++] = i;
		
		// lexicographically sort triplets
		int[] sortedTriplets = new int[index.length];
		sortedTriplets = radixSort (sequence2, index, tripletNumber, K, 2);
		sortedTriplets = radixSort (sequence2, sortedTriplets, tripletNumber, K, 1);
		sortedTriplets = radixSort (sequence2, sortedTriplets, tripletNumber, K, 0);

		// name triplets
		int[] lexName = new int[tripletNumber];
		lexName[0] = 1;
		boolean notUnique = nameTriplets(tripletNumber, sequence2, sortedTriplets, lexName);
			
		// concatenate the triplet names in the right order
		int[] lexNameSorted = new int[tripletNumber];
		lexNameSorted = concatenateTripletNames(n0, tripletNumber, sortedTriplets, lexName);
		
		// construct the suffix array
		int[] SA = new int[tripletNumber];		
		if (notUnique) {
			int maximum = 0;
			for (int i = 0; i < lexNameSorted.length; i++) {
				if (lexNameSorted[i] > maximum)
					maximum = lexNameSorted[i];
			}
			SA = constructSuffixArray(lexNameSorted, maximum);			
		}
		else {
			for (int i = 0; i < tripletNumber; i++) {
				SA[lexNameSorted[i] - 1] = i;
			}
		}
		
		// transform SA to A12
		int[] A12 = new int[tripletNumber];
		transformToA12(n0, tripletNumber, SA, A12);
		
		// derive A0 from A12
		int[] A0 = new int[n0];
		deriveA0(tripletNumber, A12, A0);				
		A0 = radixSort (sequence2, A0, n0, K, 0);
		
		// merge A12 and A0 into suffix array rezSA
		int[] resultSA = new int[n0 + tripletNumber - (n0 - n1)];
		merge(n, tripletNumber, sequence2, A12, A0, resultSA);
		
		return resultSA;
	}

	/**
	 * This is a radix sort.
	 * @param s2			initial string s with appended special characters
	 * @param index			ordered indexes of triplets
	 * @param tripletNumber	number of triplets in string s		
	 * @param K				the maximum number of distinct characters
	 * @param offset		offset from index (the position of character in
	 * 						triplet which is being sorted)
	 * @return result		sorted indexes
	 */
	public static int[] radixSort(int[] s2, int[] index, int tripletNumber, int K, int offset) {
		int[] c = new int[K+1];
		System.out.println();
		int[] result = new int[tripletNumber];
		for (int i = 0; i < tripletNumber; i++) 
	      c[s2[index[i] + offset]]++;  
	    for (int i = 1; i <= K; i++)
	      c[i] += c[i - 1];
	    for (int i = tripletNumber - 1; i >= 0; i--)
	      result[--c[s2[index[i] + offset]]] = index[i];
	    return result;
	}
	
	/**
	 * This method assigns the lexicographical names to the sorted triplets
	 * and checks if the triplets are unique.
	 * @param tripletNumber		number of triplets in string s
	 * @param s2				initial string s with appended characters
	 * @param sortedTriplets	indexes of sorted triplets		
	 * @param lexName			lexicographical names of the triplets
	 * @return notUnique		true if triplets are not unique
	 * 							false if triplets are unique
	 */
	public static boolean nameTriplets(int tripletNumber, int[] s2, int[] sortedTriplets, int[] lexName) {
		int name = 1;
		boolean notUnique = false;
		for (int i = 1; i < tripletNumber; i++) {		
			if ((s2[sortedTriplets[i]] == s2[sortedTriplets[i-1]]) && (s2[sortedTriplets[i]+1] == s2[sortedTriplets[i-1]+1]) && (s2[sortedTriplets[i]+2] == s2[sortedTriplets[i-1]+2])) 
				notUnique = true;
			else
				name++;
			lexName[i] = name;
		}
		return notUnique;
	}
	
	/**
	 * This method puts lexicographical names in the correct order.
	 * @param n0				number of triplets in string s which start
	 * 							on indexes i=3*k+1	
	 * @param tripletNumber		number of triplets in string s
	 * @param sortedTriplets	indexes of sorted triplets
	 * @param lexName			lexicographical names of the triplets
	 * @return lexNameSorted	array of concatenated triplet names
	 */
	public static int[] concatenateTripletNames(int n0, int tripletNumber, int[] sortedTriplets, int[] lexName) {
		int[] lexNameSorted = new int[tripletNumber];
		for (int i = 0; i < tripletNumber; i++) {
			if (sortedTriplets[i] % 3 == 1) {
				lexNameSorted[(sortedTriplets[i]-1)/3] = lexName[i];
			}
			if (sortedTriplets[i] % 3 == 2) {
				lexNameSorted[(sortedTriplets[i]-2)/3 + n0] = lexName[i];
			}
		}
		return lexNameSorted;
	}
	
	/**
	 * This methods calculates the suffix array A12 from suffix array SA.
	 * @param n0				number of triplets in string s which start
	 * 							on indexes i=3*k+1						
	 * @param tripletNumber		number of triplets in string s
	 * @param SA				suffix array SA of auxiliary string lexNameSorted
	 * @param A12				suffix array A12
	 */
	public static void transformToA12(int n0, int tripletNumber, int[] SA, int[] A12) {
		for (int i = 0; i < tripletNumber; i++) {
			if (SA[i] < n0)
				A12[i] = 1 + 3 * SA[i];
			else 
				A12[i] = 2 + 3 * (SA[i] - n0);
		}
	}
	/**
	 * This methods calculates the suffix array A0 from the array A12. 
	 * @param tripletNumber		number of triplets in string s
	 * @param A12				suffix array A12
	 * @param A0				suffix array A0
	 */
	public static void deriveA0(int tripletNumber, int[] A12, int[] A0) {
		for (int i = 0, j = 0; i < tripletNumber; i++)
			if (A12[i] % 3 == 1) {
				A0[j++] = A12[i] - 1;
			}
	}

	/**
	 * This methods appends special characters in the end of string s.
	 * @param s		initial string s
	 * @param s2	initial string s with appended characters
	 * @return s2
	 */
	public static int[] appendSpecialChars(int[] s, int[] s2) {
		int n = s.length;
		if (n % 3 == 0 || n % 3 == 2) {
			s2 = new int[n + 2];
			s2[n] = s2[n + 1] = 0;
		}
		if (n % 3 == 1) {
			s2 = new int[n + 3];
			s2[n] = s2[n + 1] = s2[n + 2] = 0;
		}
		for (int i = 0; i < n; i++) 
			s2[i] = s[i];
		return s2;
	}

	/**
	 * This method merges A12 and A0 into suffix array A.
	 * @param n					length of the initial string s
	 * @param tripletNumber		number of triplets in string s
	 * @param s2				initial string s with appended characters
	 * @param A12				suffix array A12
	 * @param A0				suffix array A0
	 * @param resultSA			total suffix array of initial string s
	 */
	public static void merge(int n, int tripletNumber, int[] s2, int[] A12, int[] A0, int[] resultSA) {	
		int[] R12 = new int[s2.length];
		int n0 = (int) Math.ceil(n / 3.0);
		
		int index0 = 0;
		int index12 = 0;
		int m = 0;
		if (n % 3 == 1)
			index12 = 1;
		boolean end = false;
		
		for (int i = 0; i < tripletNumber; i++)
			R12[A12[i]] = i + 1;
		
		for (int i = 0; i < tripletNumber + n0; i++) {
			if (index0 == n0) {
				while (index12 < tripletNumber) {
					resultSA[m++] = A12[index12];
					index12++;
				}			
				end = true;
			}
			if (end) break;

			if (index12 == tripletNumber) {
				while (index0 < n0) {
					resultSA[m++] = A0[index0];
					index0++;
				}
				end = true;
			}
			if (end) break;
			
			if (A12[index12] % 3 == 1) {
				if (compare2(s2[A0[index0]], s2[A12[index12]], R12[A0[index0] + 1], R12[A12[index12] + 1])) {
					resultSA[m++] = A0[index0]; 
					index0++;
				}
				else {
					resultSA[m++] = A12[index12]; 
					index12++;				
				}
			}
			else {
				if (compare3(s2[A0[index0]], s2[A12[index12]], s2[A0[index0] + 1], s2[A12[index12] + 1], R12[A0[index0] + 2], R12[A12[index12] + 2])) {						
					resultSA[m++] = A0[index0]; 
					index0++;
				}
				else {
					resultSA[m++] = A12[index12]; 
					index12++;				
				}				
			}	
		}
	}
	
	/**
	 * This method compares if the triple (i, k, m) is smaller than the triple (j, l, n).
	 * @param i		number for comparison with j
	 * @param j		number for comparison with i
	 * @param k		number for comparison with l
	 * @param l		number for comparison with k
	 * @param m		number for comparison with n
	 * @param n		number for comparison with m
	 * @return 		true if (i, k, m) is equal or smaller than (j, l, n)
	 * 				false if (i, k, m) is greater than (j, l, n)
	 */
	public static boolean compare3(int i, int j, int k, int l, int m, int n) {
		return compare2(i, j, k, l) || (i == j && k == l && m < n);
	}

	/**
	 * This method compares if the pair (i, k) is smaller than the pair (j, l).
	 * @param i		number for comparison with j
	 * @param j		number for comparison with i
	 * @param k		number for comparison with l
	 * @param l		number for comparison with k
	 * @return		true if (i, k) is equal or smaller than (j, l)
	 * 				false if (i, k) is grater than (j, l) 
	 */
	public static boolean compare2(int i, int j, int k, int l) {
		return (i < j || i == j && k < l);
	}

	/**
	 * This is the main method. It reads sequences from input file
	 * given as the first argument, calls the method constructSuffixArray
	 * for each sequence and writes the calculated suffix arrays 
	 * in output file given as the second argument.
	 * 
	 * @param args 	args[0] input file containing sequences (plain text or FASTA format)
	 * 				args[1] result file containing suffix arrays
	 **/
	@SuppressWarnings("resource")
	public static void main (String[] args) {
		
		// check the number of arguments
		if (args.length != 2) {
			System.out.println("The number of arguments should be two - the first argument represends the input file and the second arugment represends the output file.");
			return;
		}
		
		// read data from the file 
		int sequenceNumber = 0;	
		BufferedReader reader = null;
		String sequence[] = null;
		boolean fasta = false;
		try {
			reader = new BufferedReader(new FileReader(args[0]));
			StringBuilder stringBuilder = new StringBuilder();
			String line = reader.readLine();

			if (line.charAt(0) == '>')
				fasta = true;
			
			// count the number of sequences
			while (line != null) {
				if (fasta == true && line.charAt(0) == '>') sequenceNumber++;
				line = reader.readLine();	
			}
			
			if (sequenceNumber == 0)
				sequenceNumber = 1;
			sequence = new String[sequenceNumber];
			
			// read all sequences
			boolean firstLine = true;
			sequenceNumber = 0;
			reader = new BufferedReader(new FileReader(args[0]));
			line = reader.readLine();

			if (fasta == true) {
				while (line != null) {
					if (line.charAt(0) == '>' && firstLine == false) {
						sequence[sequenceNumber] = stringBuilder.toString();
						stringBuilder = new StringBuilder();
						sequenceNumber++;
					} else if (line.charAt(0) != '>'){
						stringBuilder.append(line);
					}
					line = reader.readLine();
					firstLine = false;
				}

			} else {
				while (line != null) {
					stringBuilder.append(line);
					line = reader.readLine();	
				}									
			}
			sequence[sequenceNumber] = stringBuilder.toString();
			reader.close();	

		} catch (FileNotFoundException e) {
			System.out.println("The input file doesn't exist.");
			return;
		} catch (Exception e)  {
			e.printStackTrace();
		}
		
		// calculate the suffix array of each sequence and write it to the file 
		try {
			BufferedWriter writer = new BufferedWriter(new FileWriter(args[1]));	
			for (int i = 0; i < sequence.length; i++) {
				String seq = sequence[i];
				if (fasta == true) {
					seq = seq.toUpperCase();
					// check if all characters in FASTA format are allowed
					for (int j = 0; j < seq.length(); j++) {
						if (!((seq.charAt(j) >= 'A' && seq.charAt(j) <= 'Z') || (seq.charAt(j) >= '0' && seq.charAt(j) <= '9') || seq.charAt(j) == '-' || seq.charAt(j) == '*')) {
							System.out.println("Not correct FASTA format.");
							return;
						}						
					}					
					// remove digits					
					seq = seq.replaceAll("[0-9]", "");					
				}

				char[] chars = seq.toCharArray();
				int[] s = new int[chars.length];
				int minimum = 256;
				for (int j = 0; j< chars.length; j++) {
					s[j] = chars[j] + 1;
					if (s[j] < minimum) 
						minimum = s[j];
				}
				int maximum = 0;
				for (int j = 0; j< chars.length; j++) {
					s[j] = chars[j] + 2 - minimum;		
					if (s[j] > maximum)
						maximum = s[j];
				}
				
				// calculate suffix array
				int[] suffixArray = new int[chars.length];
				suffixArray = constructSuffixArray(s, maximum);	
				
				// write  suffix array to output file
				for (int j = 0; j < suffixArray.length; j++)
					writer.write(suffixArray[j] + " ");	
				writer.write("\n");
			}
			writer.close();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}	
}

