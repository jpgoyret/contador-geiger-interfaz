# Interfaz de manejo y visualización de los datos de un contador Geiger-Müller en microcontrolador de 8 bits

## Descripcion:
Dispositivo para controlar y recibir información de un detector de partículas radioactivas. Este informa la cantidad de partículas que han sido recibidas en un intervalo de tiempo deseado y, en particular, comunica cuando se ha superado un umbral de radiación establecido por el usuario.

El primer prototipo funcional de este proyecto fue realizado en el marco de la materia "6609/8607 Laboratorio de Microcontroladores" en la Facultad de Ingeniería de la Universidad de Buenos Aires (FIUBA).

La intrerfaz fue desarrollada sobre un microcontrolador de 8 bits Atmega328p (integrado en un Arduino) y programada en Assembly.

## Navegación del repositorio

En el archivo [Documentacion_Contador_Geiger](Documentacion_Contador_Geiger.pdf) se podrá encontrar la documentación propia de la interfaz incluyendo: breve descripción del desarrollo, diagramas de flujo y de bloques, componentes de la interfaz, conexiones, entre otros.

En [Mediciones_Contador_Geiger](Mediciones_Contador_Geiger.pdf) se incluyen las mediciones realizadas sobre el contador Geiger por medio de la interfaz de manejo y visualización de datos. Para dichas pruebas se empleó una fuente elevadora de tensión elaborada por Ing. Ricardo Arias.

#### Carpetas:

- Codigo: incluye el código fuente del programa que irá embebido en el microcontrolador Atmega328p. Dicho código puede ser copiado y pegado dentro de la carpeta de un proyecto de Atmel Studio para poder ser modificado.
- diseño_caja_contador_geiger: contiene los archivos 3D del diseño de una caja que contenga a la fuente elevadora de tensión armada en una placa de 10cmx10cm.
- esquematicos: contiene los esquemáticos del PCB del shield del Arduino y del teclado.


## Integrantes del equipo:
- Nuñez Frau, Federico
- Vidal, Gabriel
- Goyret, Juan Pablo
