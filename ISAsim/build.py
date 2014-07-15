import os
print("Cleaning...")
os.system("make clean")
print("Building...")
os.system("make")
print("Done")