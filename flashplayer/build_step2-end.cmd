SET INFILE=%CD%\src\kprftvlive.as
SET OUTFILE=%CD%\bin\kprftvlive.swf
SET RMFILE=%CD%\bin\kprftvlivec.swf

chcp 1251
cd /flex/bin/
mxmlc.exe -static-link-runtime-shared-libraries=true -metadata.creator=EvgeniyKozin %INFILE% -output=%OUTFILE%
del %RMFILE%
pause
