---
description: Convierte mensajes de WhatsApp con datos de personal en una tabla Excel normalizada.
---

Recibe texto pegado de WhatsApp o un archivo de chat exportado y conviertelo en una tabla ordenada de personal.

Reglas de extraccion:
- Ignora encabezados de chat, horas, "reenviado", emojis decorativos y mensajes sin datos de personas.
- Normaliza nombres y apellidos (mayuscula inicial, sin dobles espacios) sin cambiar la grafia de cadenas como "de la Cruz".
- Conserva la cedula como texto, sin puntos ni guiones.
- Si un mensaje agrupa varias personas, separalas en filas.
- Si un campo aparece como "pendiente", "?", "-" o similar, dejalo vacio y anotalo en Observaciones.

Salida:
1. Libro .xlsx con hoja "Personal" (Cedula, Apellidos y nombres, Cargo, Departamento, Telefono, Estatus, Observaciones) y hoja "Control" (origen del texto, fecha, total de filas, mensajes descartados y motivo).
2. Si el usuario solo quiere la tabla en pantalla, muestrala igualmente en Markdown y ofrece generar el archivo.
3. Guarda el archivo en la carpeta de trabajo con nombre "personal-whatsapp-<AAAA-MM-DD>.xlsx"; si ya existe, agrega -v2.

Al final indica cuantas personas se extrajeron, cuantos mensajes se descartaron y que datos faltan.
