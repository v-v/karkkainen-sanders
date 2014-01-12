using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
namespace Bioinflabos
{
	public class MainClass
	{
		//function is finding suffix array SA of s[0..n-1] in {1..K}^n
		//require s[n]=s[n+1]=s[n+2]=0, n>=2
		static public void suffixArray(int[] s, int[] SA, int n, int K, int start)
		{
			
			//converting int n to double n
			double nDouble = (double) n;
			
			//number of triplets on start position i = 0 (mod 3)
			int n0 =(int) Math.Ceiling(nDouble/3);
			
			//number of triplets on start position i = 1 (mod 3)
			int n1 =(int) Math.Ceiling((nDouble-1)/3);
			
			//number of triplets on start position i = 2 (mod 3)
			int n2 =(int) Math.Ceiling((nDouble-2)/3);
			
			//number of triplets in T'
			int n02 = n0+n2;
			
			//array for positions i != 0 (mod 3)
			int[] s12 = new int[n02+3];
			
			//put $ (0) on last three places
			s12[n02] = s12[n02+1] = s12[n02+2] = 0;
			
			//finding positions i != 0 (mod 3)
			if ((n0 - n1) == 0)
			{
				int position = 0;
				for (int i = 0; i < n; i++)
				{
					if ((i % 3) != 0)
					{
						s12[position] = i;
						position++;
					}
				}
			}
			else if ( (n0-n1) == 1)			//if (n0-n1) == 1 -> add triplet $$$ on the end of t1
			{
				int position = 0;
				for (int i = 0; i < n + 1; i++)
				{
					if ((i % 3) != 0)
					{
						s12[position] = i;
						position++;
					}
				}
			}
			
			//temporary array for radix sort
			int[] sorted = new int[n02+3];
			sorted[n02] = sorted[n02+1] = sorted[n02+2] = 0;
			
			//radix sort of triplets by last, second and first character
			sorted = radix(s12, s, 2, n02, K, start);
			sorted = radix (sorted, s, 1, n02, K, start);
			sorted = radix (sorted, s, 0, n02, K, start);
			
			//assign lexicographic names
			int name = 0;
			int c0 = -1;
			int c1 = -1;
			int c2 = -1;
			for (int i = 0; i < n02; i++)
			{
				if ((s[start + sorted[i]] != c0) || (s[start + sorted[i] + 1] != c1) || (s[start + sorted[i] + 2] != c2))
				{
					name++;
					c0 = s[start + sorted[i]];
					c1 = s[start + sorted[i] + 1];
					c2 = s[start + sorted[i] + 2];
				}
				if (sorted[i] % 3 == 1) //left part
				{
					s12[sorted[i] / 3 ] = name;		
				}
				else if (sorted[i] % 3 == 2) //right part	
				{
					s12[sorted[i] / 3 + n0] = name;	
				}
			}
			
			//array for suffix array
			int[] SA12 = new int[n02+3];
			SA12 = sorted;
			
			//in s12 now are triplet names

			//check if names are unique
			if (name < n02) //names are not unique
			{
				//recursive call
				suffixArray(s12, SA12, n02, name, start); 
				//put unique names in s12
				for (int i = 0; i < n02; i++)
				{
					s12[SA12[i]] = i + 1;	
				}
			}
			else //names are unique			
			{
				//make suffix array SA12
				for (int i = 0; i < n02; i++) 
				{
					SA12[s12[i] -1 ] = i;
				}
			}
			
			int[] s0 = new int[n0];
			int[] SA0 = new int[n0];
			
			//calculating s0 from SA12 - radix sort the mod 0 suffixes from SA12 by their first character
			int l=0;
			for (int i = 0; i < n02; i++)
			{
				if (SA12[i] < n0)
				{
					s0[l++] = 3 * SA12[i];	
				}
			}
			SA0 = radix(s0, s, 0, n0, K, start);
			
			//make SA from SA0 and SA12
			for (int p = 0, t = n0 - n1, k = 0; k < n; k++)
			{
				int i = (SA12[t] < n0 ? SA12[t] * 3 +1 : (SA12[t] - n0) * 3 +2);
				int j = SA0[p];
				
				// comparing suffixes
				if (SA12[t] < n0 ? leq (s[start + i], s12[SA12[t] + n0], s[start + j],
				    s12[j / 3]) : leq (s[start + i], s[start + i + 1], s12[SA12[t] - n0 + 1],
				    s[start + j], s[start + j + 1], s12[j / 3 + n0]))
				{			
					// suffix from SA12 is smaller
					SA[k] = i;
					t++;
					if (t == n02)					
					{
						for (k++; p < n0; p++, k++)
						{
							SA[k] = SA0[p];	
						}
					}
				}
				else
				{
					// suffix from SA12 is bigger
					SA[k] = j;
					p++;
					if (p == n0)				
					{
						for (k++; t < n02; t++, k++)
						{
							SA[k] = (SA12[t] < n0 ? SA12[t] * 3 +1 : (SA12[t] - n0) * 3 +2);	
						}
					}
				}
			}
		}

