#include <windows.h>
#include <mmsystem.h>
#include <string>

#pragma comment(lib, "winmm.lib")

namespace  N {
    class VoiceRecording
    {
        public:
            bool isRecording = false;

            VoiceRecording();
            ~VoiceRecording();
            bool startRecording(std::string fileName);
            void stopRecording();
            bool isReady();
            bool play();
            bool saveFile();
            std::string _fileName;

        private:
        //	void(*callback)(WAVEHDR data);

            UINT wDeviceID;
            DWORD_PTR dwReturn;
            MCI_OPEN_PARMS mciOpenParms;
            MCI_RECORD_PARMS mciRecordParms;
            MCI_SAVE_PARMS mciSaveParms;
            MCI_PLAY_PARMS mciPlayParms;
            MCI_STATUS_PARMS parmStatus;
            
            bool prepareForRecording();
    };
}