local function InstallFromGit(repoFile, saveTo)
local download = http.get("https://github.com/TrueBeef/CCLuaProjects/raw/main/" .. repoFile) --This will make 'download' hold the contents of the file.
if download then --checks if download returned true or false
   local handle = download.readAll() --Reads everything in download
   download.close() --remember to close the download!
   local file = fs.open(saveTo,"w") --opens the file defined in 'saveTo' with the permissions to write.
   file.write(handle) --writes all the stuff in handle to the file defined in 'saveTo'
   file.close() --remember to close the file!
  else --if returned false
   print("Unable to download the file "..repoFile)
   print("Make sure you have the HTTP API enabled or")
   print("an internet connection!")
  end --end the if
end --close the function

term.clear()
term.setCursorPos(1,1)
term.write("Filename in CCLuaProjectsRepo: ")
local repoFile = read()
repoFile = (repoFile .. ".lua")

term.clear()
term.setCursorPos(1,1)
term.write("Selected Filename: " .. repoFile .. "\n")
term.write("Save as: ")
local saveAs = read()

InstallFromGit(repoFile, saveAs)