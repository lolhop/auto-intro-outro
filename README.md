# auto-intro-outro

A program to batch overlay a transparent intro and outro to videos. Optimized for M1 Pro, easy to change to be optimized with your system.

## How to use

1. Install ffmpeg (`brew install ffmpeg`).
2. Create the file structure below (intro and outro files must be .mov with alpha).

![CleanShot 2025-04-21 at 12 02 39@2x](https://github.com/user-attachments/assets/15884929-ab7e-47a2-8c58-48ef7d529b92)

3. Put all videos you want edited in the input folder.
4. Copy the path where the script is placed, and run these two commands:

```bash
chmod +x /your/folder/structure/add_intro_outro.sh
/your/folder/structure/add_intro_outro.sh
```