		//radix sort a[0..n-1] with keys in 0..K from r
		static public int[] radix(int[] a, int[] r, int rIndex, int n, int K, int start)
		{
			//sorted array
			int[] sorted = new int[a.Length];
			
			//counter array
			int[] count = new int[K+1]; 	
			
			//count frequencies
			for (int i = 0; i < n; i++)				
			{
				count[r[start+rIndex+a[i]]]++;	
			}
			
			//exclusive prefix sums
			int sum = 0;
			for (int i = 0; i < (K + 1); i++)	
			{
				int temp = count[i];
				count[i] = sum;
				sum += temp;
			}
			
			//sort
			for (int i = 0; i < n; i++)				
			{
				sorted[count[r[start+rIndex+a[i]]]++] = a[i];
			}
			
			return sorted;
		}
		
		//lexic order for pairs
		static public bool leq(int a1, int a2, int b1, int b2)
		{
			return (a1 < b1 || (a1 == b1 && a2 <= b2));
		}
		//lexic order for triples
		static public bool leq(int a1, int a2, int a3, int b1, int b2, int b3)
		{
			return (a1 < b1 || (a1 == b1 && leq (a2, a3, b2, b3)));
		}
		//find max value in slice of an array
		static public int max(int[] input, int start, int length)
		{
			int max = input[start];
			for (int i = length - 2, index = start +1; i >= 0; i--, index++)
			{
				int v = input[index];
				if (v > max)
					max = v;
				
			}
			return max;
		}
		
		//function that converts string to integer array, keeping alphabetic order
		public static int[] convertStringToArrayInt(string s, int type)
		{

			int length = s.Length;
			
			int[] returnArray = new int[length+1];
			
			if (type ==1) //if type is FASTA
			{
				//convert characters to upper
				s = s.ToUpper(); 
				
				// put $ char on the end of array
				returnArray[length] = 1;
				
				for (int i = 0; i<length; i++)
				{
					//in FASTA only can be letters from A to Z, char '-' and '*'
					if (!((s[i]>='A' && s[i] <='Z') || s[i] == '-' || s[i]=='*') ){
						throw new Exception("Wrong format!");
					}
					
					//convert chat to int
					returnArray[i] =Convert.ToInt32( s[i]);
				}	
			}
			else //type is plain text		
			{
				// put $ char on the end of array
				returnArray[length] = 1;
				
				for (int i = 0; i < length ; i++)
				{
					//convert chat to int
					returnArray[i] =Convert.ToInt32( s[i]);
				}

			}
			return returnArray;		
		}
		public static void Main (string[] args)
		{
			
			try{
				//path to input document
				string inputDocument = args[0];			
				
				//path to output document
				string outputDocument = args[1];
				
				//all lines from document
				string[] lines = System.IO.File.ReadAllLines(@inputDocument);
				
				int type=0; // 1 za FASTU, 2 za plain
				
				//list for sequences
				List<string> sequences =  new List<string>();
				if (lines[0].Substring(0,1).Equals(";") || lines[0].Substring(0,1).Equals(">")) //FASTA
				{
					type=1;
					string sequence = "";
					bool sequenceBool = false;
					
					for (int i = 0; i < lines.Length; i++) 
					{
						
						if (lines[i].Substring(0,1).Equals(";")) //it is a comment
						{
							if (sequenceBool)
							{
								
								sequences.Add(sequence);
							}
							sequenceBool=false;
						
						}
						else if(lines[i].Substring(0,1).Equals(">")) //it is a sequence
						{
							if (sequenceBool)
							{
								
								sequences.Add(sequence);
							}
							sequence="";
							sequenceBool = true;
						}
						else
						{
							if (sequenceBool)
							{
								sequence = sequence+lines[i];	
							}
						}
						
					}
					if (sequenceBool)
					{
						
						sequences.Add(sequence);
					}
				}
				else //plain text
				{
					type = 2;
					string plainString = "";
					for (int i= 0; i<lines.Length; i++)
					{
						plainString = plainString+lines[i];
						
					}
					sequences.Add(plainString);
				}
				
				//output document
				StreamWriter writer = File.CreateText(@outputDocument);
				
				//for every sequence make suffix array and write it in output document
				for (int i = 0; i < sequences.Count; i++) {
					
					string str =sequences[i];
					
					//convert string to int array
					int[] sIn = convertStringToArrayInt(str, type);
					
					int start = 0;
					int length = sIn.Length;
					
					int[] end = new int[3]{0,0,0};
					int[] SA = new int[length + 3];
					
					int alphabetSize = max (sIn, start, length);
					
					int[] s = new int[length+3];
					
					//put 3 zeros on the end of array
					Array.Copy(sIn, 0, s, 0, length);
					Array.Copy(end, 0, s, length,3);
					
					//find suffix array
					suffixArray(s, SA, length, alphabetSize, start);
					
					int len = SA.Length-3;
					
					//write suffix array in output document
					for (int j = 1; j < len; j++) {
						writer.Write(SA[j]);
						writer.Write(" ");					
					}
					writer.Write("\n");				
			}
				writer.Close();
			}
			catch (Exception e){
				Console.WriteLine(e);	
			}			
		}
	}
}
