// This must be included before many other Windows headers.
#include <windows.h>
#include "voiceRecording.h"
#include <mmsystem.h>
#include <sstream>
#include <string>
#include<iostream>

using namespace N;
using namespace std;

VoiceRecording::VoiceRecording() {}

VoiceRecording::~VoiceRecording() {}

bool VoiceRecording::play() {
	dwReturn = 1;
	dwReturn = mciSendCommand(wDeviceID, MCI_PLAY,
	MCI_FROM | MCI_WAIT, (DWORD_PTR) &mciPlayParms);
	if (dwReturn == 0)
	{
		return true;
	}
	mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
	return false;
}

void VoiceRecording::stopRecording() {
	if(saveFile()) {
		isRecording = false;
	}
}

bool VoiceRecording::saveFile() {
	// Save the recording to a file named TEMPFILE.WAV. Wait for
	// the operation to complete before continuing.
	std::wstring stemp = wstring(_fileName.begin(), _fileName.end());
	LPCWSTR sw = stemp.c_str();
	mciSaveParms.lpfilename = sw;
	wcout << sw;
	dwReturn = 1;
	dwReturn = mciSendCommand(wDeviceID, MCI_SAVE,
		MCI_SAVE_FILE | MCI_WAIT, (DWORD_PTR) &mciSaveParms);
	if(dwReturn == 0)
	{
		mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
		return (true);
	}
	mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
	return (false);
}

bool VoiceRecording::prepareForRecording() {
	
	// Open a waveform-audio device with a new file for recording.
	mciOpenParms.lpstrDeviceType = L"waveaudio";
	mciOpenParms.lpstrElementName = L"";
	dwReturn = 1;
	dwReturn = mciSendCommand(0, MCI_OPEN,
		MCI_OPEN_ELEMENT | MCI_OPEN_TYPE, 
		(DWORD_PTR) &mciOpenParms);
	if (dwReturn == 0)
	{
		// The device opened successfully; get the device ID.
		wDeviceID = mciOpenParms.wDeviceID;
		return true;
	}
	// Failed to open device; don't close it, just return error.
	mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
	return false;

}

bool N::VoiceRecording::startRecording(string fileName) {
	if(VoiceRecording::prepareForRecording()) {
		// Begin recording and record for the specified number of 
		// milliseconds. Wait for recording to complete before continuing. 
		// Assume the default time format for the waveform-audio device 
		// (milliseconds).
		dwReturn = 1;
		dwReturn = mciSendCommand(wDeviceID, MCI_RECORD, 
			0, (DWORD_PTR) &mciRecordParms);
		if (dwReturn == 0)
		{
			_fileName = fileName;
			isRecording = true;
			return true;
		}
	}
	mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
	return false;
}