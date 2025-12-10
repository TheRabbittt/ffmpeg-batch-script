@echo off
setlocal enabledelayedexpansion
set DEBUG=1

:: Create output directory
mkdir "edited" 2>nul

echo ================================================
echo        Audio & Subtitle Track Organizer
echo ================================================
echo.

:: Prompt user for audio tracks
set /p audio_tracks=Enter the audio track numbers to include (e.g., "1 2") or press Enter to skip: 

:: Prompt user for subtitle tracks
set /p subtitle_tracks=Enter the subtitle track numbers to include (e.g., "1 2") or press Enter to skip: 

:: Initialize variables
set audio_args=
set subtitle_args=
set audio_index=-1
set subtitle_index=-1
set audio_metadata_args=
set subtitle_metadata_args=
set audio_codec_args=
set out_audio_index=0
set out_subtitle_index=0

:: -------- Process Audio Tracks --------
if not "%audio_tracks%"=="" (
    echo.
    echo Processing audio tracks...
    for %%a in (%audio_tracks%) do (
        set /A audio_index=-1
		set /A audio_index+=%%a
        set audio_args=!audio_args! -map 0:a:!audio_index!

        :: Ask user about conversion
        set /p choice=Convert audio track %%a to FLAC? y/N: 
        if /I "!choice!"=="Y" (
            set audio_codec_args=!audio_codec_args! -c:a:!out_audio_index! flac
        ) else (
            set audio_codec_args=!audio_codec_args! -c:a:!out_audio_index! copy
        )

        :: Get audio metadata
        set /p metadata=Enter the title for audio track %%a: 
        set code=
        if /I "!metadata:~0,3!"=="Eng" set code=eng
        if /I "!metadata:~0,3!"=="Jap" set code=jpn
        if not defined code (
            set /p code=Enter language code for audio track %%a: 
        )
        set audio_metadata_args=!audio_metadata_args! -metadata:s:a:!out_audio_index! title="!metadata!" -metadata:s:a:!out_audio_index! language="!code!"

        set /A out_audio_index+=1
    )
)

:: -------- Process Subtitle Tracks --------
if not "%subtitle_tracks%"=="" (
    echo.
    echo Processing subtitle tracks...
    for %%s in (%subtitle_tracks%) do (
        set subtitle_index=-1
        set /A subtitle_index+=%%s
        set subtitle_args=!subtitle_args! -map 0:s:!subtitle_index!

        :: Get subtitle metadata
        set /p metadata=Enter the title for subtitle track %%s: 
        set code=
        if /I "!metadata:~0,3!"=="eng" set code=eng
        if /I "!metadata:~0,3!"=="jap" set code=jpn
        if not defined code (
            set /p code=Enter language code for subtitle track %%s: 
        )
        set subtitle_metadata_args=!subtitle_metadata_args! -metadata:s:s:!out_subtitle_index! title="!metadata!" -metadata:s:s:!out_subtitle_index! language="!code!"

        set /A out_subtitle_index+=1
    )
)

:: -------- Start Processing Files --------
echo.
echo ================================================
echo       Starting file processing with ffmpeg
echo ================================================
echo.

for %%i in (*.m4a *.mp4 *.mkv *.avi *.mov *.ts) DO (
    echo Processing "%%i" ...
    ffmpeg -i "%%i" -map 0:0 -c:v copy %audio_args% %audio_codec_args% %audio_metadata_args% %subtitle_args% %subtitle_metadata_args% -c:s copy "edited\%%~ni_edited%%~xi"
    echo "%%i" done.
    echo.
)

echo ================================================
echo             All files have been processed
echo ================================================
pause
