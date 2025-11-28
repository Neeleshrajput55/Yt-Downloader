#!/data/data/com.termux/files/usr/bin/bash

# Termux-specific script for downloading videos using yt-dlp
# Features: External storage + Quality selection + Credit Banner + Termux URL Handler

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display banner
show_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}${MAGENTA}YouTube Video Downloader Pro${NC}                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Developer:${NC} Pummy Rajput / GitHub: @Neeleshrajput55         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Version:${NC} 2.0 | ${GREEN}Powered by:${NC} yt-dlp                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to show status banner during download
show_status_banner() {
    local current=$1
    local total=$2
    local success=$3
    local failed=$4

    echo ""
    echo -e "${BLUE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Progress:${NC} [$current/$total] | ${GREEN}✓ $success${NC} | ${RED}✗ $failed${NC}                 ${BLUE}│${NC}"
    echo -e "${BLUE}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Set external storage path
EXTERNAL_STORAGE="/sdcard/YouTube"
SCRIPT_DIR="$(dirname "$0")"

# Show initial banner
show_banner

# Check if storage permission is granted
if [ ! -d "/sdcard" ]; then
    echo -e "${RED}Error: Storage permission not granted!${NC}"
    echo "Please run: termux-setup-storage"
    read -p "Press enter to exit..."
    exit 1
fi

# Create YouTube directory in external storage
mkdir -p "$EXTERNAL_STORAGE"/{videos,audios,playlists}

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}yt-dlp not found. Installing...${NC}"
    pkg update -y
    pkg install -y python ffmpeg
    pip install -U yt-dlp
    echo -e "${GREEN}Installation complete!${NC}"
    sleep 2
    show_banner
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}FFmpeg not found. Installing...${NC}"
    pkg install -y ffmpeg
    sleep 2
    show_banner
fi

# Check if URL was passed as argument (from share menu)
SHARED_URL=""
if [ -n "$1" ]; then
    SHARED_URL="$1"
    echo -e "${GREEN}${BOLD}ðŸ“± Shared URL detected!${NC}"
    echo -e "${CYAN}URL: ${YELLOW}$SHARED_URL${NC}"
    echo ""
fi

# Download mode selection
echo -e "${BLUE}${BOLD}Select download mode:${NC}"
echo ""
if [ -n "$SHARED_URL" ]; then
    echo -e "  ${CYAN}1)${NC} Download shared URL ${GREEN}[Quick]${NC}"
    echo -e "  ${CYAN}2)${NC} Download from links.txt"
    echo -e "  ${CYAN}3)${NC} Add shared URL to links.txt and download later"
else
    echo -e "  ${CYAN}1)${NC} Download from links.txt"
    echo -e "  ${CYAN}2)${NC} Enter URL manually"
fi
echo ""
read -p "Enter your choice: " mode_choice

# Handle mode selection
download_mode=""
manual_url=""

if [ -n "$SHARED_URL" ]; then
    case $mode_choice in
        1)
            download_mode="shared"
            ;;
        2)
            download_mode="file"
            ;;
        3)
            # Add to links.txt
            echo "$SHARED_URL" >> "$SCRIPT_DIR/links.txt"
            echo -e "${GREEN}âœ“ URL added to links.txt${NC}"
            echo -e "${YELLOW}Run script again to download from links.txt${NC}"
            read -p "Press enter to exit..."
            exit 0
            ;;
        *)
            download_mode="shared"
            ;;
    esac
else
    case $mode_choice in
        1)
            download_mode="file"
            ;;
        2)
            download_mode="manual"
            echo ""
            read -p "Enter video URL: " manual_url
            if [ -z "$manual_url" ]; then
                echo -e "${RED}No URL provided. Exiting...${NC}"
                exit 1
            fi
            ;;
        *)
            download_mode="file"
            ;;
    esac
fi

# Check if links.txt exists when needed
if [ "$download_mode" = "file" ]; then
    if [ ! -f "$SCRIPT_DIR/links.txt" ]; then
        echo -e "${RED}Error: links.txt not found!${NC}"
        echo "Creating example links.txt..."
        cat > "$SCRIPT_DIR/links.txt" << 'EOF'
# Add your video URLs here (one per line)
# Lines starting with # are comments

