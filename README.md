# FCAS
 Flashjacks Cassette Loader

First:
sjasm.exe FCAS.asm FCAS.COM


Sources:

https://retromsx.com


This device synthesizes a cassette deck. 

For all intents and purposes we obtain its real analog signal from a .CAS file, being able to configure the system without consuming MSX resources and therefore obtain maximum compatibility in 64k MSX1 environments.

The system is compatible with all MSX that have a Cassette input. It also has a bus signal injection system but only those that have the Busdir signal enabled in the slot (NMS8250 and some other) are compatible.

The application that configures this accessory is called FCAS.COM

This program has help parameters and author's notes so you can view all the help discussed here. The text format is oriented to be viewed on a 40 character MSX1.

This is your command:

FCAS casfile.cas /options

We are going to discuss the possible options.
/N /D /T /F : Here we select the baud rate. It ranges from 1200, 2400, 3000 and 3600 respectively with 1200bps being the default speed.
/B : Bypass function. This function does not require a file as it takes the data from the audio input of the Flashjacks from a real Cassette. In addition, it performs the bypass function where it synthesizes the source wave and extracts a recovered and enhanced wave through the audio output. Come on, it is redigitalized at the cassette data level and resynthesized again.
/I : Apart from the audio output, it reintegrates the data by sending it through the MSX bus. This only works on MSX that have the Busdir operating with a bidirectional buffer (what the MSX standard said). Unfortunately only a few MSX carry it (Ex: NMS8250) so if it does not load you with this option without an analog cable, then you will have to make use of it and discard this option.
/R : With this option we leave the MSX in a clean environment, without interference with the FJ. It disables all the expansions, especially the RAM, leaving the MSX with its basic Basic functions. This is due to the poor compatibility of cassette programs and games with RAM expansions. Remember to put their corresponding POKEs on the MSX2, as we did in the past. Without this option we will be able to run in Basic with all the functionalities of the FJ but with the limitations of its original Cassette programs. We can also remove the RAM from the bootmenu and enter without this command for greater compatibility but this option is not viable in 64k MSX, so this function allows the loading of MSXDOS with the RAM expansion of the FJ and then with this function , once loaded the .CAS, leave us a clean environment in 64k.
/H : Author's notes. Enter if you want to know more about ...
 
Otherwise comment on several things.

It is linked to the multimente with simple configuration (1200bps and reset. The most compatible). You can change this at your discretion in the MMRET.DAT.

As for the cassette cable, remember that the Jack of the cables is usually mono and the Jack of the Flashjacks is stereo. This can create incompatibilities. 

Theirs is to put a stereo Jack and wire only the left channel (left, the one on the top).

The audio level of the cassette can be adjusted in the bootmenu, where it says EXT out. It is at level 1 (low) where most MSX accept it. 

You can go up to level 3 if your MSX doesn't catch it. Higher is not better, it could saturate the signal and have no reading. This regulation applies in the same way when we have not used the FCAS function since its function without CAS is to reproduce the line input at 48kHz as the Flashjacks did initially.

On the subject of baud rates. 1200bps is the most compatible and 3600bps the least compatible. 

Most MSX1 only accept 1200bps while most MSX2 support 2400bps. 

Through internal data bus, I have managed to upload at 3600bps but it is not always compatible. 

2400 bps is the famous fast loading that some cassettes had.

Finally, when we are already in BASIC, comment that the system is intelligent. 

As soon as we put the usual load command, the Flashjacks will detect the activation of the Motor and it will begin to emit data in analogue. 

It has auto rewind at the end of the cassette and when interrupting the process in the middle of a data emission.
Another thing is the one indicated by the red led when it is broadcasting cassette data. These flashes indicate cassette data transfer and their flashing indicates the number of bytes transferred. 

Each full blink means that you have transferred 256 bytes.

Little more to say about this functionality. 

With the ability to play this format, Flashjacks adds an additional file type that it can run. 

It not only runs ROMs, DSKs and Nextor, but also .CAS, adding to all that catalog of games on tapes that we had on MSX1.
