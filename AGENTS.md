# AGENTS.md - Wildlands Survival

## Identidad del proyecto

Wildlands Survival es un videojuego de supervivencia 2D, con perspectiva Top-Down, mundo abierto y modalidad de un solo jugador.

Está desarrollado utilizando Godot 4 y GDScript.

La temática principal es la supervivencia en la naturaleza, con exploración, recolección de recursos, fabricación, construcción y administración de necesidades.

## Reglas generales

1. Trabajar siempre sobre el proyecto existente.
2. No reemplazar archivos sin revisar previamente su contenido.
3. Mantener una arquitectura modular.
4. Evitar scripts excesivamente grandes.
5. Utilizar GDScript compatible con la versión instalada de Godot.
6. Utilizar tipado estático cuando sea conveniente.
7. Separar los datos de la lógica del juego.
8. Utilizar señales para comunicar sistemas cuando sea apropiado.
9. Evitar dependencias circulares.
10. Mantener nombres descriptivos y consistentes.
11. No eliminar funcionalidades existentes sin autorización.
12. No afirmar que una funcionalidad funciona sin haberla probado.

## Arquitectura

Mantener separados los siguientes sistemas:

- Player
- World
- Inventory
- Survival
- Interaction
- Resources
- Crafting
- Construction
- Animals
- Environment
- Save System
- User Interface

Cada sistema debe tener responsabilidades claras.

## Desarrollo

Trabajar mediante fases.

No avanzar automáticamente a una fase nueva sin comprobar la anterior.

Al terminar una fase, documentar:

- Funcionalidades implementadas.
- Archivos creados.
- Archivos modificados.
- Sistemas conectados.
- Pruebas realizadas.
- Errores encontrados.
- Tareas pendientes.

## Pruebas

Cuando sea posible:

- Ejecutar comprobaciones del proyecto mediante Godot en modo headless.
- Comprobar las escenas.
- Revisar errores de GDScript.
- Verificar referencias y recursos.
- Comprobar las conexiones entre sistemas.

Si no es posible ejecutar alguna prueba, indicarlo claramente.

## Git

No ejecutar automáticamente:

- git reset --hard
- git clean
- git push --force
- Eliminación masiva de archivos.

No realizar commits ni subir cambios a GitHub sin autorización explícita.

No incluir la carpeta .godot en el repositorio.

## Calidad visual

Priorizar una estética natural 2D.

Evitar que los recursos provisionales se presenten como gráficos definitivos.

Mantener los recursos gráficos organizados y reemplazables.

## Comunicación

Explicar las decisiones técnicas importantes de manera clara.

Cuando sea necesario realizar una acción manual en Godot, proporcionar instrucciones paso a paso.

No avanzar si existen errores importantes sin resolver.