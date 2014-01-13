# -*- coding: cp1250 -*-
#Suffix array
#Domagoj Salkovic
#---------------
import sys

##global variables
fastaSeq=0 #if file is in FASTA format, fastaSeq is 1, else it is 0
#character map for FASTA format and plain text, they contain
#different letters because FASTA doesn't support all characters
charactersFasta=["$","*","-","A","B","C","D","E","F","G","H","I","J",
                 "K","L","M","N","O","P","Q","R","S","T","U","V",
                 "W","X","Y","Z"]    
charactersPlain=[" ","!",'"',"#","$","%","&","'","(",")","*","+",
                 ",","-",".",'/',"0","1","2","3","4","5","6","7","8","9",
                 ":",";","<","=",">","?","@","A","B","C","D","E","F",
                 "G","H","I","J","K","L","M","N","O","P","Q","R",
                 "S","T","U","V","W","X","Y","Z","[",'\\',"]","^","_","´",
                 "a","b","c","d","e","f","g","h","i","j","k","l","m",
                 "n","o","p","q","r","s","t","u","v","w","x","y","z",
                 "{","|","}","~"]    
#------------

#function returns list with triplets and their index number from sequence
#choice variable determines whether the triplets are from the
# 0-index field or 1,2-index field
def getTriplets(sequence,choice):
    triplets=[]
    if(choice==1):
        for i in range(len(sequence)-2):
            current=""
            if i%3==1:
                current+=(sequence[i]+sequence[i+1]+sequence[i+2])+":"+str(i)
                triplets.append(current)
        for i in range(len(sequence)-2):
            current=""
            if i%3==2:
                current+=(sequence[i]+sequence[i+1]+sequence[i+2])+":"+str(i)
                triplets.append(current)
    elif(choice==0):
        for i in range(len(sequence)-2):
            current=""
            if i%3==0:
                current+=(sequence[i]+sequence[i+1]+sequence[i+2])+":"+str(i)
                triplets.append(current)
    return triplets

#function returns empty bucket used in radix sort
#bucket contains all characters in the currently
#used character map in order
def sortBucket():
    global fastaSeq
    if fastaSeq==0:
        global charactersPlain
        characters=charactersPlain
    else:
        global charactersFasta
        characters=charactersFasta   
    bucket={}
    for letter in characters:
        bucket[letter]=[]
    return bucket

#function returns list with items sorted
#in the current radix sort iteration
def getBucketItems(bucket):
    global fastaSeq
    if fastaSeq==0:
        global charactersPlain
        characters=charactersPlain
    else:
        global charactersFasta
        characters=charactersFasta   
    triplets=[]
    for letter in characters:
        if bucket[letter]!=[]:
            for triplet in bucket[letter]:
                triplets.append(triplet)
    return triplets

#radixSort sorts the triplets by their containing letters
#at the end of the sort, we have triplets that are arranged
#in an alphabetical order in the order they appear in the
#original sequence
#function returns sorted triplets and their changed indexes in tIndexes
def radixSort(triplets):
    beginField=triplets
    for j in range(2,-1,-1):
        bucket=sortBucket()
        for triplet in triplets:
            bucket[triplet.split(":")[0][j]].append(triplet)
        triplets=getBucketItems(bucket)
    tIndexes=[]
    for i in range(len(triplets)):
        for j in range(len(beginField)):
            if beginField[j]==triplets[i]:
                tIndexes.append(j)
                break
    return triplets,tIndexes

#function compares triplet1 and triplet2
#to determine which comes sooner in the suffix array
#if the triplets are identical, then the one with the
#higher index gets picked and placed in the suffix array sooner
def compareTriplets(triplet1,triplet2):
    state=0
    for i in range(3):
        if triplet1.split(":")[0][i]<triplet2.split(":")[0][i]:
            state=-1
            return state
        elif triplet1.split(":")[0][i]>triplet2.split(":")[0][i]:
            state=1
            return state
    if state==0:
        if int(triplet1.split(":")[1])>int(triplet2.split(":")[1]):
            state=-1
            return state
        elif int(triplet1.split(":")[1])<int(triplet2.split(":")[1]):
            state=1
            return state