# Example:
# https://www.youtube.com/watch?v=dQw4w9WgXcQ
EOF
        echo -e "${YELLOW}Please add URLs to: $SCRIPT_DIR/links.txt${NC}"
        read -p "Press enter to exit..."
        exit 1
    fi

    # Check if file is empty or only has comments
    if ! grep -qvE "^[[:space:]]*#|^[[:space:]]*$" "$SCRIPT_DIR/links.txt"; then
        echo -e "${RED}Error: links.txt is empty or contains only comments!${NC}"
        echo -e "${YELLOW}Please add URLs to: $SCRIPT_DIR/links.txt${NC}"
        read -p "Press enter to exit..."
        exit 1
    fi
fi

show_banner

# Quality selection menu
echo -e "${BLUE}${BOLD}Select video quality:${NC}"
echo ""
echo -e "  ${CYAN}1)${NC}  144p  (Low quality, smallest size)"
echo -e "  ${CYAN}2)${NC}  240p  (Low quality)"
echo -e "  ${CYAN}3)${NC}  360p  (Medium quality)"
echo -e "  ${CYAN}4)${NC}  480p  (SD quality)"
echo -e "  ${CYAN}5)${NC}  720p  (HD quality) ${GREEN}[Recommended]${NC}"
echo -e "  ${CYAN}6)${NC}  1080p (Full HD quality)"
echo -e "  ${CYAN}7)${NC}  1440p (2K quality)"
echo -e "  ${CYAN}8)${NC}  2160p (4K quality)"
echo -e "  ${CYAN}9)${NC}  Best available quality"
echo -e "  ${CYAN}10)${NC} Audio only (MP3)"
echo ""
read -p "Enter your choice (1-10): " quality_choice

# Set format based on user choice
case $quality_choice in
    1)
        format="bestvideo[height<=144][ext=mp4]+bestaudio[ext=m4a]/best[height<=144]"
        quality_label="144p"
        folder="$EXTERNAL_STORAGE/videos/144p"
        ;;
    2)
        format="bestvideo[height<=240][ext=mp4]+bestaudio[ext=m4a]/best[height<=240]"
        quality_label="240p"
        folder="$EXTERNAL_STORAGE/videos/240p"
        ;;
    3)
        format="bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]/best[height<=360]"
        quality_label="360p"
        folder="$EXTERNAL_STORAGE/videos/360p"
        ;;
    4)
        format="bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/best[height<=480]"
        quality_label="480p"
        folder="$EXTERNAL_STORAGE/videos/480p"
        ;;
    5)
        format="bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720]"
        quality_label="720p"
        folder="$EXTERNAL_STORAGE/videos/720p"
        ;;
    6)
        format="bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080]"
        quality_label="1080p"
        folder="$EXTERNAL_STORAGE/videos/1080p"
        ;;
    7)
        format="bestvideo[height<=1440][ext=mp4]+bestaudio[ext=m4a]/best[height<=1440]"
        quality_label="1440p"
        folder="$EXTERNAL_STORAGE/videos/1440p"
        ;;
    8)
        format="bestvideo[height<=2160][ext=mp4]+bestaudio[ext=m4a]/best[height<=2160]"
        quality_label="2160p"
        folder="$EXTERNAL_STORAGE/videos/2160p"
        ;;
    9)
        format="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best"
        quality_label="Best"
        folder="$EXTERNAL_STORAGE/videos/best_quality"
        ;;
    10)
        format="bestaudio[ext=m4a]/bestaudio"
        quality_label="Audio Only"
        folder="$EXTERNAL_STORAGE/audios"
        output_ext="mp3"
        ;;
    *)
        echo -e "${RED}Invalid choice! Using default 720p${NC}"
        format="bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720]"
        quality_label="720p"
        folder="$EXTERNAL_STORAGE/videos/720p"
        sleep 2
        ;;
esac

# Create quality-specific folder
mkdir -p "$folder"

# Set output template
if [ "$quality_choice" = "10" ]; then
    output_template="%(channel,uploader)s/%(title)s.%(ext)s"
else
    output_template="%(channel,uploader)s/%(title)s.mp4"
fi

# Additional yt-dlp options for audio
if [ "$quality_choice" = "10" ]; then
    extra_opts="--extract-audio --audio-format mp3 --audio-quality 0"
else
    extra_opts="--merge-output-format mp4"
fi

# Clear screen and show banner with settings
show_banner
echo -e "${GREEN}${BOLD}Selected Configuration:${NC}"
echo -e "  Mode: ${YELLOW}$([ "$download_mode" = "shared" ] && echo "Shared URL" || ([ "$download_mode" = "manual" ] && echo "Manual URL" || echo "From links.txt"))${NC}"
echo -e "  Quality: ${YELLOW}$quality_label${NC}"
echo -e "  Location: ${YELLOW}$folder${NC}"
echo ""

