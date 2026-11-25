---
description: Audita una planilla Excel contra el documento original y reporta diferencias sin modificar la fuente.
---

Compara una planilla Excel ya procesada contra el documento original (PDF escaneado, imagenes o texto) y entrega un informe de diferencias.

Procedimiento:
1. Confirma las rutas del Excel y del original. Si falta una, pide solo esa.
2. Revisa fila por fila y campo por campo: cedula, nombres, cargo, departamento, fechas y montos.
3. Clasifica cada hallazgo como:
   - Falta en el Excel
   - Sobra en el Excel
   - Valor distinto
   - Duplicado
   - Formato invalido (cedula con puntos, fecha como texto, monto con separador incorrecto)
4. Entrega una tabla de hallazgos con: fila del Excel, persona, campo, valor en Excel, valor en el original y accion sugerida.
5. Genera un archivo "auditoria-<nombre-planilla>-<AAAA-MM-DD>.xlsx" con dos hojas: "Hallazgos" y "Resumen" (conteo por tipo y por campo).
6. No edites la planilla original. Si el usuario pide corregir, crea una copia con sufijo "-corregida" y registra cada cambio.

Al final indica la tasa de coincidencia (campos correctos / campos revisados) y los tres riesgos mas importantes.
