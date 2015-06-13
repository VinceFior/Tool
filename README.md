# Tool
My personal utility for important tasks like opening reaction .gifs and music videos. 
I'll come up with a better name later. 


This multi-purpose tool has a number of distinct commands, listed below. My favorites are "gif" and "ytmusic".
While most of these commands are silly or small, I hope to add more meaningful commands 
so the tool becomes more like a miniature digital assistant.


## How to install

Move the `Tool.app` file to your Applications folder. 
To run the application, you have to go to System Preferences > Security & Privacy > General and allow apps downloaded from anywhere.
You can open the Tool by clicking on the gear icon in the menu bar or by pressing `CMD`+`\`. 
However, to use the keyboard shortcut you need to give the application accessibility permissions. 
Go to System Preferences > Security & Privacy > Privacy > Accessibility and add `Tool.app` 
under "Allow the apps below to control your computer".

### How to configure

Use the `config` command to open your Tool settings folder. The placeholder files show what information you'll want to add.
If you're curious what my configuration files look like, feel free to send me a message.

## Commands

`settings` or `config` to open settings folder

`gif <keyword>` to copy the URL of a reaction image, like "gif nope"

`list gif` to list all reaction images

`getalbum <album ID>` to generate a list of reaction images for the given album

`updatealbum` to update the image-database.txt file

`dict <word>` to open Dictionary.com to the given word

`xkcd <keyword>` to open the first xkcd.com result for the given keyword

`ytmusic <keyword>` to open the first matching video on my YouTube 'Music' playlist

`youtube <keyword>` to search YouTube for the given keyword

`music <keyword>` to search my Google Play Music library for the given keyword

`google <keyword>` to search Google for the given keyword

`school <class>` to open the folder for my given class in Finder

`syl <class>` to open the syllabus for my given class in Finder


### Notes

To use all the commands, you need an API key for Imgur and for YouTube. Both can be obtained for free.
