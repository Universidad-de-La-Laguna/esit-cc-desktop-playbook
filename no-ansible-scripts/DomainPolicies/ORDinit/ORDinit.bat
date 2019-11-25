@echo off

c:\Windows\System32\setx path "C:\Windows\System32;C:\Program Files\Java\jre1.8.0_25\bin"


if not exist c:\windows\confetsii (
  md c:\windows\confetsii
)

if not exist c:\windows\ejecutados (
  md  c:\windows\ejecutados
)

\\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xcacls c:\windows\confetsii /G todos:F /Y
\\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xcacls c:\windows\ejecutados /G todos:F /Y


rem \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xcacls "C:\Program Files\reno" /G todos:F /Y

echo "pp1" > c:\windows\confetsii\w7.txt


if not exist c:\windows\ejecutados\D020710 (
    echo a > c:\windows\ejecutados\D020710
    @REM rmdir /s /q "c:\Users\Default\"
    @rem xcopy /y /x /h /o /E \\lagar\default$ "c:\Documents and Settings\Default User\"
    rem xcopy /y /x /h /o /E P:\perfil_obligatorio.v2\*.* "c:\Users\Default.COPIA-porfin\"
    rem xcopy /y /x /h /o /E \\lagar\netlogon\perfilw7\ "c:\Users\Default.COPIA\"

)

if not exist c:\windows\ejecutados\invitado2_ (
    echo a > c:\windows\ejecutados\invitado2_
    net user invitado2 /delete
    net user invitado2 /add /expires:never
    net user invitado2 "enlaull"
    WMIC USERACCOUNT WHERE "Name='invitado2'" SET PasswordExpires=FALSE
)

if not exist c:\windows\ejecutados\aluprim (
    echo a > c:\windows\ejecutados\aluprim
    net user aluprim /delete
    net user aluprim "aluenlaull" /add /expires:never
    WMIC USERACCOUNT WHERE "Name='aluprim'" SET PasswordExpires=FALSE
)

if not exist c:\windows\ejecutados\etsii2_ (
    echo a > c:\windows\ejecutados\etsii2_
    net user /add etsii2 /expires:never
    net user etsii2 "laguna"
    net localgroup Administradores etsii2 /add
    WMIC USERACCOUNT WHERE "Name='etsii2'" SET PasswordExpires=FALSE
)


if not exist c:\windows\ejecutados\invitado31 (
    echo a > c:\windows\ejecutados\invitado31
    net user invitado3 /delete
    net user /add invitado3 /expires:never
    net user invitado3 "enlaull3" 
    WMIC USERACCOUNT WHERE "Name='invitado3'" SET PasswordExpires=FALSE
    
)


if not exist c:\windows\ejecutados\opo0619 (
    echo a > c:\windows\ejecutados\opo0619
    net user /del opo
    net user /add opo /expires:never
    net user opo "opoenlaull" 
    net localgroup Administradores opo /add
    WMIC USERACCOUNT WHERE "Name='opo'" SET PasswordExpires=FALSE

)

if not exist c:\windows\ejecutados\opo219 (
    echo a > c:\windows\ejecutados\opo219
    net user /del opo2
    net user /add opo2 /expires:never
    net user opo2 "opoenlaull2" 
    net localgroup Administradores opo2 /add
    WMIC USERACCOUNT WHERE "Name='opo2'" SET PasswordExpires=FALSE

)


if not exist c:\windows\ejecutados\xilinx_lic1 (
    echo a > c:\windows\ejecutados\xilinx_lic1
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xilinx12\settings32.bat "c:\Xilinx\12.4\ISE_DS\common\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xilinx12\settings64.bat "c:\Xilinx\12.4\ISE_DS\common\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xilinx14\settings32.bat "c:\Xilinx\14.7\ISE_DS\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\xilinx14\settings64.bat "c:\Xilinx\14.7\ISE_DS\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Xilinx14\ISE-lib-nt64\*.* "C:\Xilinx\14.7\ISE_DS\ISE\lib\nt64\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Xilinx14\Common-lib-nt64\*.* "C:\Xilinx\14.7\ISE_DS\common\lib\nt64\"

)

if not exist c:\windows\ejecutados\Pilar72a (
    echo a > c:\windows\ejecutados\Pilar72a
    xcopy /y /E \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Pilar72\PILAR_7.2\*.* "C:\Program Files (x86)\PILAR_7.2\"
    xcopy /y /E \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Pilar72\PilarBasic_7.2\*.* "C:\Program Files (x86)\PilarBasic_7.2\"
    xcopy /y /E \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Pilar72\PilarMicro_7.2\*.* "C:\Program Files (x86)\PilarMicro_7.2\"
    xcopy /y \\ull.local\SysVol\ull.local\Policies\{9D6D0523-981C-458C-B3E0-E49FF1DC9C2B}\Machine\Scripts\bin\Pilar72\PILAR\*.* "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PILAR\"
)

if not exist c:\windows\ejecutados\BorraPilar6 (
    echo a > c:\windows\ejecutados\BorraPilar6
    rmdir /Q /S "C:\Program Files (x86)\PILAR_6.2\"
    rmdir /Q /S "C:\Program Files (x86)\PilarBasic_6.1\"
    rmdir /Q /S "C:\Program Files (x86)\PilarMicro_6.1\"
)

if not exist c:\windows\ejecutados\Borraetsii3 (
    echo a > c:\windows\ejecutados\Borraetsii3
    net user /del etsii3
)


if not exist c:\windows\ejecutados\Borracomerzzia (
    echo a > c:\windows\ejecutados\Borracomerzzia
    net user comerzzia /delete
        
)