# Counter for statistics
total_count=0
success_count=0
fail_count=0

# Function to download a single URL
download_url() {
    local url="$1"

    ((total_count++))

    # Clear and show banner with status
    show_banner
    show_status_banner "$total_count" "$([[ "$download_mode" == "file" ]] && echo "?" || echo "1")" "$success_count" "$fail_count"

    echo -e "${YELLOW}Processing URL:${NC} $url"
    echo ""

    # Run yt-dlp
    if yt-dlp         --no-update         --ignore-errors         --no-warnings         $extra_opts         --format "$format"         --output "$folder/$output_template"         --no-playlist-reverse         --concurrent-fragments 3         --retries 3         --restrict-filenames         --add-metadata         --embed-thumbnail         --progress         "$url"; then
        ((success_count++))
        echo ""
        echo -e "${GREEN}${BOLD}âœ“ Download successful!${NC}"
    else
        ((fail_count++))
        echo ""
        echo -e "${RED}${BOLD}âœ— Download failed!${NC}"
    fi

    sleep 2
}

# Download based on mode
if [ "$download_mode" = "shared" ]; then
    # Download shared URL
    download_url "$SHARED_URL"
elif [ "$download_mode" = "manual" ]; then
    # Download manually entered URL
    download_url "$manual_url"
else
    # Download from links.txt
    while IFS= read -r video_url || [ -n "$video_url" ]; do
        # Skip empty lines and comments
        [ -z "$video_url" ] && continue
        [[ "$video_url" =~ ^#.* ]] && continue

        download_url "$video_url"
    done < "$SCRIPT_DIR/links.txt"
fi

# Final summary with banner
show_banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}${GREEN}Download Summary${NC}                                          ${BLUE}║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║${NC}  Total URLs processed:     ${YELLOW}${BOLD}%-28s${NC} ${BLUE}║${NC}" "$total_count"
echo -e "${BLUE}║${NC}  Successfully downloaded:  ${GREEN}${BOLD}%-28s${NC} ${BLUE}║${NC}" "$success_count"
echo -e "${BLUE}║${NC}  Failed downloads:         ${RED}${BOLD}%-28s${NC} ${BLUE}║${NC}" "$fail_count"
echo -e "${BLUE}║${NC}  Saved in:                 %-28s ${BLUE}║${NC}" "$(basename "$folder")"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}${BOLD}All downloads completed!${NC}"
echo -e "${CYAN}Location: ${YELLOW}$folder${NC}"
echo ""

# Option to open folder
read -p "Open download folder? (y/n): " open_folder
if [[ "$open_folder" =~ ^[Yy]$ ]]; then
    termux-open "$folder"
fi

# Show final credit
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}Thank you for using YouTube Video Downloader Pro!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press enter to exit..."

यहाँ आपके फाइनल प्रोजेक्ट के लिए एक शानदार, साफ और पूरी तरह हिंदी-समझाने वाला README.md तैयार किया गया है—हर feature के साथ, "क्यों और कैसे", step-by-step instructions और highlights मौजूद है:

***

# 🎬 YouTube Video Downloader Pro (Termux Bash)

