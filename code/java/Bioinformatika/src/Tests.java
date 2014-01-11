import static org.junit.Assert.*;
import org.junit.*;

public class Tests {
	@Test
	public void testCompare2() {
		assertTrue(SuffixArray.compare2(1, 2, 3, 4));
		assertTrue(SuffixArray.compare2(1, 1, 2, 3));
		assertFalse(SuffixArray.compare2(2, 1, 2, 3));
		assertFalse(SuffixArray.compare2(1, 1, 3, 2));		
	}
	
	@Test
	public void testCompare3() {
		assertTrue(SuffixArray.compare3(1, 2, 2, 3, 4, 5));
		assertTrue(SuffixArray.compare3(1, 1, 2, 3, 1, 2));
		assertTrue(SuffixArray.compare3(1, 1, 2, 2, 3, 4));
		assertFalse(SuffixArray.compare3(2, 1, 2, 3, 4, 5));
		assertFalse(SuffixArray.compare3(1, 1, 3, 2, 1, 2));
		assertFalse(SuffixArray.compare3(1, 1, 2, 2, 4, 3));
	}	
	
	@Test
	public void testRadixSort() {
		int[] s2 = {5, 3, 1, 2, 6, 4, 0, 0};
		int[] index = {1, 2, 4, 5};
		int n = 4;
		int K = 10;
		int offset = 0;
		int[] expectedResult1 = {2, 1, 5, 4};
		int[] actualResult = SuffixArray.radixSort(s2, index, n, K, offset);
		assertArrayEquals("Radix sort 1", expectedResult1, actualResult);
		
		offset = 1;
		int[] expectedResult2 = {5, 1, 2, 4};
		actualResult = SuffixArray.radixSort(s2, index, n, K, offset);
		assertArrayEquals("Radix sort 2", expectedResult2, actualResult);

		offset = 2;
		int[] expectedResult3 = {4, 5, 1, 2};
		actualResult = SuffixArray.radixSort(s2, index, n, K, offset);
		assertArrayEquals("Radix sort 3", expectedResult3, actualResult);		
	}
	
	@Test
	public void testConcatenateTripletNames() {
		int n0 = 2;
		int tripletNumber = 4;
		int[] rez = {2, 1, 5, 4};
		int[] lexName = {1, 2, 3, 4};
		int[] expectedResult = {2, 4, 1, 3};
		int[] actualResult = SuffixArray.concatenateTripletNames(n0, tripletNumber, rez, lexName);
		assertArrayEquals(expectedResult, actualResult);		
	}
	
	@Test
	public void testNameTriplets() {
		int[] s2 = {5, 3, 1, 2, 6, 4, 0, 0};
		int tripletNumber = 4;
		int[] rez = {2, 1, 5, 4};
		int[] lexName = new int[tripletNumber];
		lexName[0] = 1;
		int[] lexNameExpected = {1, 2, 3, 4};
		assertFalse("It is unique", SuffixArray.nameTriplets(tripletNumber, s2, rez, lexName));
		assertArrayEquals(lexNameExpected, lexName);
		
		int[] s22 = {3, 5, 5, 5, 5, 0, 0};
		tripletNumber = 3;
		int[] rez2 = {4, 1, 2};
		lexName = new int[tripletNumber];
		lexName[0] = 1;
		int[] lexNameExpected2 = {1, 2, 2};
		assertTrue("It is not unique", SuffixArray.nameTriplets(tripletNumber, s22, rez2, lexName));
		assertArrayEquals(lexNameExpected2, lexName);
	}
	
	@Test
	public void testAppendSpecialChars() {
		int[] rez = null;
		int[] s1 = {5, 3, 1};
		int[] actualResult1 = SuffixArray.appendSpecialChars(s1, rez);
		int[] expectedResult1 = {5, 3, 1, 0, 0};
		assertArrayEquals(expectedResult1, actualResult1);

		int[] s2 = {5, 3, 1, 2};
		int[] actualResult2 = SuffixArray.appendSpecialChars(s2, rez);
		int[] expectedResult2 = {5, 3, 1, 2, 0, 0, 0};
		assertArrayEquals(expectedResult2, actualResult2);

		int[] s3 = {5, 3, 1, 2, 4};
		int[] actualResult3 = SuffixArray.appendSpecialChars(s3, rez);
		int[] expectedResult3 = {5, 3, 1, 2, 4, 0, 0};
		assertArrayEquals(expectedResult3, actualResult3);
	}
	
	@Test
	public void testTransformToA12() {
		int[] SA = {2, 3, 0, 4, 1};
		int n0 = 3;
		int tripletNumber = 5;
		int[] A12 = new int[tripletNumber];
		int[] expectedResult = {7, 2, 1, 5, 4};
		SuffixArray.transformToA12(n0, tripletNumber, SA, A12);
		assertArrayEquals(expectedResult, A12);
	}
	
	@Test
	public void testDeriveA0() {
		int tripletNumber = 5;
		int[] A12 = {7, 2, 1, 5, 4};
		int[] A0 = new int[3];
		int[] expectedResult = {6, 0, 3};
		SuffixArray.deriveA0(tripletNumber, A12, A0);
		assertArrayEquals(expectedResult, A0);
	}
	
	@Test
	public void testMerge() {
		int[] s2 = {3, 3, 2, 1, 5, 5, 4, 0, 0, 0};
		int n = 7;
		int n0 = 3;
		int n1 = 2;
		int tripletNumber = 5;
		int[] A12 = {7, 2, 1, 5, 4};
		int[] A0 = {3, 0, 6};
		int[] rezSA = new int[n0 + tripletNumber - (n0 - n1)];
		int[] expectedResult = {3, 2, 1, 0, 6, 5, 4};	
		SuffixArray.merge(n, tripletNumber, s2, A12, A0, rezSA);
		assertArrayEquals(expectedResult, rezSA);
		
		String a = "MISSISSIPPI";
		char[] chars = a.toCharArray();
		int[] s2_2 = new int[chars.length + 2];
		for (int i = 0; i< chars.length; i++) {
			s2_2[i] = chars[i] - '0' + 1;
		}	
		s2_2[chars.length] = s2_2[chars.length + 1] = 0;
		n = 11;
		n0 = 4;
		n1 = 4;
		tripletNumber = 7;
		int[] A12_2 = {10, 7, 4, 1, 8, 5, 2};
		int[] A0_2 = {0, 9, 6, 3};
		int[] rezSA_2 = new int[n0 + tripletNumber - (n0 - n1)];
		int[] expectedResult_2 = {10, 7, 4, 1, 0, 9, 8, 6, 3, 5, 2};	
		SuffixArray.merge(n, tripletNumber, s2_2, A12_2, A0_2, rezSA_2);
		assertArrayEquals(expectedResult_2, rezSA_2);		
	}
	
	@Test
	public void testConstructSuffixArray() {
		int[] s = {5, 3, 1, 2, 6, 4};
		int K = 100;
		int[] actualResult = SuffixArray.constructSuffixArray(s, K);
		int[] expectedResult = {2, 3, 1, 5, 0, 4};
		assertArrayEquals(expectedResult, actualResult);		
	}
}
