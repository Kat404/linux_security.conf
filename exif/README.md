# 🧹 Metadata Removal (EXIF & Co.)

Metadata is structured data about a file that is not directly visible in its content (like the pixels of an image or the text of a document), but reveals potentially sensitive information about the author, device, software used, and geographical location (GPS coordinates).

This module provides documentation and tools for file anonymization by removing this metadata using **mat2** (Metadata Anonymisation Toolkit v2).

---

## 🛡️ Why Clean Metadata?

When you share a file (images, PDFs, audios, documents), you often inadvertently share:

- **GPS Coordinates:** The exact location where a photo was taken.
- **Device Identifiers:** The brand, model, and serial number of your camera or smartphone.
- **Software and History:** Versions of image editing software, operating systems, local usernames, and file paths on your system.
- **Dates and Times:** Exact file creation and modification timestamps.

---

## 🛠️ Recommended Tools

### 1. mat2 (Metadata Anonymisation Toolkit v2)

It is the standard anonymization tool recommended by **PrivacyGuides** and used in systems like **Tails OS**.

- **FOSS:** Licensed under GPLv3, written in Python.
- **Operation Mode:** Cleans metadata safely and destructively (by replacing the file or creating a clean copy).
- **Supported Formats:** PNG, JPEG, TIFF, PDF, ODT, DOCX, PPTX, XLSX, MP3, FLAC, Torrent, among others.
- **Official Repository:** [https://0xacab.org/jvoisin/mat2](https://0xacab.org/jvoisin/mat2)

### 2. ExifTool

A highly powerful CLI tool for reading, writing, and editing metadata information. Used as an analysis complement.

- **Official Repository:** [https://exiftool.org/](https://exiftool.org/)

---

## 📥 Installation

### On Arch Linux (using Pacman)

```bash
sudo pacman -S mat2 perl-image-exiftool
```

### On Debian/Ubuntu

```bash
sudo apt update
sudo apt install mat2 exiftool
```

---

## 📖 Usage Instructions

### Analyze metadata without modifying the file

To check if a file contains suspicious/sensitive metadata using `mat2`:

```bash
mat2 --show file.jpg
```

Or using `exiftool` for a comprehensive analysis:

```bash
exiftool file.jpg
```

### Clean metadata

By default, `mat2` will create a copy of the file with the `.cleaned` extension (e.g., `file.cleaned.jpg`) free of metadata:

```bash
mat2 file.jpg
```

If you wish to clean the original file directly (overwriting it), use the `-i` or `--inplace` flag:

```bash
mat2 --inplace file.jpg
```

---

## 🤖 Script Automation

We have provided the [`clean_metadata.sh`](./clean_metadata.sh) script to automate metadata cleanup for individual files or entire folders recursively.

### Run the script:

1. Grant execution permissions:

   ```bash
   chmod +x clean_metadata.sh
   ```

2. Run it by passing a file or an entire directory as an argument:

   ```bash
   ./clean_metadata.sh /path/to/directory_or_file
   ```
