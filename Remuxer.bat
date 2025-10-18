@echo off
mkdir edited

setlocal enabledelayedexpansion

:: Prompt user for audio tracks input
set /p audio_tracks=Enter the audio track indices you want to include (e.g., "1 2") in the desired order, or press Enter to skip: 
:: Prompt user for subtitle tracks input
set /p subtitle_tracks=Enter the subtitle track indices you want to include (e.g., "1 2") in the desired order, or press Enter to skip:

set audio_args=
set subtitle_args=
set audio_index=-1
set subtitle_index=-1

set audio_metadata_args=
set subtitle_metadata_args=
set audio_codec_args=

set out_audio_index=0
set out_subtitle_index=0

:: Process audio tracks and create mappings
if not "%audio_tracks%"=="" (
    for %%a in (%audio_tracks%) do (
        set audio_index=-1
        set /A audio_index+=%%a
        set audio_args=!audio_args! -map 0:a:!audio_index!

        :: Ask user whether to convert this audio track or keep original
        set choice=
        set /p choice=Do you want to convert audio track %%a to FLAC?: 
        if /I "!choice!"=="N" (
            set audio_codec_args=!audio_codec_args! -c:a:!out_audio_index! copy
        ) else (
            set audio_codec_args=!audio_codec_args! -c:a:!out_audio_index! flac
        )

        :: Prompt user for audio track metadata
        set /p metadata=Enter the title for audio track %%a: 
        set code=
        if /I "!metadata:~0,3!"=="Eng" (set code=eng)
        if /I "!metadata:~0,3!"=="Jap" (set code=jpn)
        if not defined code (
            set /p code=Enter the language code for audio track %%a:
        )
        set audio_metadata_args=!audio_metadata_args! -metadata:s:a:!out_audio_index! title="!metadata!" -metadata:s:a:!out_audio_index! language="!code!"

        set /a out_audio_index+=1
    )
)

:: Process subtitle tracks and create mappings
if not "%subtitle_tracks%"=="" (
    for %%s in (%subtitle_tracks%) do (
        set subtitle_index=-1
        set /A subtitle_index+=%%s
        set subtitle_args=!subtitle_args! -map 0:s:!subtitle_index!

        :: Prompt user for subtitle track metadata
        set /p metadata=Enter the title for subtitle track %%s: 
        set code=
        if /I "!metadata:~0,3!"=="eng" (set code=eng)
        if /I "!metadata:~0,3!"=="jap" (set code=jpn)
        if not defined code (
            set /p code=Enter the language code for subtitle track %%s:
        )
        set subtitle_metadata_args=!subtitle_metadata_args! -metadata:s:s:!out_subtitle_index! title="!metadata!" -metadata:s:s:!out_subtitle_index! language="!code!"

        set /a out_subtitle_index+=1
    )
)

:: Run ffmpeg command to process files
for %%i in (*.m4a *.mp4 *.mkv *.avi *.mov *.ts) DO (
    ffmpeg -i "%%i" -map 0:0 -c:v copy %audio_args% %audio_codec_args% %audio_metadata_args% %subtitle_args% %subtitle_metadata_args% -c:s copy "edited\%%~ni_edited%%~xi"
)

pause
