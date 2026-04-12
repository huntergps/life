# Descargar Gemma 4 desde red local

En Galápagos el internet es lento. La mejor opción es descargar el modelo en una computadora con buena conexión y luego servirlo al iPhone/Android por WiFi local.

## Paso 1: Descargar en la computadora

### Modelo E2B (recomendado, ~2.5 GB)
```bash
curl -L -C - -o ~/Downloads/gemma-4-E2B-it.litertlm \
  "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"
```

### Modelo E4B (high-end, ~4.3 GB)
```bash
curl -L -C - -o ~/Downloads/gemma-4-E4B-it.litertlm \
  "https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm"
```

**Si se interrumpe:** Ejecuta el mismo comando de nuevo. `-C -` reanuda donde quedó.

### Verificar descarga
```bash
ls -lh ~/Downloads/gemma-4-E*
# E2B debe pesar ~2.5 GB
# E4B debe pesar ~4.3 GB
```

## Paso 2: Servir desde la computadora

### Obtener la IP local de tu Mac
```bash
ifconfig en0 | grep "inet " | awk '{print $2}'
# Ejemplo: 192.168.1.50
```

### Iniciar servidor HTTP
```bash
cd ~/Downloads && python3 -m http.server 8080
```

Deja esta terminal abierta mientras el iPhone descarga.

### En Windows
```bash
cd %USERPROFILE%\Downloads
python -m http.server 8080
```

### En Linux
```bash
cd ~/Downloads && python3 -m http.server 8080
```

## Paso 3: Configurar en el iPhone/Android

1. Asegúrate de que el teléfono y la computadora estén en la **misma red WiFi**
2. Abre la app → **Ajustes → AI**
3. Toca el icono **⚙️** (configurar URL) junto al botón "Descargar"
4. Escribe la URL:
   ```
   http://192.168.1.50:8080/gemma-4-E2B-it.litertlm
   ```
   (reemplaza `192.168.1.50` con tu IP real)
5. Toca **Guardar**
6. Toca **Descargar**

La descarga será por WiFi local (~100 MB/s), mucho más rápido que por internet.

## Paso 4: Después de descargar

1. En la terminal de tu Mac, presiona `Ctrl+C` para detener el servidor
2. En la app: **Ajustes → AI → ⚙️ → "Usar HuggingFace"** para restaurar la URL por defecto (opcional)
3. El modelo queda guardado en el dispositivo — no se necesita descargar de nuevo

## Notas

- **La descarga continúa en background:** Si bloqueas la pantalla o cambias de app, la descarga sigue
- **Pausa/Resume:** Durante la descarga puedes pausar (⏸) y reanudar (▶) desde Ajustes → AI
- **Cancelar:** Si necesitas cancelar, toca ✕ durante la descarga
- **Espacio:** Verifica que tu dispositivo tenga al menos 3 GB (E2B) o 5 GB (E4B) de espacio libre
- **Selector de modelo:** Toca el icono 🧠 junto al botón de descarga para elegir entre E2B (standard) y E4B (high-end)

## Qué modelo elegir

| Modelo | Tamaño | RAM necesaria | Dispositivos |
|---|---|---|---|
| **E2B** | 2.5 GB | 4 GB+ | iPhone 12+, la mayoría de Android modernos |
| **E4B** | 4.3 GB | 8 GB+ | iPhone 15 Pro+, Android flagship con 8GB+ RAM |

Si no estás seguro, usa **E2B** — funciona en la mayoría de dispositivos modernos.
