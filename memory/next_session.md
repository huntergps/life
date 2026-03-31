---
name: next_session
description: Tareas pendientes para la próxima sesión de trabajo
type: project
---

## Pendientes para próxima sesión

### 1. Agregar logging al RecognitionFeedbackService
- El `catch (_)` en `recognition_feedback_service.dart` (líneas 47 y 86) traga errores silenciosamente
- Agregar `debugPrint` o `log()` para diagnosticar si hay fallos de upload/insert
- Verificar que las pruebas de campo en Puerto Egas (2026-03-16) llegaron a Supabase

### 2. Verificar datos post-pruebas de campo
- Última data en `species_recognition_feedback`: 2026-03-09 (14 registros, 10 fotos)
- Después de las pruebas en Puerto Egas, verificar nuevos registros
- Si no hay datos nuevos → investigar causa raíz (auth, red, unawaited)

### 3. Modelo TFLite / Sound ID (pendiente anterior)
- Verificar MCP Colab cargó
- Probar modelo TFLite en iPhone
- Si modelo OK → Sound ID con BirdNET
