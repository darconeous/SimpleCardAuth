#!/bin/sh

sqlite3 ./logDB.sqlite "CREATE TABLE Identity (ID INTEGER PRIMARY KEY, CommonName TEXT, OrganizationName TEXT, StateOrProvinceName TEXT, CountryName TEXT, LocalityName TEXT, OrganizationalUnitName TEXT, email TEXT);"

sqlite3 ./logDB.sqlite "Create table AccessAttempt (ID INTEGER PRIMARY KEY, Identity_ID TEXT, timestamp TEXT, success INTEGER, FOREIGN KEY(Identity_ID) REFERENCES Identity(ID));"