#function returns a suffix array from the sorted lists
#of 1,2-indexes and 0-indexes
#it compares current triplet from sortedOneTwo and sortedZero
#and writes one of them in to the suffix array
#the choice is determined by the triplet characters and their original index
#with same triplets in both fields, the one with the higher index is selected
#function iterates through both lists until all indexes are written
#to the suffix array
def getSuffixArray(sortedOneTwo,sortedZero):
    SA=[]
    suffixArray=[]
    cOneTwo=0
    cZero=0
    for i in range(len(sortedOneTwo)+len(sortedZero)):
        if cOneTwo>=len(sortedOneTwo):
            suffixArray.append(sortedZero[cZero].split(":")[1])
            SA.append(sortedZero[cZero])
            cZero+=1
        elif cZero>=len(sortedZero):
            suffixArray.append(sortedOneTwo[cOneTwo].split(":")[1])
            SA.append(sortedOneTwo[cOneTwo])
            cOneTwo+=1
        else:
            compare=compareTriplets(sortedOneTwo[cOneTwo],sortedZero[cZero])
            if compare==1:
                suffixArray.append(sortedZero[cZero].split(":")[1])
                SA.append(sortedZero[cZero])
                cZero+=1
            elif compare==-1:
                suffixArray.append(sortedOneTwo[cOneTwo].split(":")[1])
                SA.append(sortedOneTwo[cOneTwo])
                cOneTwo+=1
    #print SA
    return suffixArray

#prints out suffixes from array
def printSuffixes(suffixArray,sequence):
    for suffix in suffixArray:
        line=""
        for i in range(int(suffix),len(sequence),1):
            line+=sequence[i]
        print line

#prints the triplets contained in the triplets list
def printTriplets(triplets):
    line=""
    for t in triplets:
        line+=t.split(":")[0]
    print line

#reads from inputData file and returns the sequence that
#needs to have the suffix array calculated
#function also recognises if input file is plain or FASTA
#and writes it in the global variable fastaSeq
#if plain text, function returns sequence
#if FASTA, function can return multiple sequences in a list
def readFromFile(inputData):
    global fastaSeq
    f = open(inputData,"r")
    sequence=""
    fasta=0
    allSequences=[]
    seq=[]
    last="*"
    for line in f.readlines():
        if line[0]==">" or line[0]==";":
            if last=="*":
                last=line[0]
                fasta+=1
            else:
                if last==">" or last==";":
                    last=line[0]
                else:
                    allSequences.append(sequence+"$$")
                    sequence=""
                    fasta+=1
                    last=line[0]
        else:
            sequence+=line.rstrip()
            last=line[0]
    
    if fasta>0:
        fastaSeq=1
        allSequences.append(sequence+"$$")
        return allSequences
    elif fasta==0:
        seq.append(sequence+"$$")    
        return seq
    
#this function writes suffix array to output file
#allArray contains suffixes and outputData is the file name
def writeToFile(allArray,outputData):
    f = open(outputData,"w")
    for array in allArray:
        for item in array:
            f.write(item+" ")
        f.write("\n")

#main function runs the program
def main():
    global fastaSeq
    if len(sys.argv)!=3:
        #if incorrect number of command line parameters, error
        print "Incorrect number of parameters."
        return -1
    allArrays=[]
    sequence=readFromFile(sys.argv[1])
    for seq in sequence:
        if fastaSeq==1:
            seq=seq.upper() #if sequence is FASTA, all characters are uppercased
        #STEP 1
        # get triplets on 1,2-indexes and sort them
        tripletsOneTwo=getTriplets(seq,1)
        sortedOneTwo,indexOneTwo=radixSort(tripletsOneTwo)
        #------
        #STEP 2
        # get triplets on 0-indexes and sort them
        tripletsZero=getTriplets(seq,0)
        sortedZero,indexZero=radixSort(tripletsZero)
        #------
        #STEP 3
        # use sorted indexes to get suffix array
        suffixArray=getSuffixArray(sortedOneTwo,sortedZero)
        allArrays.append(suffixArray)
        #------
    #prints suffix array(s) to an output file
    writeToFile(allArrays,sys.argv[2])
if __name__=="__main__":
    main()
