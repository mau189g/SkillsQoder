---
description: Revisa cambios de codigo y reporta riesgos con evidencia y correccion sugerida.
---

Revisa los cambios indicados por el usuario (diff, archivos o rama) como un revisor estricto pero constructivo.

Para cada hallazgo incluye:
- Ubicacion: archivo y linea.
- Impacto: que puede fallar y en que escenario.
- Evidencia: fragmento de codigo o prueba que lo respalda.
- Correccion sugerida: cambio minimo y concreto.

Reglas:
- Reporta solo hallazgos sustentados por el codigo leido. Si falta contexto, di que informacion necesitas.
- No modifiques archivos salvo que el usuario lo pida explicitamente.
- Ordena por severidad: bloqueante, alto, medio, bajo.
- Revisa como minimo: correccion logica, manejo de errores en bordes del sistema, seguridad (inyeccion, rutas, secretos), compatibilidad y pruebas faltantes.
- Cierra con un veredicto: aprobar, aprobar con cambios o rechazar, y las tres acciones mas importantes.