> **Developer:** Pummy Rajput  
> **GitHub:** [@Neeleshrajput55](https://github.com/Neeleshrajput55)  
> **Version:** 2.1  
> **Engine:** yt-dlp  
>  
> एक ultimate Termux Bash स्क्रिप्ट, जिससे आप YouTube (या अन्य supported websites) से high-speed और automated तरीके से videos और audios अपने Android मोबाइल की external storage (`/sdcard/YouTube`) में save कर सकते हैं।

***

## ⭐ इस प्रोजेक्ट की खासियत

- **YouTube App से डायरेक्ट Download**: Share से Termux चुनते ही video डाउनलोड।
- **Batch Download**: links.txt में दर्ज कई videos/playlist/channel लिंक को एक साथ डाउनलोड करें।
- **Manual URL Mode**: किसी भी लिंक को सीधे paste करके डाउनलोड करें।
- **Quality Selection**: 144p से 4K (2160p) तक video या केवल audio (MP3) डाउनलोड करें।
- **External Storage Save**: `/sdcard/YouTube` में organized folders (quality/channel/others) में सेविंग।
- **Beautiful Banner & Stats**: Download progress और summary professional look में।
- **No Root Needed**: सिर्फ Termux और permissions।
- **Auto Dependency Install**: yt-dlp, ffmpeg, python खुद install हो जाते हैं।
- **Hinglish + English**: Instructions universal—आप कहीं से भी चला सकते हैं!

***

## 📦 इंस्टॉलेशन (Installation)

### 1. **Termux Install करें**
- F-Droid से [Latest Termux](https://f-droid.org/en/packages/com.termux/) डाउनलोड करें (Play Store से नहीं!)
- Storage Permission दें:  
  ```bash
  termux-setup-storage
  ```

### 2. **स्क्रिप्ट सेव करें और executable बनाएं**

```bash
cp download_videos_termux_v2.1_fixed.sh ~/download_videos.sh
chmod +x ~/download_videos.sh
```

### 3. **अगर YouTube से "Share" Menu से डाउनलोड चाहते हैं:**

- `~/bin/termux-url-opener` फाइल बनाइए और उसमें ये लाइन डालिए:
  ```bash
  #!/data/data/com.termux/files/usr/bin/bash
  bash ~/download_videos.sh \"$1\"
  ```
- Executable बनाईये:
  ```bash
  mkdir -p ~/bin
  chmod +x ~/bin/termux-url-opener
  ```
- अब YouTube ऐप में कोई video -> Share -> Termux पर tap करें

***

## ⚡ इस्तेमाल कैसे करें (Usage)

### (A) **Direct Share (YouTube App से)**
- वीडियो पर Share → Termux → Quality चुनें → डाउनलोड शुरू

### (B) **Batch Mode (links.txt फाइल से)**
1. `nano links.txt` चलाकर हर line पर एक-एक लिंक लिखें।
2. स्क्रिप्ट चलाएँ:
   ```bash
   ~/download_videos.sh
   ```
3. Download mode में "Download from links.txt" चुनिए।

### (C) **Manual URL Entry**
- स्क्रिप्ट चलाएं, "Enter URL manually" ऑप्शन चुनें, URL paste करें।

***

## 🎞️ Download Location & Folder Structure

```
/sdcard/YouTube/
├── videos/
│   ├── 720p/
│   │   └── ChannelName/
│   ├── 1080p/
│   │   └── ChannelName/
│   └── best_quality/
├── audios/
│   └── ChannelName/
└── playlists/
```

***

## 🎚️ Quality Options (Download Menu में)

- 1 = 144p (Very low, smallest size)
- 2 = 240p  
- 3 = 360p  
- 4 = 480p  
- 5 = 720p (HD, Recommended)  
- 6 = 1080p  
- 7 = 1440p  
- 8 = 2160p (4K)  
- 9 = Best available
- 10 = Audio Only (MP3)

***

## 🏆 Features At A Glance

| Feature                   | Support                    |
|---------------------------|----------------------------|
| Direct YouTube Share      | ✅                        |
| links.txt Batch Download  | ✅                        |
| Manual URL Entry          | ✅                        |
| All Quality Levels        | ✅                        |
| Audio Only (MP3) Mode     | ✅                        |
| Storage: /sdcard/YouTube/ | ✅                        |
| Download Stats Banner     | ✅                        |
| No Root Required          | ✅                        |
| Fast, Reliable & Safe     | ✅                        |

***

## ❓ FAQ

- **Q:** Share menu में Termux नहीं दिख रहा?
  **A:** `pkg reinstall termux-tools` करने के बाद bin script executable बनाएं।
- **Q:** Error: links.txt not found?
  **A:** Script खुद बनाएगी – edit करके links डाल सकते हैं।
- **Q:** Download failed?
  **A:** Network, video regional restrictions या server side कारण हो सकता है।
- **Q:** FFmpeg/yt-dlp नहीं है?
  **A:** Script पहली बार अपने आप install करती है।

***

## 🤝 योगदान (Contribution)

सुझाव, pull requests, bug fixes हमेशा स्वागत योग्य हैं! Issue बनाएँ या सीधे PR करें।
- GitHub: [@Neeleshrajput55](https://github.com/Neeleshrajput55)

***

## 👑 क्रेडिट

- Script & UX: **Pummy Rajput**
- yt-dlp & ffmpeg का इस्तेमाल
- आपके सुझावों के लिए धन्यवाद 🙏

***

## 📜 License

**MIT License** — Project को open-source और use/edit करने के लिए आप पूरी तरह आज़ाद हैं!

***

**Enjoy #YouTube Video Downloader Pro — Fast, Reliable, Open-Source, Termux-Ready!**

***
