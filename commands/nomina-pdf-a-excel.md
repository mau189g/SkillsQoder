---
description: Convierte una nomina o lista de personal escaneada (PDF o imagenes) en una hoja de Excel verificada.
---

Trabaja como asistente de RR. HH. para AMB (Venezuela) y produce una planilla en Excel a partir de documentos escaneados.

1. Usa los archivos que indique el usuario (PDF escaneado o imagenes). Si no hay una ruta, pide una sola vez la carpeta o los archivos.
2. Extrae cada fila con estas columnas, en este orden: Cedula, Apellidos y nombres, Cargo, Departamento, Fecha de ingreso, Sueldo, Estatus, Observaciones.
3. Conserva el orden original de las filas. No inventes cedulas, montos, fechas ni cargos: si un dato no se lee, deja la celda vacia y explica la duda en Observaciones.
4. Crea un libro .xlsx con:
   - Hoja "Planilla": encabezados en la fila 1, una fila por persona, formato de tabla, cedula y telefono como texto.
   - Hoja "Control": archivo fuente, fecha de procesado, total de filas, filas completas, filas con dudas y lista de campos ausentes en el documento.
5. Resalta en amarillo las celdas dudosas y agrega una nota con el texto exacto que si se leia en el escaneo.
6. Guarda el archivo junto al PDF original con el nombre "<nombre-del-archivo> - planilla.xlsx". No sobrescribas archivos existentes; usa un sufijo -v2, -v3.
7. Al terminar, resume en espanol: filas procesadas, filas con dudas, campos que no aparecian y cualquier decision que necesite confirmacion humana.

No modifiques ni renombres los archivos de origen.
