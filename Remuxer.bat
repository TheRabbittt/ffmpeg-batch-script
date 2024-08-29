@echo off
mkdir edited

setlocal enabledelayedexpansion

set /p audio_tracks=Enter audio tracks to include and in the correct order, or press enter to skip: 
set /p subtitle_tracks=Enter subtitle tracks to include and in the correct order, or press enter to skip:

set audio_args=
set subtitle_args=
set audio_index=-1
set subtitle_index=-1

set audio_metadata_args=
set subtitle_metadata_args=

rem creates the mappings for audio streams
if not "%audio_tracks%"=="" (
	for %%a in (%audio_tracks%) do (
		set audio_index=-1
		set /A audio_index+=%%a
		set audio_args=!audio_args! -map 0:a:!audio_index!
	) 
)

rem creates the mappings for subtitle streams
if not "%subtitle_tracks%"=="" (
	for %%s in (%subtitle_tracks%) do (
		set subtitle_index=-1
		set /A subtitle_index+=%%s
		set subtitle_args=!subtitle_args! -map 0:s:!subtitle_index!
	) 
)

rem changes metadata of audio streams
for %%a in (%audio_tracks%) do (
	set audio_index=-1
	set /A audio_index+=%%a
    set /p metadata=Enter title for audio file %%a:
	if /I "!metadata:~0,3!" == "eng" (
		set audio_metadata_args=!audio_metadata_args! -metadata:s:a:!audio_index! title="!metadata!" -metadata:s:a:!audio_index! language="eng"
	) else if /I "!metadata:~0,3!" == "jap" (
		set audio_metadata_args=!audio_metadata_args! -metadata:s:a:!audio_index! title="!metadata!" -metadata:s:a:!audio_index! language="jpn"
	) else (
		set /p language=Enter language code for audio file %%a, e.g eng,jpn:
		set audio_metadata_args=!audio_metadata_args! -metadata:s:a:!audio_index! title="!metadata!" -metadata:s:a:!audio_index! language="!language!"
	)
)

rem changes metadata of subtitle streams
for %%s in (%subtitle_tracks%) do (
	set subtitle_index=-1
	set /A subtitle_index+=%%s
    set /p metadata=Enter title for subtitle file %%s:
	if /I "!metadata:~0,3%!" == "eng" (
	    set subtitle_metadata_args=!subtitle_metadata_args! -metadata:s:s:!subtitle_index! title="!metadata!" -metadata:s:s:!subtitle_index! language="eng"
	) else (
		set /p language=Enter language code for subtitle file %%s, e.g eng,jpn:
		set subtitle_metadata_args=!subtitle_metadata_args! -metadata:s:s:!subtitle_index! title="!metadata!" -metadata:s:s:!subtitle_index! language="!language!"
	)
)

rem runs ffmpeg encoding with the configured settings
for %%i in (*.m4a *.mp4 *.mkv *.avi *.mov *.ts) DO (
    ffmpeg -i "%%i" -map 0:0 -c:v copy %audio_args% %audio_metadata_args% -c:a flac %subtitle_args% %subtitle_metadata_args% -c:s copy "edited\%%~ni_edited.%%~xi"
)

pause


rem FOR %i IN (*.mp4) DO ffmpeg -i "%i" -map 0:v -c:v copy -map 0:a -c:a:0 ac3 -map 0:a -c:a:1 copy "%%~ni_.mkv"

rem --sync 3:500

rem -map 0:t for attachtment, script wont work if (maybe) attachments dont exist in file.