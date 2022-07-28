@echo off
color 2e
cd "%userprofile%\GOMES\sneak"
title Sneak Game - Gomes
if "%~1" == "startGame" goto :game
if "%~1" == "startController" goto :controller



set "choice="
2>nul >nul choice /c:yn /t 0 /d y
if errorlevel 1 if not errorlevel 2 set "choice=choice /cs"
if not defined choice (
  2>nul >nul choice /c:yn /t:y,1
  if errorlevel 1 if not errorlevel 2 set "choice=choice /s"
)
if not defined choice (
  echo ERROR: This game requires the CHOICE command, but it is missing.
  echo Game aborted. :(
  echo(
  echo A 16 bit port of CHOICE.EXE from FREEDOS is available at
  echo http://winsupport.org/utilities/freedos-choice.html
  echo(
  echo A 32 bit version from ??? suitable for 64 bit machines is available at
  echo http://hp.vector.co.jp/authors/VA007219/dkclonesup/choice.html
  echo(
  exit /b
)




set "keys=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "keyFile=key.txt"
set "cmdFile=cmd.txt"
set "highscoreFile=last score on !difficulty!.txt"


copy nul "%keyFile%" >nul
start "" /b "%~f0" startController 9^>^>%keyFile% 2^>nul ^>nul
cmd /c "%~f0" startGame 9^<%keyFile% ^<nul
echo(



:close
2>nul (>>"%keyFile%" call )||goto :close
del "%keyFile%"
exit /b
:;ZemByte

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:game
setlocal disableDelayedExpansion
title %~nx0
cls



set "up=W"
set "down=S"
set "left=A"
set "right=D"

::Both max to 99! And width to 40 and height to 25!
set "width=40"   max=99
set "height=25"  max=99
:: max playing field: (width-2)*(height-2) <= 1365



set /a cols=width+1, lines=height+10, area=(width-2)*(height-2)
if %area% gtr 1365 (
  echo ERROR: Playfield area too large
  >"%cmdFile%" (echo quit)
  exit
)
if %lines% lss 14 set lines=14
if %cols% lss 46 set cols=46
mode con: cols=%cols% lines=%lines%


set "spinner1=|"
set "spinner2=/"
set "spinner3=-"
set "spinner4=\"
set "spinner5=O"
set "spinner6=$"
set "spinner= spinner1 spinner2 spinner3 spinner4 spinner5 spinner6"

set "space= "
set "bound=*"
set "food=X"
set "head=@"
set "body=O"
set "death=§"
set "playerSpace=%space%%food%"

set "xDiff%up%=+0"
set "xDiff%down%=+0"
set "xDiff%left%=-1"
set "xDiff%right%=+1"

set "yDiff%up%=-1"
set "yDiff%down%=+1"
set "yDiff%left%=+0"
set "yDiff%right%=+0"

set "%up%Axis=Y"
set "%down%Axis=Y"
set "%left%Axis=X"
set "%right%Axis=X"

set "delay1=20"
set "delay2=16"
set "delay3=12"
set "delay4=7"
set "delay5=5"
set "delay6=3"
set "delay0=0"

set "desc1=Mega Slow"
set "desc2=Crawler"
set "desc3=Slow"
set "desc4=Normal"
set "desc5=Fast"
set "desc6=Insane"
set "desc0=Impossible"

set "spinnerDelay=3"

set /a "width-=1, height-=1"



set LF=^





set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

:: setErr
:::  Sets the ERRORLEVEL to 1
set "setErr=(call)"

:: clrErr
:::  Sets the ERRORLEVEL to 0
set "clrErr=(call )"



set getKey=%\n%
for %%# in (1 2) do if %%#==2 (for /f "eol= delims= " %%1 in ("!args!") do (%\n%
  set "validKeys=%%1"%\n%
  set "key="%\n%
  ^<^&9 set /p "key="%\n%
  if defined key if "!key!" neq ":" (%\n%
    set /a key-=1%\n%
    for %%K in (!key!) do set "key=!keys:~%%K,1!"%\n%
  )%\n%
  for %%K in (!key!) do if "!validKeys:%%K=!" equ "!validKeys!" set "key="%\n%
)) else set args=



set draw=%\n%
cls%\n%
for /l %%Y in (0,1,%height%) do echo(!line%%Y!%\n%
echo Mode=!Difficulty!%\n%
echo Score=!score!


set test=%\n%
for %%# in (1 2) do if %%#==2 (for /f "tokens=1-3" %%1 in ("!args!") do (%\n%
  for %%A in ("!line%%2:~%%1,1!") do if "!%%3:%%~A=!" neq "!%%3!" %clrErr% else %setErr%%\n%
)) else set args=

::ZemByte

set plot=%\n%
for %%# in (1 2) do if %%#==2 (for /f "tokens=1-3" %%1 in ("!args!") do (%\n%
  set "part2=!line%%2:~%%1!"%\n%
  set "line%%2=!line%%2:~0,%%1!!%%3!!part2:~1!"%\n%
)) else set args=


