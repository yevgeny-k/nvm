SET INFILE=%CD%\src\kprftvlivec.as
SET OUTFILE=%CD%\bin\kprftvlivec.swf

chcp 1251
cd /flex/bin/
mxmlc.exe -static-link-runtime-shared-libraries=true -metadata.creator=EvgeniyKozin %INFILE% -output=%OUTFILE%
pause
