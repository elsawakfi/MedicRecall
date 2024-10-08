class Card:
    def __init__(self, name):
        self.name = name

import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("serviceAccountKey.json")

firebase_admin.initialize_app(cred)
db = firestore.client()

db.collection("flashcards").document().create({"front":"aaa"})

import json, copy

file = open("8.txt","r").readlines()

newfile = []

for line in file:
    if line == "\n" or line == "":
        continue

    newfile.append(line.replace("\n",""))

file = newfile
j = {"front":"front", "back":"back", "topic":"topic", "subtopic":"subtopic"}

jsonList = []

subtopic = ""
front = ""
back = ""
topic = "Who’s who"

i = 0
for line in file:
    if line[0] == "-":
        front = line.replace("-","")
        back = ""
        c = 1
        while 1:
            if (c+i > len(file)-1): break
            if (file[c+i][0] != " "): break
            #print(file[c+i])
            back+=file[c+i].replace("    - "," -")
            c += 1
        
        db.collection("flashcards").document().create({"front":front, "back":back, "topic": topic, "subtopic": subtopic})
    else:
        if not line[0] in ["-"," "]:
            subtopic = line
        #continue
    
    i += 1

for j in jsonList:
    print(j)

    
    
    
    
    
    