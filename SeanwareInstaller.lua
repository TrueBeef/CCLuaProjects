local function InstallFromGit(repoFile, saveTo)
local download = http.get("https://github.com/TrueBeef/CCLuaProjects/raw/main/" .. repoFile) --This will make 'download' hold the contents of the file.
if download then --checks if download returned true or false
   local handle = download.readAll() --Reads everything in download
   download.close() --remember to close the download!
   local file = fs.open(saveTo,"w") --opens the file defined in 'saveTo' with the permissions to write.
   file.write(handle) --writes all the stuff in handle to the file defined in 'saveTo'
   file.close() --remember to close the file!
   print("Installed file: " .. repoFile)
  else --if returned false
   print("Unable to download the file ".. repoFile)
   print("Make sure you have the HTTP API enabled or")
   print("an internet connection!")
  end --end the if
end --close the function

--Put all our things here we for sure want installed.
-- Just the filenames.
print("Installing Dependencies ... ")
InstallFromGit("TurtleMovementUtil", "TurtleMovementUtil")
InstallFromGit("MinePlus", "MinePlus")

sleep(3)

term.clear()
term.setCursorPos(1,1)
term.write("Filename in CCLuaProjectsRepo:")
term.setCursorPos(1,2)
local repoFile = read()
repoFile = (repoFile .. ".lua")

term.clear()
term.setCursorPos(1,1)
term.write("Selected Filename: " .. repoFile)
term.setCursorPos(1,2)
term.write("Save as: ")
term.setCursorPos(1,3)
local saveAs = read()

InstallFromGit(repoFile, saveAs)