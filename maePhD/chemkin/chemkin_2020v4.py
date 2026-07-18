# modification history
# (02/06/2017 Tanner) handle blank entry in constants list
# (10/15/2020 Andrew Navratil) global numbering 
# (10/16/2020 Andrew Navratil) reaction tags
# (10/30/2020 Andrew Navratil) handle comments on non-reaction lines (!F=2 in LOW)
#                              assumes reaction lines have '=' in first 32 chars
# (10/30/2020 Andrew Navratil) created file1a (exchange_plog.csv) for exchange reacs w PLOG
#-----------------------------------------------
import sys, os, getopt, pTable

FILENAME = ''
REACTION_LIST_TYPE1 = []
REACTION_LIST_TYPE1a = []
REACTION_LIST_TYPE2 = []
REACTION_LIST_TYPE3 = []
STOICH_LIST = []
SCALE_LIST = []
WS = [
    ' ',
    '\t',
    '\s',
    '\r',
    '\f',
    '\n',
    '\v'
    ]
def isnumeric(VAL):
   if (ord(VAL) > ord('0') and ord(VAL) < ord('9')):
       return True
   else:
       return False

def is_number(n):
    try:
        float(n)
    except ValueError:
        return False
    return True

def main(argv):
   FILENAME = ''
   try:
      opts, args = getopt.getopt(argv,"f:",["filename="])
   except getopt.GetoptError:
      print ('test.py -f <inputfile>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print ('test.py -f <inputfile>')
         sys.exit()
      elif opt in ("-f", "--filename"):
         FILENAME = arg
   print ('Input file is <%s>' % FILENAME)
   return FILENAME

if __name__ == "__main__":
   FILENAME = main(sys.argv[1:])
   
def readlines(FN):
    return open(FN,'r').read().split('\n')

def indexLine(ARRAY, STR_START, STR_END):
   INDEX = []
   for (x,y) in enumerate(ARRAY):
      if ((STR_START in y or STR_START.lower() in y or STR_START.title() in y) and '!' not in y):
         INDEX.append(x)
         for (n,m) in enumerate(ARRAY[INDEX[0]:]):
            if ((STR_END in m or STR_END.lower() in m or STR_END.title() in m) and '!' not in m):
               INDEX.append(INDEX[0]+n)
               return INDEX

def indexString(STR, STR_START, STR_END):
   IND = [0,0]
   if (STR_START in STR or STR_START.lower() in STR or STR_START.title() in STR):
      IND[0] = STR.find(STR_START)+len(STR_START)
   if (STR_END in STR or STR_END.lower() in STR or STR_END.title() in STR):
      IND[1] = STR.find(STR_END)
   return IND
                
def depthReplace(STR,DEPTH,REMOVE,REPLACE):
   STR_BUF = STR
   while(DEPTH > 0):
      for x in REMOVE:
         STR_BUF = STR_BUF.replace(DEPTH*x,REPLACE)
      DEPTH -= 1
   return STR_BUF

def splitReactionLineIndex(STR): #<-----
   POS = STR.find('.')
   x = 1
   while (STR[POS-x] == '-' or isnumeric(str(STR[POS-x]))):
      x += 1
   return (POS - x)

def removeWhiteSpace(STR):
   for n in WS:
      STR = STR.replace(n, '')
   return STR

def removeExcessRxnSpecies(R,P):
   for x in S_BLOCK:
      if (R.count(x) > 1):
         del R[R.index(x)]
      if (P.count(x) > 1):
         del P[P.index(x)]
   return [R,P]

def orderReactions(REAC,PROD,R,P):
   RXN = []
   STO = []
   for x in REAC:
      if (x == 'M'):
         RXN.append(0)
         STO.append(0)
      else:
         RXN.append(R[x][0])
         STO.append(R[x][1])
   for x in range(0,3-len(REAC)):
      RXN.append(0)
      STO.append(0)
   for x in PROD:
      if (x == 'M'):
         RXN.append(0)
         STO.append(0)
      else:
         RXN.append(P[x][0])
         STO.append(P[x][1])
   for x in range(0,3-len(PROD)):
      RXN.append(0)
      STO.append(0)
   return [RXN,STO]

def matchCount(LIST,STR,POS,DICT):
   if (LIST.count(STR) != 0):
      if (STR in DICT):
         DICT[STR] = [POS,DICT[STR][1] + LIST.count(STR)]
      else:
         DICT[STR] = [POS,LIST.count(STR)]
   else:
      for x in range(2,10):
         VAL = str(x)+STR
         if (LIST.count(VAL) == 0):
            continue
         else:
            LIST[LIST.index(VAL)] = STR
            DICT[STR] = [POS,x]

def popRxnLists(REAC,PROD,R,P):
   for (n,m) in enumerate(S_BLOCK):
      matchCount(REAC,m,n,R)
      matchCount(PROD,m,n,P)

def scaleLinearMatrix(S,M):
   B = []
   for x in M:
      B.append(float("%.2E" % (float(x)*float(S))))
   return B

def strToFloatList(LIST):
   for (x,y) in enumerate(LIST[:2]):
      LIST[x] = float(y)
   return LIST
         
def findPropertyBlock(LIST,BLOCK):
   for (n,m) in enumerate(BLOCK):
      for x in LIST:
         if (x in m):
            return depthReplace(m.split('/')[1].strip(),15,WS,'~').split('~')

def findPropertyBlockMultiple(LIST,BLOCK):
   mblock = []
   for (n,m) in enumerate(BLOCK):
      for x in LIST:
         if (x in m):
            mblock.append(depthReplace(m.split('/')[1].strip(),15,WS,'~').split('~'))
   return mblock

def findPropertyString(LIST,STR):
   for x in LIST:
      if (x in STR):
         return 1
   return 0

def genBlock(RXNS,X):
   BLOCK = []
   LIST = list(RXNS[X+1:])
   for (x,y) in enumerate(LIST):
      y = y.strip()
      if ('!' in y and '=' not in y and y[0] == '!'):
         del LIST[x]
   for (n,m) in enumerate(LIST):
      #if ('=' in m):
      # fix to handle !F=xx on LOW lines
      if ('=' in m[0:31]):
         BLOCK = LIST[:n]
         break
      elif (n == (len(LIST)-1)):
         BLOCK = LIST
         break

   return BLOCK

def storeScales(BLOCK):
   S = ''
   for (n,m) in enumerate(BLOCK):
      if (findPropertyString(EXC,m) == 0 and '!' not in m):
         m = m.strip()
         m = removeWhiteSpace(m)
         S += m
   if (S != ''):
      SCALES = S[:-1].split('/')
      SCALE_DICT = {}
      for x in range(0,len(SCALES),2):
         if (SCALES[x+1] != '0.0' or SCALES[x+1] != '0'):
            SCALE_DICT[SCALES[x]] = SCALES[x+1]
      return SCALE_DICT
   return {}

def blockSplit(ARRAY,OPEN,CLOSE):
   IND = indexLine(ARRAY,OPEN,CLOSE)
   STR_BUFFER = " "
   for x in CONTENTS[IND[0]:IND[1]+1]:
      if ('!' not in x):
         STR_BUFFER += ' ' + x.strip()
   STR_IND = indexString(STR_BUFFER,OPEN,CLOSE)
   STR_BUFFER = ' M ' + STR_BUFFER[STR_IND[0]:STR_IND[1]].upper()
   return depthReplace(STR_BUFFER.strip(),15,WS,'~').split('~')

DIR = FILENAME[:FILENAME.find('.')]

if not os.path.exists(DIR):
   os.makedirs(DIR)
    
# Deletes Files in Directory
list(map(os.unlink, (os.path.join( os.getcwd()+ '/' + DIR,f) for f in os.listdir(os.getcwd()+ '/' + DIR))))

vTROE = ['troe','troE','trOe','trOE','tRoe','tRoE','tROe','tROE','Troe','TroE','TrOe','TrOE','TRoe','TRoE','TROe','TROE']
vLOW = ['low','Low','LoW','LOw','LOW','loW','lOw','lOW']
vSRI = ['sri','Sri','SrI','SRi','SRI','srI','sRi','sRI']
vREV = ['rev','Rev','ReV','REv','REV','reV','rEv','rEV']
vPLOG = ['PLOG']
EXC = set(vTROE + vLOW + vSRI + vREV + vPLOG)
WEIGHTS_FILE = DIR + '/weights.csv'
CONFIG_FILE = DIR + '/config.csv'
REACTION_FILE_1 = DIR + '/exchange.csv'
REACTION_FILE_1a = DIR + '/exchange_plog.csv'
REACTION_FILE_2 = DIR + '/three_body.csv'
REACTION_FILE_3 = DIR + '/hybrid.csv'
FILE_1 = open(REACTION_FILE_1,'a')
FILE_1a = open(REACTION_FILE_1a,'a')
FILE_2 = open(REACTION_FILE_2,'a')
FILE_3 = open(REACTION_FILE_3,'a')
FILE_4 = open(CONFIG_FILE,'a')
FILE_5 = open(WEIGHTS_FILE,'a')
REACTION_LIST_TYPE1 = []
REACTION_LIST_TYPE1a = []
REACTION_LIST_TYPE2 = []
REACTION_LIST_TYPE3 = []
STOICH_LIST = []
SCALE_LIST = []
INV_W = []
WS = [
    ' ',
    '\t',
    '\s',
    '\r',
    '\f',
    '\n',
    '\v'
    ]

CONTENTS = readlines(FILENAME)
E_BLOCK = blockSplit(CONTENTS, 'ELEMENTS', 'END')
S_BLOCK = blockSplit(CONTENTS, 'SPECIES', 'END')

M_INV = []
for (n,m) in enumerate(S_BLOCK[1:]):
    if (m in E_BLOCK[1:]):
        M_INV.append(1.0/pTable.weights[m])
    else:
        MASS = 0.0
        for (x,y) in enumerate(m):
            if (isnumeric(str(y))): continue
            else: 
                if (m[x] not in E_BLOCK[1:]): continue
                if ((x+1) < len(m)):
                    if (isnumeric(str(m[x+1]))):
                        MASS += int(m[x+1])*pTable.weights[m[x]]
                    else:
                        MASS += pTable.weights[m[x]]
                else:
                    MASS += pTable.weights[m[x]]
        M_INV.append(1.0/MASS)

for x in M_INV:
    FILE_5.write(str(x)+'\n')

FILE_5.close()

IND = indexLine(CONTENTS, 'REACTIONS', 'END')
REACTIONS = CONTENTS[IND[0]:IND[1]]

# track the order of all reactions in the initial input file
global_number = 1

for (x,y) in enumerate(REACTIONS):
   # fix to handle !F=xx on LOW lines
   # if not a reaction line (= in first 31 chars), just skip ahead to next reaction line
   if ('=' not in y[0:31]):
      continue

   # added flag for reaction type: 0 for = or <=>, 1 for =>
   y = y.strip().upper()
   react_tag = 0
   if ('<=>' in y or '=' in y):
      y = y.replace('<=>', '=')
      react_tag = 0
   if ('=>' in y):
      y = y.replace('=>', '=')
      react_tag = 1

   if (y.strip() != '' and (y.strip() != 'DUPLICATE' or y.strip() != 'duplicate') and y[0] != '!' and '=' in y):
      R = {}
      P = {}
      RXN_ORD = []
      STO_ORD = []
      H_BLOCK = []
      SCALE_DICT = {}
      LOW = []
      TROE = []
      SRI = []
      POS = splitReactionLineIndex(y)

      # global number and reaction tag appended to beginning of line in output files
      STR = str(global_number) + ',' + str(react_tag) + ','
      global_number += 1

      REACTION = removeWhiteSpace(y[:POS])
      if ('+M' in REACTION and '(+M)' not in REACTION): # Three Body Reactions
         STRTMP = STR + ' ' + REACTION # STR is now reserved for output to file
         H_BLOCK = genBlock(REACTIONS,x)
         COUNT = 0
         TROE = findPropertyBlock(vTROE,H_BLOCK)
         if (TROE):
            if (len(TROE) < 4):
                TROE.append('0.0')
            COUNT += 1
         else:
            TROE = ['0.0','0.0','0.0','0.0']
         REV = findPropertyBlock(vREV,H_BLOCK)
         if (REV):
            REV = strToFloatList(REV)
            COUNT += 1
         SCALE_DICT = storeScales(H_BLOCK)
         for x in S_BLOCK[1:]:
             if x in SCALE_DICT:
                 continue
             else:
                 SCALE_DICT[x] = '1.0'
         REACTION = REACTION.replace('+','.').split('=')
         REAC = REACTION[0].split('.')
         PROD = REACTION[1].split('.')
         
         FLAG = 0
         for x in REAC:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         for x in PROD:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         if FLAG != 0:
             continue
         print ('  ' + STRTMP)

         if ('!'  in y):
            CONSTANTS = depthReplace(y[POS:y.find('!')].strip(),15,WS,'~').split('~')
         else:
            CONSTANTS = depthReplace(y[POS:].strip(),15,WS,'~').split('~')
         for (n,m) in enumerate(CONSTANTS):
            if ('E+' in m or 'e+' in m):
               if ('e+' in m): 
                  CONSTANTS[n].replace('e+','E+')
               if ('e-' in m): 
                  CONSTANTS[n].replace('e-','E-')
            elif ('+' in m):
               CONSTANTS[n].replace('+','E+')
         CONSTANTS = filter(None, CONSTANTS)  # Tanner 02/06/2017: gets rid of a blank entry in CONSTANTS list (seems to occur for some three body reactions with negative b coefficient)
             
         popRxnLists(REAC,PROD,R,P)

         REACTION = removeExcessRxnSpecies(REAC,PROD)
         REAC = REACTION[0]
         PROD = REACTION[1]

         REACTION = orderReactions(REAC,PROD,R,P)
         RXN_ORD = REACTION[0]
         STO_ORD = REACTION[1]
         
         for n in RXN_ORD:
            STR += str(float(n)) + ','
         for n in STO_ORD:
            STR += str(float(n)) + ','
         for n in CONSTANTS:
            STR += n + ','
        
         REACTION_LIST_TYPE2.append([STR,TROE,SCALE_DICT])             

      REACTION = removeWhiteSpace(y[:POS])
      if ('(+M)' in REACTION or '(+N2)' in REACTION or '(+H2)' in REACTION or '(+AR)' in REACTION or '(+HE)' in REACTION or '(+H2O)' in REACTION): # Hybrid Reactions
         STRTMP = STR + ' ' + REACTION
         H_BLOCK = genBlock(REACTIONS,x)
         COUNT = 0
         LOW = findPropertyBlock(vLOW,H_BLOCK)
         if (LOW):
            LOW = strToFloatList(LOW)
            COUNT += 1
         else:
            LOW = ['0.0','0.0','0.0']
         TROE = findPropertyBlock(vTROE,H_BLOCK)
         if (TROE):
            if (len(TROE) < 4):
                TROE.append('0.0')
            COUNT += 1
         else:
            TROE = ['0.0','0.0','0.0','0.0']
         SRI = findPropertyBlock(vSRI,H_BLOCK)
         if (SRI):
            SRI = strToFloatList(SRI)
            COUNT += 1
         REV = findPropertyBlock(vREV,H_BLOCK)
         if (REV):
            REV = strToFloatList(REV)
            COUNT += 1
         SCALE_DICT = storeScales(H_BLOCK)
         for x in S_BLOCK[1:]:
             if x in SCALE_DICT:
                 continue
             else:
                 SCALE_DICT[x] = '1.0'
         if ('(+M)' in REACTION):
            REACTION = REACTION.replace('(+M)','+M').replace('+','.').split('=')
         if ('(+N2)' in REACTION):
            REACTION = REACTION.replace('(+N2)','+N2').replace('+','.').split('=')
         if ('(+H2)' in REACTION):
            REACTION = REACTION.replace('(+H2)','+N2').replace('+','.').split('=')
         if ('(+AR)' in REACTION):
            REACTION = REACTION.replace('(+AR)','+AR').replace('+','.').split('=')
         if ('(+HE)' in REACTION):
            REACTION = REACTION.replace('(+HE)','+HE').replace('+','.').split('=')
         if ('(+H2O)' in REACTION):
            REACTION = REACTION.replace('(+H2O)','+H2O').replace('+','.').split('=')
         REAC = REACTION[0].split('.')
         PROD = REACTION[1].split('.')

         FLAG = 0
         for x in REAC:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         for x in PROD:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         if FLAG != 0:
             continue
         print ('  ' + STRTMP)
 
         if ('!'  in y):
            CONSTANTS = depthReplace(y[POS:y.find('!')].strip(),15,WS,'~').split('~')
         else:
            CONSTANTS = depthReplace(y[POS:].strip(),15,WS,'~').split('~')

         for (n,m) in enumerate(CONSTANTS):
            if ('E+' in m or 'e+' in m):
               if ('e+' in m): 
                  CONSTANTS[n].replace('e+','E+')
               if ('e-' in m): 
                  CONSTANTS[n].replace('e-','E-')
            elif ('+' in m):
               CONSTANTS[n].replace('+','E+')
         CONSTANTS = filter(None, CONSTANTS)  # Tanner 02/06/2017: gets rid of a blank entry in CONSTANTS list (seems to occur for some three body reactions with negative b coefficient)
        
         popRxnLists(REAC,PROD,R,P)

         REACTION = removeExcessRxnSpecies(REAC,PROD)
         REAC = REACTION[0]
         PROD = REACTION[1]

         REACTION = orderReactions(REAC,PROD,R,P)
         RXN_ORD = REACTION[0]
         STO_ORD = REACTION[1]

         RATE = ''
         for n in RXN_ORD:
            STR += str(float(n)) + ','
         for n in STO_ORD:
            STR += str(float(n)) + ','
         for n in CONSTANTS:
            RATE += n + ','
         REACTION_LIST_TYPE3.append([STR,LOW,RATE,TROE,SCALE_DICT])

      REACTION = removeWhiteSpace(y[:POS])
      if ('+M' not in REACTION and '(+N2)' not in REACTION and '(+H2)' not in REACTION and '(+AR)' not in REACTION and '(+HE)' not in REACTION and '(+H2O)' not in REACTION): # Exchange Reactions
         STRTMP = STR + ' ' + REACTION
         reacidx = x # save current input file line index for use in PLOG
         
         REACTION = REACTION.replace('+','.').split('=')
         if (REACTION[0].find('.')):
            REAC = REACTION[0].split('.')
         else:
            REAC = [REACTION[0].strip()]
            
         if (REACTION[1].find('.')):
            PROD = REACTION[1].split('.')
         else:
            PROD = [REACTION[1].strip()]
         FLAG = 0
         for x in REAC:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         for x in PROD:
             if (x[0].isdigit()):
                 if (x[1:] in S_BLOCK):
                    pass
             elif (x in S_BLOCK):
                 pass
             else:
                 FLAG += 1
         if FLAG != 0:
             continue
         print ('  ' + STRTMP)
         
         if ('!'  in y):
            CONSTANTS = depthReplace(y[POS:y.find('!')].strip(),15,WS,'~').split('~')
         else:
            CONSTANTS = depthReplace(y[POS:].strip(),15,WS,'~').split('~')

         for (n,m) in enumerate(CONSTANTS):
            if ('E+' in m or 'e+' in m):
               if ('e+' in m): 
                  CONSTANTS[n].replace('e+','E+')
               if ('e-' in m): 
                  CONSTANTS[n].replace('e-','E-')
            elif ('+' in m):
               CONSTANTS[n].replace('+','E+')
         CONSTANTS = filter(None, CONSTANTS)  # Tanner 02/06/2017: gets rid of a blank entry in CONSTANTS list (seems to occur for some three body reactions with negative b coefficient)

         popRxnLists(REAC,PROD,R,P)
         
         REACTION = removeExcessRxnSpecies(REAC,PROD)
         REAC = REACTION[0]
         PROD = REACTION[1]

         REACTION = orderReactions(REAC,PROD,R,P)
         RXN_ORD = REACTION[0]
         STO_ORD = REACTION[1]

         for n in RXN_ORD:
            STR += str(float(n)) + ','
         for n in STO_ORD:
            STR += str(float(n)) + ','
         for n in CONSTANTS:
            STR += n + ','

         # process reactions with PLOG entries
         PLOGALL = ''
         H_BLOCK = genBlock(REACTIONS,reacidx)
         PLOG = findPropertyBlockMultiple(vPLOG,H_BLOCK)
         pcount = len(PLOG)
         if (pcount > 0):
            for (x,y) in enumerate(PLOG):
               for (n,m) in enumerate(y):
                  if (is_number(m)):
                     PLOGALL += str(m) + ','

         if (pcount > 0):
            PLOGALL = str(pcount) + ',' + PLOGALL[:-1] # [:-1] is to remove trailing ,
            REACTION_LIST_TYPE1a.append([STR,PLOGALL]) 
         else:
            REACTION_LIST_TYPE1.append([STR[:-1]])

for x in REACTION_LIST_TYPE1:
   FILE_1.write(x[0]+'\n')
    
for x in REACTION_LIST_TYPE1a:
   FILE_1a.write(x[0]+x[1]+'\n')
    
for x in REACTION_LIST_TYPE2:
   SCALE = []
   for y in S_BLOCK[1:]:
      if (y in x[2]):
         SCALE.extend([x[2][y]])
   STR = ''
   for y in x[1]:
         STR += y + ','
   for y in SCALE:
      STR += str(float(y)).strip() + ','
   FILE_2.write(x[0] + STR[:-1] + '\n')
        
for x in REACTION_LIST_TYPE3:
   SCALE = []
   for y in S_BLOCK[1:]:
      if (y in x[4]):
         SCALE.extend([x[4][y]])
   LOW = ''
   for y in x[1]:
         LOW += str(y) + ','
   RATE = x[2]
   TROE = ''
   for y in x[3]:
         TROE += y + ','
   SCALES = ''
   for y in SCALE:
      SCALES += str(float(y)).strip() + ','
   FILE_3.write(x[0] + LOW + RATE + TROE + SCALES[:-1] + '\n')

NUM_RXNS = len(REACTION_LIST_TYPE2)+len(REACTION_LIST_TYPE3)+len(REACTION_LIST_TYPE1)
NUM_RXNS += len(REACTION_LIST_TYPE1a)
NUM_SPECIES = len(S_BLOCK[1:])
FILE_4.write(str(NUM_RXNS) + ',' + str(NUM_SPECIES))

#print (NUM_RXNS,NUM_SPECIES)
print ('Done processing %d reaction mechanisms from file <%s>.' % (NUM_RXNS,FILENAME) )

FILE_1.close()
FILE_1a.close()
FILE_2.close()
FILE_3.close()
FILE_4.close()
