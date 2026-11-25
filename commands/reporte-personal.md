---
description: Genera un reporte Word semanal de personal a partir de la planilla Excel vigente.
---

Redacta un reporte semanal de personal en espanol, en formato Word (.docx), usando como fuente la planilla Excel que indique el usuario.

Estructura obligatoria:
1. Encabezado: titulo, periodo (fecha inicial y final), fecha de emision y fuente de datos (nombre exacto del archivo Excel).
2. Resumen ejecutivo: total de personal activo, altas, bajas y cambios de cargo o sueldo en el periodo.
3. Altas: tabla con cedula, nombre, cargo, departamento y fecha de ingreso.
4. Bajas: tabla con cedula, nombre, cargo y fecha de egreso. Si la planilla no tiene fecha de egreso, indicalo.
5. Cambios: tabla con cedula, nombre, campo modificado, valor anterior y valor nuevo.
6. Pendientes y riesgos: datos incompletos, duplicados detectados y casos que requieren validacion humana.
7. Anexo: total de filas leidas, filas excluidas y criterio de exclusion.

Reglas:
- No inventes cifras ni redondees sueldos. Usa exactamente los valores de la planilla.
- Si falta un dato, escribe "No registrado en la fuente" en lugar de suponer.
- Usa tablas con encabezados repetidos y estilo sobrio; no agregues imagenes ni graficos salvo que el usuario lo pida.
- Guarda el archivo como "reporte-personal-<AAAA-MM-DD>.docx" en la carpeta de trabajo.
- Termina con una lista breve de supuestos y de lo que el usuario debe confirmar antes de enviar el reporte.
