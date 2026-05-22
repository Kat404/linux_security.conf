# 🧹 Limpieza de Metadatos (EXIF & Co.)

Los metadatos son datos estructurados sobre un archivo que no son visibles directamente en su contenido (como los píxeles de una imagen o el texto de un documento), pero que revelan información potencialmente sensible sobre el autor, el dispositivo, el software utilizado y la ubicación geográfica (coordenadas GPS).

Este módulo proporciona documentación y herramientas para la anonimización de archivos eliminando estos metadatos utilizando **mat2** (Metadata Anonymisation Toolkit v2).

---

## 🛡️ ¿Por qué limpiar metadatos?

Cuando compartes un archivo (imágenes, PDFs, audios, documentos), a menudo compartes inadvertidamente:

- **Coordenadas GPS:** Ubicación exacta donde se tomó una foto.
- **Identificadores de Dispositivo:** Marca, modelo, número de serie de tu cámara o smartphone.
- **Software e Historial:** Versiones de software de edición de imágenes, sistemas operativos, nombres de usuario y rutas de archivos locales en tu sistema.
- **Fechas y Horas:** Modificaciones y creaciones exactas del archivo.

---

## 🛠️ Herramientas Recomendadas

### 1. mat2 (Metadata Anonymisation Toolkit v2)

Es la herramienta de anonimización estándar recomendada por **PrivacyGuides** y utilizada en sistemas como **Tails OS**.

- **FOSS:** Licenciado bajo GPLv3, escrito en Python.
- **Modo de Operación:** Limpia metadatos de forma segura y destructiva (reemplazando el archivo o creando una copia limpia).
- **Formatos Soportados:** PNG, JPEG, TIFF, PDF, ODT, DOCX, PPTX, XLSX, MP3, FLAC, Torrent, entre otros.
- **Repositorio Oficial:** [https://0xacab.org/jvoisin/mat2](https://0xacab.org/jvoisin/mat2)

### 2. ExifTool

Una herramienta CLI sumamente potente para leer, escribir y editar información de metadatos. Se utiliza como complemento de análisis.

- **Repositorio Oficial:** [https://exiftool.org/](https://exiftool.org/)

---

## 📥 Instalación

### En Arch Linux (usando Pacman)

```bash
sudo pacman -S mat2 perl-image-exiftool
```

### En Debian/Ubuntu

```bash
sudo apt update
sudo apt install mat2 exiftool
```

---

## 📖 Instrucciones de Uso

### Analizar metadatos sin modificar el archivo

Para ver si un archivo contiene metadatos sospechosos/sensibles utilizando `mat2`:

```bash
mat2 --show archivo.jpg
```

O usando `exiftool` para un análisis exhaustivo:

```bash
exiftool archivo.jpg
```

### Limpiar metadatos

Por defecto, `mat2` creará una copia del archivo con la extensión `.cleaned` (ej. `archivo.cleaned.jpg`) libre de metadatos:

```bash
mat2 archivo.jpg
```

Si deseas limpiar el archivo original directamente (sobrescribiéndolo), utiliza el flag `-i` o `--inplace`:

```bash
mat2 --inplace archivo.jpg
```

---

## 🤖 Automatización con Script

Hemos provisto el script [`clean_metadata.sh`](./clean_metadata.sh) para automatizar la limpieza de archivos individuales o carpetas de manera recursiva.

### Ejecutar el script:

1. Dale permisos de ejecución:

   ```bash
   chmod +x clean_metadata.sh
   ```

2. Ejecútalo pasándole como argumento un archivo o un directorio entero:

   ```bash
   ./clean_metadata.sh /ruta/al/directorio_o_archivo
   ```
