# YouTube Video Downloader - Batch Script

Yeh ek powerful Windows batch script hai jo YouTube se videos ko automatically download karta hai [4]. Script yt-dlp aur FFmpeg ka use karke high-quality videos (720p) download karta hai [5].

## ✨ Features

- **Automatic Setup**: Pehli baar chalane par yt-dlp aur FFmpeg automatically download ho jate hain
- **Batch Downloads**: `links.txt` file mein multiple URLs add karke ek saath kai videos download kar sakte hain
- **720p Quality**: Default 720p MP4 format mein videos download hoti hain
- **Playlist Support**: YouTube playlists ko bhi download kar sakta hai
- **Admin Privileges**: Automatically administrator rights request karta hai
- **Error Handling**: Failed downloads ko handle karta hai aur retry karta hai

## 📋 Requirements

- Windows OS (7/8/10/11)
- Internet connection
- PowerShell enabled (Windows mein by default hota hai)

## 🚀 Installation

1. Ek naya folder banayein (jaise: `C:\YouTube_Downloader`)
2. Is folder mein `youtube-downloader.bat` naam se script file banayein
3. Script code ko copy-paste karein
4. Same folder mein `links.txt` naam ki ek text file banayein

## 📝 Usage

### Step 1: Links Add Karna

`links.txt` file ko text editor mein open karein aur har line mein ek YouTube URL daalein:

```
https://www.youtube.com/watch?v=VIDEO_ID_1
https://www.youtube.com/watch?v=VIDEO_ID_2
https://www.youtube.com/playlist?list=PLAYLIST_ID
```

### Step 2: Script Chalana

`youtube-downloader.bat` file par double-click karein. Script automatically:
- Admin privileges request karega
- Zaruri tools (yt-dlp, FFmpeg) download karega (pehli baar)
- `links.txt` se saari videos download karega

### Step 3: Downloaded Videos

Download hone ke baad videos yahan milenge:
```
YouTube_Downloader/
├── videos/          ← Downloaded videos yahan save hoti hain
├── audios/          ← Future audio downloads ke liye
├── bin/             ← yt-dlp aur FFmpeg tools
├── links.txt        ← Aapki YouTube URLs
└── youtube-downloader.bat
```

## 🎯 Advanced Features

### Different Quality Download

Script mein `set "format="` line ko modify karke quality change kar sakte hain:

- **1080p**: `bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080]`
- **480p**: `bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480]`
- **Best Available**: `bestvideo+bestaudio/best`

### Audio-Only Download

Videos folder ke bajay audios folder use karne ke liye:
```batch
set "folder=audios"
set "format=bestaudio[ext=m4a]/bestaudio"
```

## ⚠️ Troubleshooting

### Error: links.txt not found
- Check karein ki `links.txt` file script ke same folder mein hai
- File ka naam exactly `links.txt` hona chahiye (extension hidden na ho)

### Download Failed
- Internet connection check karein
- YouTube URL valid hai ya nahi verify karein
- Antivirus temporarily disable karke try karein

### Admin Rights Error
- Script par right-click karke "Run as Administrator" select karein

## 🔧 Technical Details

**Tools Used:**
- **yt-dlp**: Latest YouTube downloader tool [4]
- **FFmpeg**: Video/audio processing ke liye

**Key Parameters:**
- `--concurrent-fragments 3`: Fast download ke liye 3 fragments parallel download hote hain
- `--retries 3`: Failed downloads ko 3 baar retry karta hai
- `--windows-filenames`: Windows-compatible filenames create karta hai
- `--ignore-errors`: Ek video fail hone par bhi baaki videos download hoti rahti hain

## 📜 License

Is script ko free use kar sakte hain. Modifications aur redistribution allowed hai [2].

## ⚡ Tips

- Large playlists download karte waqt disk space ka dhyan rakhein
- Slow internet par quality kam rakhein (480p ya 360p)
- Multiple URLs ek saath download karne se time bachta hai
- Regular updates ke liye `bin` folder delete karke script phir se chalayein

## 🤝 Contributing

Script mein improvements ya bug fixes ke liye suggestions welcome hain [6].

***

**Note**: YouTube ki Terms of Service ka palan karein. Copyrighted content download karne ke pehle permission zaruri hai.