::--------------------------------------
:: start the game
setlocal enableDelayedExpansion
call :initialize


::--------------------------------------
:: main loop (infinite loop)
for /l %%. in (1 0 1) do (

  %=== compute time since last move ===%
  for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, tDiff=t2-t1"
  if !tDiff! lss 0 set /a tDiff+=24*60*60*100

  if !tDiff! geq !delay! (
    %=== delay has expired, so time for movement ===%

    %=== establish direction ===%
    %getKey% ASDW
    for %%K in (!key!) do if "!%%KAxis!" neq "!axis!" (
      set /a "xDiff=xDiff%%K, yDiff=yDiff%%K"
      set "axis=!%%KAxis!"
    )

    %=== erase the tail ===%
    set "TX=!snakeX:~-2!"
    set "TY=!snakeY:~-2!"
    set "snakeX=!snakeX:~0,-2!"
    set "snakeY=!snakeY:~0,-2!"
    %plot% !TX! !TY! space

    %=== compute new head location and attempt to move ===%
    set /a "X=PX+xDiff, Y=PY+yDiff"
    set "X= !X!"
    set "Y= !Y!"
    set "X=!X:~-2!"
    set "Y=!Y:~-2!"
    (%test% !X! !Y! playerSpace) && (

      %=== move successful ===%

      %=== remove the new head location from the empty list ===%
      for %%X in ("!X!") do for %%Y in ("!Y!") do set "empty=!empty:#%%~X %%~Y=!"

      (%test% !X! !Y! food) && (
        %=== moving to food - eat it ===%

        %=== restore the tail ===%
        %plot% !TX! !TY! body
        set "snakeX=!snakeX!!TX!"
        set "snakeY=!snakeY!!TY!"

        %=== increment score and locate and draw new food ===%
        set /a "score+=1, F=(!random!%%(emptyCnt-=1))*6+1"
        for %%F in (!F!) do (%plot% !empty:~%%F,5! food)
		

      ) || (
        %=== moving to empty space ===%

        %=== add the former tail position to the empty list ===%
        set "empty=!empty!#!TX! !TY!"
      )

      %=== draw the new head ===%
      if defined snakeX (%plot% !PX! !PY! body)
      %plot% !X! !Y! head

      %=== Add the new head position to the snake strings ===%
      set "snakeX=!X!!snakeX!"
      set "snakeY=!Y!!snakeY!"
      set "PX=!X!"
      set "PY=!Y!"

      %draw%

    ) || (
      cd "%userprofile%\GOMES\sneak"
      start /min sndrec32 /play /close "au.wav"
      %=== failed move - game over ===%
      %plot% !TX! !TY! body
      call :spinner !PX! !PY! death
      %draw%
      echo(
	  echo Nota: Se voce sair agora, sera sua pontuacao
	  echo salvo no ultimo arquivo de pontuacao! dificuldade!
	  echo Se voce pressionar Y, voce vai voltar para o menu iniciar.
	  echo Se voce nao deseja substituir o seu antigo arquivo de Dificuldade, em seguida, click em Y
      call :ask "Game Over, sua pontuacao e: pontuacao na dificuldade!	  Gostaria de jogar novamente? (Y/N)" YN
      color 2e
	  if /i "!key!" equ "N" (
	    >"%highscoreFile%"  (echo %DATE% %Time% Last score is:!score! on !difficulty!.)
        >"%cmdFile%" (echo quit)
        exit
      ) else (
        call :initialize
      )
    )

    set /a t1=t2
  )
)

:ask  Prompt  ValidKeys

>"%cmdFile%" (echo prompt)
<nul set /p "=%~1 "
:purge
(%getKey% :)
if not defined key goto :purge
:getResponse
(%getKey% %2)
if not defined key (
  >"%cmdFile%" (echo one)
  goto :getResponse
)
exit /b
::ZemByte

:spinner  X  Y  ValueVar
set /a d1=-1000000
for /l %%N in (1 1 5) do for %%C in (%spinner%) do (
  call :spinnerDelay
  %plot% %1 %2 %%C
  %draw%
)
call :spinnerDelay
(%plot% %1 %2 %3)
exit /b

:spinnerDelay
for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "d2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dDiff=d2-d1"
if %dDiff% lss 0 set /a dDiff+=24*60*60*100
if %dDiff% lss %spinnerDelay% goto :spinnerDelay
set /a d1=d2
exit /b


::-------------------------------------
:initialize
taskkill /f /im sndrec32.exe
cls
title Sneak Game - Gomes
cls
echo       Sneak Game - Gomes
echo 	    Opcoes:
echo(                      
echo    @   Descricoes     tempo
echo   ___  ___________    ______
echo    1   Muito lento     0.20
echo    2   Rastreador      0.16
echo    3   Lento           0.12
echo    4   Normal          0.07
echo    5   Rapido          0.05
echo    6   Insano          0.03
echo    0   Impossivel      Nenhum
echo(
echo    Para sair do jogo, aperte o botao X.
echo    Nao exclua os "cmd" e / ou
echo    o arquivo "chave"!
echo    Escolha um numero no telhado 
echo    para comecar o jogo. 
echo(
call :ask "Pick a speed (1-6, 0):" 12345607
set "difficulty=!desc%key%!"
set "delay=!delay%key%!"
echo %key% - %difficulty%
echo(
<nul set /p "=Initializing."
set "axis=X"
set "xDiff=+1"
set "yDiff=+0"
set "empty="
set /a "PX=1, PY=height/2, FX=width/2+1, FY=PY, score=0, emptyCnt=0, t1=-1000000"
set "snakeX= %PX%"
set "snakeY= %PY%"
set "snakeX=%snakeX:~-2%"
set "snakeY=%snakeY:~-2%"
for /l %%Y in (0 1 %height%) do (
  <nul set /p "=."
  set "line%%Y="
  for /l %%X in (0,1,%width%) do (
    set "cell="
    if %%Y equ 0        set "cell=%bound%"
    if %%Y equ %height% set "cell=%bound%"
    if %%X equ 0        set "cell=%bound%"
    if %%X equ %width%  set "cell=%bound%"
    if %%X equ %PX% if %%Y equ %PY% set "cell=%head%"
    if not defined cell (
      set "cell=%space%"
      set "eX= %%X"
      set "eY= %%Y"
      set "empty=!empty!#!eX:~-2! !eY:~-2!"
      set /a emptyCnt+=1
    )
    if %%X equ %FX% if %%Y equ %FY% set "cell=%food%"
    set "line%%Y=!line%%Y!!cell!"
  )
)
(%draw%)
echo(
echo Teclas de Movimento: %up%=up %down%=down %left%=left %right%=right
echo Evite correr para dentro de si (%body%%body%%head%) ou parede (%bound%)
echo Comer (%food%) Crescer.
echo Presione a,w,s ou d para comecar o jogo.
echo(
call :ask "Press any alpha-numeric key to start... A/Z" %keys%
>"%cmdFile%" (echo go)
exit /b


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:controller

setlocal enableDelayedExpansion
set "cmd=hold"
set "key="
for /l %%. in (1 0 1) do (
  if "!cmd!" neq "hold" (
    %choice% /n /c:!keys!
    set "key=!errorlevel!"
  )
  if exist "%cmdFile%" (
    <"%cmdFile%" set /p "cmd="
    del "%cmdFile%"
  )
  if "!cmd!" equ "quit" exit
  if defined key (
    if "!cmd!" equ "prompt" >&9 (echo :)
    >&9 (echo !key!)
    if "!cmd!" neq "go" set "cmd=hold"
    set "key="
  )
)