# -*- coding: cp1250 -*-
#Suffix array
#Domagoj Salkovic
#---------------
import sys
#import time

fastaSeq=0
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

def getBucketItems(bucket):
    global fastaSeq
    if fastaSeq==0:
        global charactersPlain
        characters=charactersPlain
    else:
        global charactersFasta
        characters=charactersFasta   
    triplets=[]
    indexes=[]
    for letter in characters:
        if bucket[letter]!=[]:
            for triplet in bucket[letter]:
                triplets.append(triplet)
    return triplets

def radixSort(triplets):
    for j in range(2,-1,-1):
        bucket=sortBucket()
        for triplet in triplets:
            bucket[triplet.split(":")[0][j]].append(triplet)
        triplets=getBucketItems(bucket)
    return triplets

def compareTriplets(triplet1,triplet2):
    state=0
    for i in range(3):
        if triplet1.split(":")[0][i]<triplet2.split(":")[0][i]:
            state=-1
            return state
        elif triplet1.split(":")[0][i]>triplet2.split(":")[0][i]:
            state=1
            return state
        else:
            continue
    if state==0:
        if triplet1.split(":")[1]<triplet2.split(":")[1]:
            state=1
            return state
        elif triplet1.split(":")[1]>triplet2.split(":")[1]:
            state=-1
            return state
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
            #print sortedOneTwo[cOneTwo],sortedZero[cZero],compare
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

def printSuffixes(suffixArray,sequence):
    for suffix in suffixArray:
        line=""
        for i in range(int(suffix),len(sequence),1):
            line+=sequence[i]
        print line
        
def printTriplets(triplets):
    line=""
    for t in triplets:
        line+=t.split(":")[0]
    print line
    
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

def writeToFile(allArray,outputData):
    f = open(outputData,"w")
    for array in allArray:
        for item in array:
            f.write(item+" ")
        f.write("\n")

def main():
    #start_time = time.time()
    global fastaSeq
    if len(sys.argv)!=3:
        print "Incorrect number of parameters."
        return -1
    allArrays=[]
    sequence=readFromFile(sys.argv[1])
    for seq in sequence:
        #STEP 1
        if fastaSeq==1:
            seq=seq.upper()
        tripletsOneTwo=getTriplets(seq,1)
        sortedOneTwo=radixSort(tripletsOneTwo)
        #------
        #STEP 2
        tripletsZero=getTriplets(seq,0)
        sortedZero=radixSort(tripletsZero)
        #------
        suffixArray=getSuffixArray(sortedOneTwo,sortedZero)
        #printSuffixes(suffixArray,seq[:-1])
        allArrays.append(suffixArray)
    writeToFile(allArrays,sys.argv[2])
    #elapsed_time = time.time() - start_time
    #print "Time: ",elapsed_time," sec"
    #print "-------\nSequence: ",sequence+"$"
if __name__=="__main__":
    main()
